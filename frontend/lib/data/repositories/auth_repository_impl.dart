import '../../core/storage/secure_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorage secureStorage,
  })  : _remote = remoteDataSource,
        _storage = secureStorage;

  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;

  @override
  Future<void> login(String username, String password) =>
      _remote.login(username, password);

  @override
  Future<User> register(String email, String username, String password) async {
    final userModel = await _remote.register(email, username, password);
    return userModel.toEntity();
  }

  @override
  Future<User?> getCurrentUser() async {
    final model = await _remote.getMe();
    return model?.toEntity();
  }

  @override
  Future<void> logout() => _storage.deleteAccessToken();

  @override
  Future<bool> get isLoggedIn async {
    final token = await _storage.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
