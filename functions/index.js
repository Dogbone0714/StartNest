const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// 發送推播通知的函數
exports.sendPushNotification = functions.https.onCall(async (data, context) => {
  try {
    const { title, body, topic, data: notificationData } = data;
    
    // 驗證必要參數
    if (!title || !body || !topic) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        '缺少必要參數：title, body, topic'
      );
    }

    // 構建消息
    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: notificationData || {},
      topic: topic,
    };

    // 發送推播通知
    const response = await admin.messaging().send(message);
    
    // 更新通知狀態
    const db = admin.database();
    const notificationRef = db.ref('notifications');
    
    // 查找對應的通知記錄並更新狀態
    const notificationsSnapshot = await notificationRef
      .orderByChild('title')
      .equalTo(title)
      .once('value');
    
    if (notificationsSnapshot.exists()) {
      const updates = {};
      notificationsSnapshot.forEach((childSnapshot) => {
        const notification = childSnapshot.val();
        if (notification.body === body && notification.topic === topic) {
          updates[`${childSnapshot.key}/status`] = 'sent';
          updates[`${childSnapshot.key}/sent_at`] = new Date().toISOString();
          updates[`${childSnapshot.key}/message_id`] = response;
        }
      });
      
      if (Object.keys(updates).length > 0) {
        await notificationRef.update(updates);
      }
    }

    return {
      success: true,
      messageId: response,
      message: '推播通知發送成功'
    };
  } catch (error) {
    console.error('發送推播通知失敗:', error);
    
    // 更新通知狀態為失敗
    try {
      const db = admin.database();
      const notificationRef = db.ref('notifications');
      
      const notificationsSnapshot = await notificationRef
        .orderByChild('title')
        .equalTo(data.title)
        .once('value');
      
      if (notificationsSnapshot.exists()) {
        const updates = {};
        notificationsSnapshot.forEach((childSnapshot) => {
          const notification = childSnapshot.val();
          if (notification.body === data.body && notification.topic === data.topic) {
            updates[`${childSnapshot.key}/status`] = 'failed';
            updates[`${childSnapshot.key}/error`] = error.message;
          }
        });
        
        if (Object.keys(updates).length > 0) {
          await notificationRef.update(updates);
        }
      }
    } catch (updateError) {
      console.error('更新通知狀態失敗:', updateError);
    }
    
    throw new functions.https.HttpsError(
      'internal',
      '發送推播通知失敗: ' + error.message
    );
  }
});

// 監聽新通知並自動發送
exports.processPendingNotifications = functions.database
  .ref('/notifications/{notificationId}')
  .onCreate(async (snapshot, context) => {
    const notification = snapshot.val();
    
    // 只處理狀態為pending的通知
    if (notification.status !== 'pending') {
      return null;
    }

    try {
      const { title, body, topic, data: notificationData } = notification;
      
      // 構建消息
      const message = {
        notification: {
          title: title,
          body: body,
        },
        data: notificationData || {},
        topic: topic,
      };

      // 發送推播通知
      const response = await admin.messaging().send(message);
      
      // 更新通知狀態
      await snapshot.ref.update({
        status: 'sent',
        sent_at: new Date().toISOString(),
        message_id: response,
      });

      return { success: true, messageId: response };
    } catch (error) {
      console.error('處理推播通知失敗:', error);
      
      // 更新通知狀態為失敗
      await snapshot.ref.update({
        status: 'failed',
        error: error.message,
      });

      return { success: false, error: error.message };
    }
  });

// 用戶註冊時自動訂閱主題
exports.subscribeUserToTopics = functions.database
  .ref('/users/{userId}')
  .onCreate(async (snapshot, context) => {
    const user = snapshot.val();
    const userId = context.params.userId;
    
    try {
      // 根據用戶角色訂閱相應主題
      const topics = ['all']; // 所有用戶都訂閱all主題
      
      if (user.role === '住戶') {
        topics.push('residents');
      } else if (user.role === '管理員') {
        topics.push('admin');
      }
      
      // 訂閱主題
      for (const topic of topics) {
        await admin.messaging().subscribeToTopic([userId], topic);
      }
      
      console.log(`用戶 ${userId} 已訂閱主題: ${topics.join(', ')}`);
      return { success: true, topics };
    } catch (error) {
      console.error('訂閱主題失敗:', error);
      return { success: false, error: error.message };
    }
  });

// 用戶更新FCM Token時處理
exports.updateUserFcmToken = functions.database
  .ref('/users/{userId}/fcm_token')
  .onWrite(async (change, context) => {
    const newToken = change.after.val();
    const oldToken = change.before.val();
    const userId = context.params.userId;
    
    if (!newToken || newToken === oldToken) {
      return null;
    }
    
    try {
      // 獲取用戶信息
      const userSnapshot = await admin.database()
        .ref(`/users/${userId}`)
        .once('value');
      
      const user = userSnapshot.val();
      if (!user) {
        return null;
      }
      
      // 根據用戶角色訂閱相應主題
      const topics = ['all'];
      
      if (user.role === '住戶') {
        topics.push('residents');
      } else if (user.role === '管理員') {
        topics.push('admin');
      }
      
      // 訂閱主題
      for (const topic of topics) {
        await admin.messaging().subscribeToTopic([newToken], topic);
      }
      
      console.log(`用戶 ${userId} 的FCM Token已更新並重新訂閱主題`);
      return { success: true, topics };
    } catch (error) {
      console.error('更新FCM Token失敗:', error);
      return { success: false, error: error.message };
    }
  }); 