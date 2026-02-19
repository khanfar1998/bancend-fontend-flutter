import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';

/// Secure storage for access token (Flutter Secure Storage).
abstract class SecureStorage {
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String token);
  Future<void> deleteAccessToken();
  Future<void> clear();
}

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getAccessToken() =>
      _storage.read(key: ApiConstants.accessTokenKey);

  @override
  Future<void> setAccessToken(String token) =>
      _storage.write(key: ApiConstants.accessTokenKey, value: token);

  @override
  Future<void> deleteAccessToken() =>
      _storage.delete(key: ApiConstants.accessTokenKey);

  @override
  Future<void> clear() => _storage.deleteAll();
}
