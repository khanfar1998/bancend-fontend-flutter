import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.role,
    required this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      role: json['role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  final String id;
  final String email;
  final String username;
  final String role;
  final bool isActive;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'role': role,
        'is_active': isActive,
      };

  User toEntity() => User(
        id: id,
        email: email,
        username: username,
        role: role,
        isActive: isActive,
      );

  @override
  List<Object?> get props => [id, email, username, role, isActive];
}
