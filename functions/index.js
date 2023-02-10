const functions = require('firebase-functions');
const firebase_tools = require('firebase-tools');
const admin = require('firebase-admin');

admin.initializeApp()

exports.notifyNewMessage = functions.firestore
    .document('chats/{chat}/messages/{message}')
    .onCreate((snapshot, context) => {
        const message = snapshot.data();
        const messageText = message['text'];
        const senderName = message['senderFullName'];
        const recipientFcmTokens = message['recipientFcmTokens'];

        functions.logger.log('Recipient FCM tokens are:', recipientFcmTokens, 'Message text is:', messageText);

        const payload = {
            notification: {
                title: `${senderName} sent you a message.`,
                body: messageText
            },
            data: {
                senderName: senderName
            }
        };

        return admin.messaging().sendToDevice(recipientFcmTokens, payload);
    })

exports.notifyNewNotification = functions.firestore
    .document('users/{user}/notifications/{notification}')
    .onCreate((snapshot, context) => {
        const notification = snapshot.data();
        const message = notification['message'];
        const notificationType = notification['notificationType']
        const recipientFcmToken = notification['recipientFcmToken'];

        functions.logger.log('Recipient FCM token is:', recipientFcmToken, 'Notification message is:', message);

        const payload = {
            notification: {
                title: `New ${notificationType}`,
                body: message
            },
            data: {
                openNotificationsTab: 'true'
            }
        };

        return admin.messaging().sendToDevice(recipientFcmToken, payload);
    })

exports.recursiveDelete = functions
    .runWith({
        timeoutSeconds: 540,
        memory: '2GB'
    })
    .https.onCall(async (data, context) => {
        const path = data.path;
        functions.logger.log('Starting delete at path', path);
        
        await firebase_tools.firestore
            .delete(path, {
                project: "the-same-page-9c69e",
                recursive: true,
                force: true,
                token: functions.config().fb.token
            });
            
        return {
            path: path
        };
    });