import '../../domain/entities/user.dart';
import '../../domain/repositories/admin_users_repository.dart';
import '../datasources/admin_users_remote_datasource.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  AdminUsersRepositoryImpl({
    required AdminUsersRemoteDataSource remoteDataSource,
  }) : _remote = remoteDataSource;

  final AdminUsersRemoteDataSource _remote;

  @override
  Future<List<User>> getUsers() async {
    final models = await _remote.getUsers();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<User> getUserById(String userId) async {
    final model = await _remote.getUserById(userId);
    return model.toEntity();
  }

  @override
  Future<User> createUser({
    required String email,
    required String username,
    required String password,
  }) async {
    final model = await _remote.createUser(
      email: email,
      username: username,
      password: password,
    );
    return model.toEntity();
  }

  @override
  Future<User> updateUser(
    String userId, {
    String? email,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    final model = await _remote.updateUser(
      userId,
      email: email,
      username: username,
      password: password,
      role: role,
      isActive: isActive,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteUser(String userId) => _remote.deleteUser(userId);
}
