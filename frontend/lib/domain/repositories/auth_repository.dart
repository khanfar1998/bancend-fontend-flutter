import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> login(String username, String password);
  Future<User> register(String email, String username, String password);
  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<bool> get isLoggedIn;
}
