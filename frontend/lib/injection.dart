import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

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

final GetIt sl = GetIt.instance;

Future<void> setupInjection() async {

  // Core
  sl.registerLazySingleton<SecureStorage>(
      ()=>SecureStorageImpl(
    storage: const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true)
    ),
      )
  );
  sl.registerLazySingleton<DioClient>(
      ()=>DioClient(secureStorage: sl<SecureStorage>(), baseUrl: ApiConstants.baseUrl)
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<DioClient>().dio,
      secureStorage: sl<SecureStorage>(),
    ),
  );

  sl.registerLazySingleton<AdminUsersRemoteDataSource>(
    () => AdminUsersRemoteDataSourceImpl(dio: sl<DioClient>().dio),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  sl.registerLazySingleton<AdminUsersRepository>(
    () => AdminUsersRepositoryImpl(
      remoteDataSource: sl<AdminUsersRemoteDataSource>(),
    ),
  );

  // Cubits (singleton so auth state is shared app-wide)
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(authRepository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<AdminUsersCubit>(
    () => AdminUsersCubit(adminUsersRepository: sl<AdminUsersRepository>()),
  );
}
