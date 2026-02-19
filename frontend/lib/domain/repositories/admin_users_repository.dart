import '../entities/user.dart';

abstract class AdminUsersRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(String userId);
  Future<User> createUser({
    required String email,
    required String username,
    required String password,
  });
  Future<User> updateUser(
    String userId, {
    String? email,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  });
  Future<void> deleteUser(String userId);
}
