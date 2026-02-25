


import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
const String _channelId = 'high_importance_channel';

final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
class FirebaseFcmConfig {

  Future<void> initConfig() async {
    final fmc = await FirebaseMessaging.instance;
    await _initLocalNotifications();
    final notificationSettings = fmc.requestPermission(provisional: true,sound: false);
    final token =  await fmc.getToken();//device token
    print(token);
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
            playSound: false,
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
    final title = "${message.notification?.title} + khanfarfasdasfd"  '' ?? 'New message';
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

}
