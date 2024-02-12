const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
exports.myFunction = functions.firestore
  .document("chats/{messageId}")
  .onCreate((snapshot, context) => {
    return admin.messaging().sendToTopic("chatMessages", {
      notification: {
        title: snapshot.data()["username"],
        body: snapshot.data()["message"],
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    });
  });