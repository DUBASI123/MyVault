// lib/core/router/app_router.dart
//
// GoRouter setup for the auth flow. Redirect logic reads authControllerProvider:
//  - while it's loading  -> stay on /splash
//  - signed out -> redirect to /login if on splash or protected route
//  - signed in  -> redirect to /home if on an auth route (/splash, /login, /register)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:myvault_app/features/auth/application/auth_providers.dart';
import 'package:myvault_app/features/auth/presentation/splash_screen.dart';
import 'package:myvault_app/features/auth/presentation/login_screen.dart';
import 'package:myvault_app/features/auth/presentation/registration_screen.dart';
import 'package:myvault_app/features/auth/presentation/developer_settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _AuthRefreshNotifier(ref),
    redirect: (context, state) {
      final loggedIn = authState.value != null;
      final isLoading = authState.isLoading;
      final loc = state.matchedLocation;

      // 1. Stay on splash while loading session state
      if (isLoading) {
        return loc == '/splash' ? null : '/splash';
      }

      // 2. If NOT logged in, route to /login if currently on splash or any protected route
      if (!loggedIn) {
        if (loc == '/login' || loc == '/register' || loc == '/dev-settings') {
          return null;
        }
        return '/login';
      }

      // 3. If LOGGED IN, redirect away from auth routes to /home
      if (loggedIn) {
        final onAuthRoute = loc == '/splash' || loc == '/login' || loc == '/register';
        if (onAuthRoute) {
          return '/home';
        }
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),
      GoRoute(path: '/dev-settings', builder: (_, __) => const DeveloperSettingsScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreenStub()),
    ],
  );
});

/// Bridges Riverpod state changes into something GoRouter's
/// `refreshListenable` can listen to, so redirect() re-runs on auth changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

/// Placeholder — swap for your real home/dashboard screen.
class HomeScreenStub extends ConsumerWidget {
  const HomeScreenStub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(authControllerProvider).value;
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Text(
          student != null ? 'Welcome, ${student.fullName}' : 'Welcome',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
