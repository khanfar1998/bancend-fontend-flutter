import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String username, String password);
  Future<UserModel> register(String email, String username, String password);
  Future<UserModel?> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  final Dio dio;
  final SecureStorage secureStorage;

  @override
  Future<void> login(String username, String password) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'username': username, 'password': password},
    );
    final data = response.data;
    if (data == null) throw Exception('Invalid login response');
    final token = data['access_token'] as String?;
    if (token == null || token.isEmpty) throw Exception('No access token');
    await secureStorage.setAccessToken(token);
  }

  @override
  Future<UserModel> register(String email, String username, String password) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'email': email,
        'username': username,
        'password': password,
      },
    );
    final data = response.data;
    if (data == null) throw Exception('Invalid register response');
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel?> getMe() async {
    final response = await dio.get<Map<String, dynamic>>(ApiConstants.me);
    if (response.statusCode == 401) return null; // Token expired or invalid
    final data = response.data;
    if (data == null) return null;
    return UserModel.fromJson(data);
  }
}
