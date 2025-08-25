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
