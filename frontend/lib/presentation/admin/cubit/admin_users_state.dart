part of 'admin_users_cubit.dart';

sealed class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];

  const factory AdminUsersState.initial() = AdminUsersInitial;
  const factory AdminUsersState.loading() = AdminUsersLoading;
  const factory AdminUsersState.loaded(List<User> users) = AdminUsersLoaded;
  const factory AdminUsersState.userDetail(User user) = AdminUsersUserDetail;
  const factory AdminUsersState.error(String message) = AdminUsersError;
}

final class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

final class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

final class AdminUsersLoaded extends AdminUsersState {
  const AdminUsersLoaded(this.users);
  final List<User> users;

  @override
  List<Object?> get props => [users];
}

final class AdminUsersUserDetail extends AdminUsersState {
  const AdminUsersUserDetail(this.user);
  final User user;

  @override
  List<Object?> get props => [user];
}

final class AdminUsersError extends AdminUsersState {
  const AdminUsersError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
