import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/repositories/admin_users_repository.dart';

part 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit({required AdminUsersRepository adminUsersRepository})
    : _repo = adminUsersRepository,
      super(const AdminUsersState.initial());

  final AdminUsersRepository _repo;

  Future<void> loadUsers() async {
    emit(const AdminUsersState.loading());
    try {
      final users = await _repo.getUsers();
      emit(AdminUsersState.loaded(users));
    } catch (e) {
      emit(AdminUsersState.error(e.toString()));
    }
  }

  Future<void> loadUser(String userId) async {
    emit(const AdminUsersState.loading());
    try {
      final user = await _repo.getUserById(userId);
      emit(AdminUsersState.userDetail(user));
    } catch (e) {
      emit(AdminUsersState.error(e.toString()));
    }
  }

  Future<void> createUser({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      await _repo.createUser(
        email: email,
        username: username,
        password: password,
      );
      await loadUsers();
    } catch (e) {
      emit(AdminUsersState.error(e.toString()));
      rethrow;
    }
  }

  Future<void> updateUser(
    String userId, {
    String? email,
    String? username,
    String? password,
    String? role,
    bool? isActive,
  }) async {
    try {
      await _repo.updateUser(
        userId,
        email: email,
        username: username,
        password: password,
        role: role,
        isActive: isActive,
      );
      await loadUsers();
    } catch (e) {
      emit(AdminUsersState.error(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _repo.deleteUser(userId);
      await loadUsers();
    } catch (e) {
      emit(AdminUsersState.error(e.toString()));
      rethrow;
    }
  }

  void clearError() {
    if (state is AdminUsersError) emit(const AdminUsersState.initial());
  }
}
