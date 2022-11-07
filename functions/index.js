const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

exports.notifyNewMessage = functions.firestore
    .document('chats/{chat}/messages/{message}')
    .onCreate((snapshot, context) => {
        const message = snapshot.data();
        const messageText = message['text'];
        const senderName = message['senderFullName'];
        const recipientFcmTokens = message['recipientFcmTokens'];

        // functions.logger.log('Recipient FCM tokens are:', recipientFcmTokens, 'Message text is:', messageText);

        const payload = {
            notification: {
                title: senderName + ' sent you a message.',
                body: messageText
            }
        };

        return admin.messaging().sendToDevice(recipientFcmTokens, payload);
    })