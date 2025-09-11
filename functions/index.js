const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

setGlobalOptions({ region: "asia-south1" });

exports.sendNotificationToNGOAdmins = onDocumentCreated(
  "reports/{reportId}",
  async (event) => {
    const reportData = event.data.data();
    const description = reportData.description || "A new report was submitted.";
    const reportId = event.params.reportId;

    try {
      // 1️⃣ Get all NGO admin users
      const ngoAdminsSnapshot = await db
        .collection("users")
        .where("role", "==", "ngo_admin")
        .get();

      const tokens = [];
      ngoAdminsSnapshot.forEach((doc) => {
        const fcmToken = doc.get("fcmToken");
        if (fcmToken) tokens.push(fcmToken);
      });

      if (tokens.length === 0) {
        console.log("No NGO admin tokens found.");
        return null;
      }

      // 2️⃣ Prepare notification
      const message = {
        notification: {
          title: "New Incident Report",
          body: description,
        },
        data: {
          reportId,
        },
        tokens,
      };

      // 3️⃣ Send notifications
      const response = await admin.messaging().sendMulticast(message);
      console.log("Notifications sent:", response.successCount);

      // 4️⃣ Clean invalid tokens
      response.responses.forEach((res, idx) => {
        if (!res.success) {
          console.log("Removing invalid token:", tokens[idx]);
          db.collection("users")
            .where("fcmToken", "==", tokens[idx])
            .get()
            .then((snapshot) => {
              snapshot.forEach((doc) =>
                doc.ref.update({ fcmToken: admin.firestore.FieldValue.delete() })
              );
            });
        }
      });

      return null;
    } catch (error) {
      console.error("Error sending notifications:", error);
      return null;
    }
  }
);
