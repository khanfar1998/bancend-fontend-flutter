import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

/// Dio HTTP client with base URL and auth interceptor.
/// On 401 we clear the token and pass the response to the caller (no exception),
/// so callers can check [Response.statusCode] and handle "session expired" cleanly.
class DioClient {
  final SecureStorage _storage;
  final Dio _dio;

  Dio get dio => _dio;

  DioClient({required SecureStorage secureStorage, required String baseUrl})
      : _storage = secureStorage,
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
            // Resolve with the 401 response instead of throwing (caller checks statusCode)
            return handler.resolve(error.response!);
          }
          return handler.next(error);
        },
      ),
    );
  }

}
