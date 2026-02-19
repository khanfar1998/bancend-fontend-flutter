import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState.initial());

  final AuthRepository _authRepository;

  User? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  bool get isAuthenticated => state is AuthAuthenticated;

  Future<void> checkAuthStatus() async {
    emit(const AuthState.loading());
    try {
      final loggedIn = await _authRepository.isLoggedIn;
      if (!loggedIn) {
        emit(const AuthState.unauthenticated());
        return;
      }
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        await _authRepository.logout();
        emit(const AuthState.unauthenticated());
        return;
      }
      emit(AuthState.authenticated(user));
    } catch (_) {
      await _authRepository.logout();
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> login(String username, String password) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.login(username, password);
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('Failed to fetch user after login');
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
      rethrow;
    }
  }

  Future<void> register(String email, String username, String password) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.register(email, username, password);
      await _authRepository.login(username, password);
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('Failed to fetch user after register');
      emit(AuthState.authenticated(user));
    } catch (e) {
      emit(AuthState.error(e.toString()));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AuthState.unauthenticated());
  }

  Future<void> refreshUser() async {
    final user = await _authRepository.getCurrentUser();
    if (user != null) emit(AuthState.authenticated(user));
  }
}
