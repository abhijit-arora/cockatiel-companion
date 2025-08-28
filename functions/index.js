const {onCall, HttpsError} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

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
