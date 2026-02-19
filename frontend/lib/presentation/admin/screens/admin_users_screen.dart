import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../cubit/admin_users_cubit.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AdminUsersCubit>().loadUsers();
  }

  Future<void> _confirmDelete(BuildContext context, User user) async {
    final cubit = context.read<AdminUsersCubit>();
    final messenger = ScaffoldMessenger.maybeOf(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete user'),
        content: Text(
          'Delete "${user.username}" (${user.email})? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await cubit.deleteUser(user.id);
      if (mounted && messenger != null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('User deleted')),
        );
      }
    } catch (_) {
      if (mounted && messenger != null) {
        final message = cubit.state is AdminUsersError
            ? (cubit.state as AdminUsersError).message
            : 'Failed to delete user';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AdminUsersCubit, AdminUsersState>(
        listener: (context, state) {
          if (state is AdminUsersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () =>
                      context.read<AdminUsersCubit>().clearError(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminUsersLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminUsersLoaded) {
            final users = state.users;
            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No users yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  context.read<AdminUsersCubit>().loadUsers(),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.username.isNotEmpty
                          ? user.username[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(user.username),
                    subtitle: Text(user.email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(
                            user.role,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        if (!user.isActive)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.block_rounded,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.of(context).pushNamed(
                                '/admin/users/edit',
                                arguments: user,
                              );
                            } else if (value == 'delete') {
                              _confirmDelete(context, user);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 20),
                                  SizedBox(width: 12),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_rounded,
                                      size: 20, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => Navigator.of(context).pushNamed(
                      '/admin/users/edit',
                      arguments: user,
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed('/admin/users/create'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
