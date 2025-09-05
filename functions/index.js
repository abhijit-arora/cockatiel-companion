const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {getStorage} = require("firebase-admin/storage");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const BLOCKED_LABELS = ["Adult", "Violence", "Racy", "Medical", "Spoof"];

exports.acceptInvitation = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in to perform this action.",
    );
  }

  const invitationId = data.invitationId;
  if (!invitationId) {
    throw new HttpsError("invalid-argument", "Invitation ID is required.");
  }

  const inviteeUid = auth.uid;
  const inviteeEmail = auth.token.email;

  // --- Query for necessary data BEFORE the transaction ---
  const invRef = db.collection("invitations").doc(invitationId);
  const invDoc = await invRef.get();

  if (!invDoc.exists) {
    throw new HttpsError("not-found", "Invitation not found.");
  }
  const invData = invDoc.data();
  const guardianId = invData.aviaryOwnerId;

  // Find all birds belonging to the Guardian before starting the transaction
  const birdsSnapshot = await db.collection("birds")
      .where("ownerId", "==", guardianId)
      .get();

  const result = await db.runTransaction(async (transaction) => {
    // Re-read the invitation inside the transaction to prevent race conditions
    const freshInvDoc = await transaction.get(invRef);
    if (!freshInvDoc.exists) {
      throw new HttpsError(
          "not-found",
          "Invitation not found during transaction.",
      );
    }
    const freshInvData = freshInvDoc.data();
    if (
      freshInvData.inviteeEmail !== inviteeEmail ||
      freshInvData.status !== "pending"
    ) {
      throw new HttpsError(
          "failed-precondition",
          "This invitation is not valid.",
      );
    }

    const inviteeUserRef = db.collection("users").doc(inviteeUid);
    const inviteeUserDoc = await transaction.get(inviteeUserRef);
    if (inviteeUserDoc.exists) {
      throw new HttpsError(
          "failed-precondition",
          "You already have an Aviary.",
      );
    }

    // All checks passed, perform the writes
    const guardianAviaryRef = db.collection("aviaries").doc(guardianId);
    const caregiverRef = guardianAviaryRef
        .collection("caregivers")
        .doc(inviteeUid);

    transaction.set(caregiverRef, {
      email: inviteeEmail,
      label: freshInvData.label,
      joinedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    transaction.set(inviteeUserRef, {
      partOfAviary: guardianId,
      guardianEmail: inviteeEmail,
    }, {merge: true});

    transaction.update(invRef, {status: "accepted"});

    // Use the pre-fetched bird snapshot to perform the updates
    birdsSnapshot.forEach((doc) => {
      const birdRef = db.collection("birds").doc(doc.id);
      transaction.update(birdRef, {
        viewers: admin.firestore.FieldValue.arrayUnion(inviteeUid),
      });
    });

    return {
      success: true,
      message: "Invitation accepted! Welcome to the flock.",
    };
  });

  console.log("acceptInvitation v2 returning:", result);
  return result;
});

