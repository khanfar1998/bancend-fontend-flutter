import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/constants/api_constants.dart';
import 'core/network/dio_client.dart';
import 'core/storage/secure_storage.dart';
import 'data/datasources/admin_users_remote_datasource.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/admin_users_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/admin_users_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/admin/cubit/admin_users_cubit.dart';
import 'presentation/auth/cubit/auth_cubit.dart';

/// Simple service locator for dependencies.
class Injection {
  Injection._();

  static final SecureStorage _secureStorage = SecureStorageImpl(
    storage: const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  static final DioClient _dioClient = DioClient(
    secureStorage: _secureStorage,
    baseUrl: ApiConstants.baseUrl,
  );

  static AuthRepository get _authRepository => AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(
          dio: _dioClient.dio,
          secureStorage: _secureStorage,
        ),
        secureStorage: _secureStorage,
      );

  static AdminUsersRepository get _adminUsersRepository =>
      AdminUsersRepositoryImpl(
        remoteDataSource: AdminUsersRemoteDataSourceImpl(dio: _dioClient.dio),
      );

  static final AuthCubit authCubit =
      AuthCubit(authRepository: _authRepository);

  static final AdminUsersCubit adminUsersCubit =
      AdminUsersCubit(adminUsersRepository: _adminUsersRepository);
}
