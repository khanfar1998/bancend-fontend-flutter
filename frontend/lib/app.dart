import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'domain/entities/user.dart';
import 'injection.dart';
import 'presentation/admin/cubit/admin_users_cubit.dart';
import 'presentation/admin/screens/admin_user_form_screen.dart';
import 'presentation/admin/screens/admin_users_screen.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/auth/screens/login_screen.dart';
import 'presentation/auth/screens/register_screen.dart';
import 'presentation/home/screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: sl<AuthCubit>()),
        BlocProvider<AdminUsersCubit>.value(value: sl<AdminUsersCubit>()),
      ],
      child: MaterialApp(
        title: 'Auth App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const _SplashRouter(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
          '/admin/users': (context) => const AdminUsersScreen(),
          '/admin/users/create': (context) =>
              const AdminUserFormScreen(),
          '/admin/users/edit': (context) {
            final user = ModalRoute.of(context)!.settings.arguments as User?;
            return AdminUserFormScreen(user: user);
          },
        },
      ),
    );
  }
}

/// Shows loading while checking auth, then redirects to /home or /login.
class _SplashRouter extends StatefulWidget {
  const _SplashRouter();

  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else if (state is AuthUnauthenticated || state is AuthError) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