exports.setAviaryName = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in to perform this action.",
    );
  }

  const newName = data.name;
  const aviaryId = auth.uid; // The user can only change their own aviary name

  // --- 1. VALIDATION ---
  if (!newName || typeof newName !== "string") {
    throw new HttpsError("invalid-argument", "A valid name is required.");
  }

  const trimmedName = newName.trim();

  // Check length (e.g., 3-25 characters)
  if (trimmedName.length < 3 || trimmedName.length > 25) {
    throw new HttpsError(
        "invalid-argument",
        "Name must be between 3 and 25 characters.",
    );
  }

  // Check for invalid characters (allow letters, numbers,
  // spaces, and single hyphens/underscores)
  if (!/^[a-zA-Z0-9 _-]+$/.test(trimmedName)) {
    throw new HttpsError(
        "invalid-argument",
        "Name can only contain letters, numbers, spaces, underscores, " +
        "and hyphens.",
    );
  }

  // Check for your double separator rule
  if (/([_ -])\1/.test(trimmedName)) {
    throw new HttpsError(
        "invalid-argument",
        "Name cannot contain consecutive spaces or separators.",
    );
  }

  // --- 2. UNIQUENESS CHECK & WRITE (in a transaction) ---
  const aviaryRef = db.collection("aviaries").doc(aviaryId);
  const aviariesQuery = db
      .collection("aviaries")
      .where("aviaryName", "==", trimmedName);

  return db.runTransaction(async (transaction) => {
    const aviariesSnapshot = await transaction.get(aviariesQuery);

    // If any documents are found, the name is taken,
    // unless it's this user's own current name.
    if (!aviariesSnapshot.empty) {
      let nameIsTaken = false;
      aviariesSnapshot.forEach((doc) => {
        if (doc.id !== aviaryId) {
          nameIsTaken = true;
        }
      });
      if (nameIsTaken) {
        throw new HttpsError(
            "already-exists",
            `The name "${trimmedName}" is already taken.`,
        );
      }
    }

    // All checks passed. Update the aviary name.
    transaction.update(aviaryRef, {aviaryName: trimmedName});
    return {success: true, message: "Aviary name updated successfully!"};
  });
});

exports.moderateImageLabels = onDocumentCreated(
    "imageLabels/{imageId}", async (event) => {
      const snap = event.data;
      if (!snap) {
        return;
      }
      const data = snap.data();
      const annotations = data.labelAnnotations || [];

      let shouldDelete = false;
      let foundBlockedLabel = "";

      for (const annotation of annotations) {
        if (BLOCKED_LABELS.includes(annotation.description)) {
          shouldDelete = true;
          foundBlockedLabel = annotation.description;
          break;
        }
      }

      if (shouldDelete) {
        const filePath = data.filePath;
        if (!filePath) {
          return;
        }

        const chirpsRef = db.collection("community_chirps");
        const query = chirpsRef.where("mediaUrl", "==", data.gcsUrl);

        try {
          const querySnapshot = await query.get();
          if (querySnapshot.empty) {
            await getStorage().bucket().file(filePath).delete();
            return;
          }

          const chirpDoc = querySnapshot.docs[0];
          const authorId = chirpDoc.data().authorId;

          await Promise.all([
            getStorage().bucket().file(filePath).delete(),
            chirpDoc.ref.update({
              mediaStatus: "REMOVED_BY_MODERATION",
              moderatedForLabel: foundBlockedLabel,
            }),
            db.collection("notifications").add({
              userId: authorId,
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
              type: "MODERATION",
              title: "Your Image Was Removed",
              body: `An image in your Chirp "${chirpDoc.data().title}" was ` +
              `automatically removed because ` +
              `it was flagged as "${foundBlockedLabel}".`,
              isRead: false,
            }),
            snap.ref.set({
              moderationStatus: "DELETED",
              deletedForLabel: foundBlockedLabel,
            }, {merge: true}),
          ]);
        } catch (err) {
          console.error(`Failed during moderation ` +
            `cleanup for ${filePath}:`, err);
        }
      } else {
        await snap.ref.set({moderationStatus: "APPROVED"}, {merge: true});
      }
    });

exports.toggleChirpFollow = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const chirpId = data.chirpId;
  if (!chirpId) {
    throw new HttpsError("invalid-argument", "Chirp ID is required.");
  }

  const userId = auth.uid;
  const chirpRef = db.collection("community_chirps").doc(chirpId);
  const followerRef = chirpRef.collection("followers").doc(userId);

  return db.runTransaction(async (transaction) => {
    const followerDoc = await transaction.get(followerRef);

    if (followerDoc.exists) {
      // --- The user has already followed, so we UNFOLLOW ---
      transaction.delete(followerRef);
      transaction.update(chirpRef, {
        followerCount: admin.firestore.FieldValue.increment(-1),
      });
      return {newFollowState: false};
    } else {
      // --- The user has NOT yet followed, so we FOLLOW ---
      transaction.set(followerRef, {
        followedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      transaction.update(chirpRef, {
        followerCount: admin.firestore.FieldValue.increment(1),
      });
      return {newFollowState: true};
    }
  });
});

