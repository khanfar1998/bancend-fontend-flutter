import 'package:flutter/foundation.dart';

/// API base URL and endpoint paths.
/// - Android emulator: 10.0.2.2 (127.0.0.1 is the emulator itself).
/// - Physical device: set [overrideBaseUrl] in main() to your machine's IP, e.g. http://192.168.1.5:8000/api/v1
class ApiConstants {
  ApiConstants._();

  /// Set in main() to use a custom host (e.g. your machine's IP when testing on a physical device).
  static String? overrideBaseUrl;

  static String get baseUrl {
    if (overrideBaseUrl != null) return overrideBaseUrl!;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  // Auth
  static const String login = '/auth/login'; // backend
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Admin
  static const String adminUsers = '/admin/users';
  static String adminUserById(String id) => '/admin/users/$id';

  // Storage keys
  static const String accessTokenKey = 'access_token';
}
