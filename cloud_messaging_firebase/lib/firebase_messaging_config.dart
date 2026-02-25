import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Channel ID used for FCM and local notifications. Must match
/// AndroidManifest meta-data com.google.firebase.messaging.default_notification_channel_id
const String _channelId = 'high_importance_channel';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling background message: ${message.messageId}');
  if (message.notification != null) {
    print('Background notification: ${message.notification!.title} - ${message.notification!.body}');
  }
  if (message.data.isNotEmpty) {
    print('Background data: ${message.data}');
  }

}

class FirebaseMessagingConfig {
  Future<void> initConfig() async {
    final messaging = FirebaseMessaging.instance;

    await _initLocalNotifications();

    // iOS: show notification when app is in foreground (alert, sound, badge)
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        sound: true,
        badge: true,
      );
    }

    final notificationSettings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    print('Notification permission: ${notificationSettings.authorizationStatus}');

    final token = await messaging.getToken();
    print('FCM token: $token');
    if (token != null) {
      // Send token to your server for targeting this device
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //app opend
      print('Foreground message: ${message.messageId}');
      if (message.notification != null) {
        print('  title: ${message.notification!.title}');
        print('  body: ${message.notification!.body}');
      }
      if (message.data.isNotEmpty) {
        print('  data: ${message.data}');
      }
      _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      //when cleicl
      print('Opened app from background notification: ${message.messageId}');
      _handleMessageOpened(message);
    });

    // App was terminated and opened from notification
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('Opened app from terminated state via notification: ${initialMessage.messageId}');
      _handleMessageOpened(initialMessage);
    }
  }

  Future<void> _initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false, // we request via FCM
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android: create high-priority channel and request permission (Android 13+)
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            'High Importance Notifications',
            description: 'Used for FCM messages',
            importance: Importance.high,
            playSound: true,
          ),
        );
      }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null && response.payload!.isNotEmpty) {
      print('Notification tapped with payload: ${response.payload}');
    }
  }

  void _showNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'New message';
    final body = message.notification?.body ?? '';
    final id = message.hashCode & 0x7FFFFFFF; // positive int

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'High Importance Notifications',
      channelDescription: 'Used for FCM messages',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    _localNotifications.show(id, title, body, details);
  }

  void _handleMessageOpened(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      print('  payload: ${message.data}');
      // e.g. navigate: if (message.data['type'] == 'chat') Navigator.pushNamed(context, '/chat', ...);
    }
  }

  static Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'High Importance Notifications',
      channelDescription: 'Used for FCM messages',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF),
      'Test notification',
      'Sent from in-app example at ${DateTime.now().toString().substring(11, 19)}',
      details,
    );
  }
}