exports.toggleReplyHelpful = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const {chirpId, replyId} = data;
  if (!chirpId || !replyId) {
    throw new HttpsError(
        "invalid-argument",
        "Chirp ID and Reply ID are required.",
    );
  }

  const userId = auth.uid;
  const replyRef = db
      .collection("community_chirps")
      .doc(chirpId)
      .collection("replies")
      .doc(replyId);

  // A subcollection to track who has marked this reply as helpful.
  const markerRef = replyRef.collection("helpfulMarkers").doc(userId);

  return db.runTransaction(async (transaction) => {
    const markerDoc = await transaction.get(markerRef);

    if (markerDoc.exists) {
      // --- The user has already marked it, so we UN-MARK ---
      transaction.delete(markerRef);
      transaction.update(replyRef, {
        helpfulCount: admin.firestore.FieldValue.increment(-1),
      });
      return {newHelpfulState: false};
    } else {
      // --- The user has NOT yet marked it, so we MARK IT ---
      transaction.set(markerRef, {
        markedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      transaction.update(replyRef, {
        helpfulCount: admin.firestore.FieldValue.increment(1),
      });
      return {newHelpfulState: true};
    }
  });
});

exports.reportContent = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  // Expecting generic parameters, not bird-specific ones
  const {contentId, contentType, reason} = data;

  // --- 1. VALIDATION ---
  if (!contentId || !contentType || !reason) {
    throw new HttpsError(
        "invalid-argument",
        "Content ID, content type, and reason are required.",
    );
  }

  const validTypes = ["chirp", "reply", "feedPost", "comment"];
  if (!validTypes.includes(contentType)) {
    throw new HttpsError(
        "invalid-argument",
        "Invalid content type specified.",
    );
  }

  const reporterUid = auth.uid;
  let docRef;

  // --- 2. LOCATE THE CONTENT TO GET ITS DATA ---
  // This logic determines where to look for the content based on its type
  if (contentType === "chirp") {
    docRef = db.collection("community_chirps").doc(contentId);
  } else if (contentType === "reply") {
    // Note: For replies, the contentId is expected to be the full path.
    // We will construct this path from the Flutter app.
    // Example: "community_chirps/{chirpId}/replies/{replyId}"
    docRef = db.doc(contentId);
  } else {
    // This case is already handled by the validation above,
    // but it's good practice
    // to have a fallback.
    return {success: false, message: "Invalid content type."};
  }

  const contentDoc = await docRef.get();
  if (!contentDoc.exists) {
    throw new HttpsError(
        "not-found",
        "The content you are trying to report does not exist.",
    );
  }

  const contentData = contentDoc.data();
  const authorId = contentData.authorId;
  // Get title for chirps, body for replies
  const contentBody = contentData.title || contentData.body;

  // --- 3. CREATE THE REPORT DOCUMENT ---
  // We save it to a top-level 'reports' collection for easy querying by admins.
  await db.collection("reports").add({
    reporterUid: reporterUid,
    reportedAt: admin.firestore.FieldValue.serverTimestamp(),
    reason: reason,

    // Store information about the content that was flagged
    contentType: contentType,
    contentId: contentId,
    contentAuthorUid: authorId,
    // Store a snippet for context
    contentSnippet: contentBody.substring(0, 100),

    // The path to the original document for easy navigation in the admin panel
    contentPath: docRef.path,

    // Status for the admin panel workflow
    status: "pending_review",
  });

  return {success: true, message: "Report has been submitted. Thank you."};
});

