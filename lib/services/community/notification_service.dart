import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  String? _fcmToken;
  bool _isInitialized = false;

  // 獲取FCM Token
  String? get fcmToken => _fcmToken;

  // 初始化通知服務
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 請求通知權限
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('用戶已授權通知權限');
      } else {
        print('用戶拒絕通知權限');
        return;
      }

      // 獲取FCM Token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // 保存Token到本地
      if (_fcmToken != null) {
        await _saveFcmToken(_fcmToken!);
      }

      // 監聽Token更新
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _saveFcmToken(newToken);
        print('FCM Token已更新: $newToken');
      });

      // 設置前台消息處理
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 設置後台消息處理
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 設置點擊通知處理
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // 檢查應用是否從通知啟動
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
    } catch (e) {
      print('初始化通知服務失敗: $e');
    }
  }

  // 保存FCM Token到本地
  Future<void> _saveFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  // 獲取保存的FCM Token
  Future<String?> getSavedFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  // 處理前台消息
  void _handleForegroundMessage(RemoteMessage message) {
    print('收到前台消息: ${message.messageId}');
    // 前台收到消息時，可以顯示一個簡單的SnackBar或Dialog
    _showForegroundNotification(message);
  }

  // 處理通知點擊
  void _handleNotificationTap(RemoteMessage message) {
    print('用戶點擊了通知: ${message.messageId}');
    // 這裡可以添加導航邏輯
    _handleNotificationAction(message);
  }

  // 處理通知動作
  void _handleNotificationAction(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'announcement':
        // 導航到公告詳情
        print('導航到公告: $id');
        break;
      case 'maintenance':
        // 導航到維修詳情
        print('導航到維修請求: $id');
        break;
      case 'invitation':
        // 導航到邀請碼
        print('導航到邀請碼管理');
        break;
      default:
        print('未知的通知類型: $type');
    }
  }

  // 顯示前台通知（使用SnackBar）
  void _showForegroundNotification(RemoteMessage message) {
    // 這裡可以使用全局的ScaffoldMessenger來顯示SnackBar
    // 或者使用其他方式來顯示前台通知
    print('前台通知: ${message.notification?.title} - ${message.notification?.body}');
  }

  // 訂閱主題
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('已訂閱主題: $topic');
  }

  // 取消訂閱主題
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('已取消訂閱主題: $topic');
  }

  // 發送推播通知（管理員功能）
  static Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String body,
    required String topic,
    Map<String, dynamic>? data,
  }) async {
    try {
      // 這裡需要調用你的後端API來發送推播
      // 或者直接使用Firebase Admin SDK
      final result = await FirebaseService.sendPushNotification(
        title: title,
        body: body,
        topic: topic,
        data: data,
      );
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': '發送推播通知失敗: $e',
      };
    }
  }

  // 獲取通知設置
  Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }
}

// 後台消息處理器
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('收到後台消息: ${message.messageId}');
  // 這裡可以添加後台處理邏輯
} 