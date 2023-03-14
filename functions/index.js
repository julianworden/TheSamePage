const functions = require('firebase-functions');
const firebase_tools = require('firebase-tools');
const admin = require('firebase-admin');

admin.initializeApp()

exports.notifyNewMessage = functions.firestore
    .document('chats/{chat}/messages/{message}')
    .onCreate((snapshot, context) => {
        const message = snapshot.data();
        const chatId = message['chatId'];
        const messageText = message['text'];
        const recipientFcmTokens = message['recipientFcmTokens'];
        const chatType = message['chatType'];
        const chatName = message['chatName'];
        const senderUsername = message['senderUsername'];
        var newMessageNotificationTitle;
        var newMessageNotificationBody;

        if (chatType === 'Show') {
            newMessageNotificationTitle = `New Message in ${chatName}.`;
            newMessageNotificationBody = `${senderUsername}: ${messageText}`;
        } else if (chatType === 'One on One') {
            newMessageNotificationTitle = `New Message from ${senderUsername}.`;
            newMessageNotificationBody = messageText;
        }

        functions.logger.log('Recipient FCM tokens are:', recipientFcmTokens, 'Message text is:', messageText);

        const payload = {
            notification: {
                title: newMessageNotificationTitle,
                body: newMessageNotificationBody
            },
            data: {
                chatId: chatId
            }
        };

        return admin.messaging().sendToDevice(recipientFcmTokens, payload);
    })

exports.notifyNewNotification = functions.firestore
    .document('users/{user}/notifications/{notification}')
    .onCreate((snapshot, context) => {
        const notification = snapshot.data();
        const message = notification['message'];
        const notificationType = notification['notificationType'];
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

exports.notifyAcceptedBandInvite = functions
    .runWith({
        timeoutSeconds: 540,
        memory: '2GB'
    })
    .https.onCall(async (data, context) => {
        const recipientFcmToken = data.recipientFcmToken;
        const message = data.message;
        const bandId = data.bandId;

        functions.logger.log('Sending notification with message', message, 'to user with FCM token', recipientFcmToken);
        
        const payload = {
            notification: {
                title: 'Band Invite Accepted',
                body: `${message}`
            },
            data: {
                bandId: bandId
            }
        };

        return admin.messaging().sendToDevice(recipientFcmToken, payload);
    });

exports.notifyAcceptedShowInvite = functions
    .runWith({
        timeoutSeconds: 540,
        memory: '2GB'
    })
    .https.onCall(async (data, context) => {
        const recipientFcmToken = data.recipientFcmToken;
        const message = data.message;
        const showId = data.showId;

        functions.logger.log('Sending notification with message', message, 'to user with FCM token', recipientFcmToken);
        
        const payload = {
            notification: {
                title: 'Show Invite Accepted',
                body: `${message}`
            },
            data: {
                showId: showId
            }
        };

        return admin.messaging().sendToDevice(recipientFcmToken, payload);
    });

exports.notifyAcceptedShowApplication = functions
    .runWith({
        timeoutSeconds: 540,
        memory: '2GB'
    })
    .https.onCall(async (data, context) => {
        const recipientFcmToken = data.recipientFcmToken;
        const message = data.message;
        const showId = data.showId;

        functions.logger.log('Sending notification with message', message, 'to user with FCM token', recipientFcmToken);
        
        const payload = {
            notification: {
                title: 'Show Application Accepted',
                body: `${message}`
            },
            data: {
                showId: showId
            }
        };

        return admin.messaging().sendToDevice(recipientFcmToken, payload);
    });

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