exports.markAsBestAnswer = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const {chirpId, replyId} = data;
  if (!chirpId || !replyId) {
    throw new HttpsError(
        "invalid-argument",
        "Chirp ID and Reply ID are required.",
    );
  }

  const userId = auth.uid;
  const chirpRef = db.collection("community_chirps").doc(chirpId);
  const newBestReplyRef = chirpRef.collection("replies").doc(replyId);

  return db.runTransaction(async (transaction) => {
    // 1. Get the main chirp document
    const chirpDoc = await transaction.get(chirpRef);
    if (!chirpDoc.exists) {
      throw new HttpsError("not-found", "Chirp not found.");
    }
    const chirpData = chirpDoc.data();

    // 2. SECURITY CHECK: Only the author can mark a best answer.
    if (chirpData.authorId !== userId) {
      throw new HttpsError(
          "permission-denied",
          "Only the author of the Chirp can select a best answer.",
      );
    }

    // 3. Get the new reply to be marked as best
    const newBestReplyDoc = await transaction.get(newBestReplyRef);
    if (!newBestReplyDoc.exists) {
      throw new HttpsError("not-found", "The selected reply does not exist.");
    }

    // 4. If an old best answer exists, un-mark it.
    if (chirpData.bestAnswer && chirpData.bestAnswer.replyId) {
      const oldBestReplyRef = chirpRef
          .collection("replies")
          .doc(chirpData.bestAnswer.replyId);

      // We check if the old best answer still exists
      // before trying to update it.
      const oldBestReplyDoc = await transaction.get(oldBestReplyRef);
      if (oldBestReplyDoc.exists) {
        transaction.update(oldBestReplyRef, {isBestAnswer: false});
      }
    }

    // 5. Set the new best answer on the main chirp and the reply itself.
    const newBestReplyData = newBestReplyDoc.data();
    transaction.update(chirpRef, {
      bestAnswer: {
        replyId: newBestReplyDoc.id,
        body: newBestReplyData.body,
        authorLabel: newBestReplyData.authorLabel,
        createdAt: newBestReplyData.createdAt,
      },
    });

    transaction.update(newBestReplyRef, {isBestAnswer: true});

    return {success: true, message: "Reply marked as best answer."};
  });
});

exports.declineInvitation = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const {invitationId} = data;
  if (!invitationId) {
    throw new HttpsError("invalid-argument", "Invitation ID is required.");
  }

  const inviteeEmail = auth.token.email;
  const invRef = db.collection("invitations").doc(invitationId);

  // We use a transaction to safely read and then write.
  return db.runTransaction(async (transaction) => {
    const invDoc = await transaction.get(invRef);

    if (!invDoc.exists) {
      throw new HttpsError("not-found", "Invitation not found.");
    }

    const invData = invDoc.data();

    // SECURITY CHECK: You can only decline an invitation sent to your email.
    if (invData.inviteeEmail !== inviteeEmail || invData.status !== "pending") {
      throw new HttpsError(
          "failed-precondition",
          "This invitation is not valid to be declined.",
      );
    }

    // All checks passed, update the status.
    transaction.update(invRef, {status: "declined"});

    return {success: true, message: "Invitation declined."};
  });
});

exports.createFeedPost = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in to post.");
  }

  const {body, mediaUrl} = data;
  const authorUid = auth.uid;

  // --- 1. VALIDATION ---
  if (!body && !mediaUrl) {
    throw new HttpsError(
        "invalid-argument",
        "A post must contain a caption or media.",
    );
  }

  // --- 2. HASHTAG PARSING ---
  const hashtags = [];
  if (body) {
    // This regex finds all words starting with #
    const hashtagRegex = /(#\w+)/g;
    const matches = body.match(hashtagRegex);
    if (matches) {
      // Add valid hashtags to the array, ensuring no duplicates
      matches.forEach((tag) => {
        if (!hashtags.includes(tag)) {
          hashtags.push(tag);
        }
      });
    }
  }

  // --- 3. GET AUTHOR LABEL ---
  // This reuses the same logic as our Flutter UserService.
  // We will refactor this later.
  const userDoc = await db.collection("users").doc(authorUid).get();
  let aviaryId;
  let isGuardian = true;
  if (userDoc.exists && userDoc.data().partOfAviary) {
    aviaryId = userDoc.data().partOfAviary;
    isGuardian = false;
  } else {
    aviaryId = authorUid;
  }
  const aviaryDoc = await db.collection("aviaries").doc(aviaryId).get();
  const aviaryName = aviaryDoc.data().aviaryName || "An Aviary";
  let userLabel;
  if (isGuardian) {
    userLabel = aviaryDoc.data()
        .guardianLabel || auth.token.email || "Guardian";
  } else {
    const caregiverDoc = await db
        .collection("aviaries").doc(aviaryId)
        .collection("caregivers").doc(authorUid).get();
    userLabel = caregiverDoc.data().label || auth.token.email || "Caregiver";
  }
  const authorLabel = `${userLabel} of ${aviaryName}`;


  // --- 4. PREPARE AND SAVE THE DOCUMENT ---
  const postData = {
    authorId: authorUid,
    authorLabel: authorLabel,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    body: body || null,
    mediaUrl: mediaUrl || null,
    hashtags: hashtags, // Add the parsed hashtags
    likeCount: 0,
    commentCount: 0,
  };

  const newPostRef = await db.collection("community_feed_posts").add(postData);

  return {success: true, postId: newPostRef.id};
});

