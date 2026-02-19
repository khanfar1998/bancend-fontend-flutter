import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

/// Dio HTTP client with base URL and auth interceptor.
class DioClient {
  DioClient({
    required SecureStorage secureStorage,
    required String baseUrl,
  })  : _storage = secureStorage,
        _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'accept': 'application/json',
              'Content-Type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _storage.deleteAccessToken();
            // Caller can listen to 401 and navigate to login
          }
          return handler.next(error);
        },
      ),
    );
  }

  final SecureStorage _storage;
  final Dio _dio;

  Dio get dio => _dio;
}
