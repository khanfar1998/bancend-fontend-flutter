import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AdminUsersRemoteDataSource {
  Future<List<UserModel>> getUsers();
  Future<UserModel> getUserById(String userId);
  Future<UserModel> createUser({
    required String email,
    required String username,
    required String password,
  });
  Future<UserModel> updateUser(
    String userId, {
    String? email,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  });
  Future<void> deleteUser(String userId);
}

class AdminUsersRemoteDataSourceImpl implements AdminUsersRemoteDataSource {
  AdminUsersRemoteDataSourceImpl({required this.dio});

  final Dio dio;

  @override
  Future<List<UserModel>> getUsers() async {
    final response = await dio.get<List<dynamic>>(ApiConstants.adminUsers);
    final list = response.data;
    if (list == null) return [];
    return list
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserModel> getUserById(String userId) async {
    final response = await dio.get<Map<String, dynamic>>(
      ApiConstants.adminUserById(userId),
    );
    final data = response.data;
    if (data == null) throw Exception('User not found');
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> createUser({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      ApiConstants.adminUsers,
      data: {
        'email': email,
        'username': username,
        'password': password,
      },
    );
    final data = response.data;
    if (data == null) throw Exception('Invalid create user response');
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateUser(
    String userId, {
    String? email,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (email != null) body['email'] = email;
    if (username != null) body['username'] = username;
    if (password != null) body['password'] = password;
    if (role != null) body['role'] = role;
    if (isActive != null) body['is_active'] = isActive;

    final response = await dio.patch<Map<String, dynamic>>(
      ApiConstants.adminUserById(userId),
      data: body,
    );
    final data = response.data;
    if (data == null) throw Exception('Invalid update user response');
    return UserModel.fromJson(data);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await dio.delete(ApiConstants.adminUserById(userId));
  }
}