exports.toggleFeedPostLike = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const {postId} = data;
  if (!postId) {
    throw new HttpsError("invalid-argument", "Post ID is required.");
  }

  const userId = auth.uid;
  const postRef = db.collection("community_feed_posts").doc(postId);
  const likeRef = postRef.collection("likes").doc(userId);

  return db.runTransaction(async (transaction) => {
    const likeDoc = await transaction.get(likeRef);

    if (likeDoc.exists) {
      // --- The user has already liked, so we UNLIKE ---
      transaction.delete(likeRef);
      transaction.update(postRef, {
        likeCount: admin.firestore.FieldValue.increment(-1),
      });
      return {newLikeState: false};
    } else {
      // --- The user has NOT yet liked, so we LIKE ---
      transaction.set(likeRef, {
        likedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      transaction.update(postRef, {
        likeCount: admin.firestore.FieldValue.increment(1),
      });
      return {newLikeState: true};
    }
  });
});

exports.deleteFeedPost = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const {postId} = data;
  if (!postId) {
    throw new HttpsError("invalid-argument", "Post ID is required.");
  }

  const userId = auth.uid;
  const postRef = db.collection("community_feed_posts").doc(postId);

  const postDoc = await postRef.get();
  if (!postDoc.exists) {
    throw new HttpsError("not-found", "Post not found.");
  }

  const postData = postDoc.data();

  // --- SECURITY CHECK: Only the author can delete their post ---
  if (postData.authorId !== userId) {
    throw new HttpsError(
        "permission-denied",
        "You can only delete your own posts.",
    );
  }

  // --- DELETE ASSOCIATED MEDIA from Firebase Storage ---
  if (postData.mediaUrl) {
    try {
      // Create a reference from the public URL
      const fileRef = getStorage().bucket().file(
          decodeURIComponent(
              postData.mediaUrl.split("/o/")[1].split("?")[0],
          ),
      );
      await fileRef.delete();
    } catch (error) {
      // Log the error but don't block the Firestore deletion
      console.error(`Failed to delete media for post ${postId}:`, error);
    }
  }

  // --- DELETE THE FIRESTORE DOCUMENT ---
  // Note: We are not deleting subcollections (likes/comments) here yet.
  // A more robust solution for that is a separate background function,
  // which we can add to the roadmap. Deleting the post is the main goal.
  await postRef.delete();

  return {success: true, message: "Post deleted successfully."};
});

