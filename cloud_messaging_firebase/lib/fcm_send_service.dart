import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

/// Sends FCM messages using the service account JSON from assets.
///
/// **Security note:** Embedding the service account key in the app is not
/// recommended for production. Prefer a backend server that holds the key
/// and exposes an API for sending notifications.
class FcmSendService {
  FcmSendService._();

  static const String _assetPath = 'assets/money-manager-3a90b-4e8cb1c3d14d.json';
  static const String _fcmScope = 'https://www.googleapis.com/auth/firebase.messaging';
  // 'auth/login'

  static Map<String, dynamic>? _cachedJson;
  static ServiceAccountCredentials? _cachedCredentials;

  static Future<Map<String, dynamic>> _loadJson() async {
    _cachedJson ??= jsonDecode(
      await rootBundle.loadString(_assetPath),
    ) as Map<String, dynamic>;
    return _cachedJson!;
  }

  static Future<ServiceAccountCredentials> _getCredentials() async {
    if (_cachedCredentials != null) return _cachedCredentials!;
    final json = await _loadJson();
    _cachedCredentials = ServiceAccountCredentials.fromJson(json);
    return _cachedCredentials!;
  }

  /// Project ID from the service account JSON (e.g. for FCM URL).
  static Future<String> get projectId async {
    final json = await _loadJson();
    final id = json['project_id'] as String?;
    if (id == null || id.isEmpty) {
      throw StateError('project_id missing in $_assetPath');
    }
    return id;
  }

  /// Sends an FCM message to the given [deviceToken].
  /// [title] and [body] are the notification title and body.
  static Future<void> send({
    required String deviceToken,
    String title = 'Test',
    String body = 'Sent from Flutter FCM service',
    Map<String, String>? data,
  }) async {
    final credentials = await _getCredentials();
    final project = await projectId;
    final baseClient = http.Client();
    try {
      final authClient = await clientViaServiceAccount(
        credentials,
        [_fcmScope],
        baseClient: baseClient,
      );
      try {
        final url = Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$project/messages:send',
        );
        final payload = <String, dynamic>{
          'message': <String, dynamic>{
            'token': 'fTeMRaulQcem-NG33dwos_:APA91bETHK8-JYanq0aVkwUlC5ZWdrdAIUBqYKs4Mso-aB7Dl2m4UtFKK2hl7r8rL2EV7uZcNORkafBtEhXQ7gbGtmz57EVptEKqL0-LUD_-EN2LPHpGQw0',
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'android': <String, dynamic>{
              'priority': 'high',
              'notification': <String, dynamic>{
                'channel_id': 'high_importance_channel',
              },
            },
            if (data != null && data.isNotEmpty) 'data': data,
          },
        };
        final response = await authClient.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );
        if (response.statusCode != 200) {
          throw FcmSendException(
            response.statusCode,
            response.body,
          );
        }
      } finally {
        authClient.close();
      }
    } finally {
      baseClient.close();
    }
  }
}

class FcmSendException implements Exception {
  FcmSendException(this.statusCode, this.body);
  final int statusCode;
  final String body;
  @override
  String toString() => 'FcmSendException($statusCode): $body';
}