exports.addFeedComment = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError(
        "unauthenticated",
        "You must be logged in to comment.",
    );
  }

  const {postId, body} = data;
  if (!postId || !body || typeof body !== "string" || body.trim() === "") {
    throw new HttpsError(
        "invalid-argument",
        "Post ID and a non-empty comment body are required.",
    );
  }

  const authorUid = auth.uid;
  const postRef = db.collection("community_feed_posts").doc(postId);

  // --- Get Author Label Logic ---
  // NOTE: This is the same logic used in createFeedPost. We will refactor this
  // into a shared helper function in a future technical health sprint.
  const userDoc = await db.collection("users").doc(authorUid).get();
  let aviaryId;
  let isGuardian = true;
  if (userDoc.exists && userDoc.data().partOfAviary) {
    aviaryId = userDoc.data().partOfAviary;
    isGuardian = false;
  } else {
    aviaryId = authorUid;
  }
  const aviaryDoc = await db.collection("aviaries").doc(aviaryId).get();
  const aviaryData = aviaryDoc.data() || {}; // Get the data or an empty object
  const aviaryName = aviaryData.aviaryName || "An Aviary";
  let userLabel;
  if (isGuardian) {
    userLabel = aviaryData.guardianLabel || auth.token.email || "Guardian";
  } else {
    const caregiverDoc = await db
        .collection("aviaries").doc(aviaryId)
        .collection("caregivers").doc(authorUid).get();
    const caregiverData = caregiverDoc.data() || {};
    userLabel = caregiverData.label || auth.token.email || "Caregiver";
  }
  const authorLabel = `${userLabel} of ${aviaryName}`;

  const commentData = {
    authorId: authorUid,
    authorLabel: authorLabel,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    body: body.trim(),
    likeCount: 0,
  };

  // --- Use a transaction to post the comment
  // and update the count atomically ---
  await db.runTransaction(async (transaction) => {
    const postDoc = await transaction.get(postRef);
    if (!postDoc.exists) {
      throw new HttpsError(
          "not-found",
          "The post you are trying to comment on does not exist.",
      );
    }

    const newCommentRef = postRef
        .collection("comments").doc(); // Auto-generate ID
    transaction.set(newCommentRef, commentData);
    transaction.update(postRef, {
      commentCount: admin.firestore.FieldValue.increment(1),
    });
  });

  return {success: true, message: "Comment posted successfully."};
});

exports.toggleCommentLike = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  // Note: We expect the full path to the comment as the commentId
  const {commentId} = data;
  if (!commentId) {
    throw new HttpsError("invalid-argument", "Comment ID path is required.");
  }

  const userId = auth.uid;
  const commentRef = db.doc(commentId); // Use the full path directly
  const likeRef = commentRef.collection("likes").doc(userId);

  return db.runTransaction(async (transaction) => {
    const likeDoc = await transaction.get(likeRef);

    if (likeDoc.exists) {
      // --- The user has already liked, so we UNLIKE ---
      transaction.delete(likeRef);
      transaction.update(commentRef, {
        likeCount: admin.firestore.FieldValue.increment(-1),
      });
      return {newLikeState: false};
    } else {
      // --- The user has NOT yet liked, so we LIKE ---
      transaction.set(likeRef, {
        likedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      transaction.update(commentRef, {
        likeCount: admin.firestore.FieldValue.increment(1),
      });
      return {newLikeState: true};
    }
  });
});

exports.deleteFeedComment = onCall(async (request) => {
  const {data, auth} = request;

  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be logged in.");
  }

  const {postId, commentId} = data;
  if (!postId || !commentId) {
    throw new HttpsError(
        "invalid-argument",
        "Post ID and Comment ID are required.",
    );
  }

  const userId = auth.uid;
  const postRef = db.collection("community_feed_posts").doc(postId);
  const commentRef = postRef.collection("comments").doc(commentId);

  return db.runTransaction(async (transaction) => {
    const commentDoc = await transaction.get(commentRef);
    if (!commentDoc.exists) {
      throw new HttpsError("not-found", "Comment not found.");
    }

    // SECURITY CHECK: You can only delete your own comments.
    if (commentDoc.data().authorId !== userId) {
      throw new HttpsError(
          "permission-denied",
          "You can only delete your own comments.",
      );
    }

    // Atomically delete the comment and decrement the post's comment count.
    transaction.delete(commentRef);
    transaction.update(postRef, {
      commentCount: admin.firestore.FieldValue.increment(-1),
    });

    return {success: true, message: "Comment deleted."};
  });
});
