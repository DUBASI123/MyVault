// lib/features/auth/presentation/splash_screen.dart
//
// Auth gate: shown while AuthController.build() checks for a stored token.
// Routes to /home if a session is restored, otherwise /login.
// GoRouter's `redirect` (see router/app_router.dart) does the actual
// navigation once authControllerProvider settles — this screen just
// renders the loading moment.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/auth_providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching this triggers build() → session check → router redirect.
    ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: Stack(
        children: [
          Positioned(
            top: -140,
            left: -120,
            child: _blob(const Color(0xFF3E7BFF)),
          ),
          Positioned(
            bottom: -160,
            right: -100,
            child: _blob(const Color(0xFF00D9F5)),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(colors: [Color(0xFF3E7BFF), Color(0xFF00D9F5)]),
                    boxShadow: [BoxShadow(color: const Color(0xFF00B4FF).withOpacity(0.35), blurRadius: 36)],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🎓', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(height: 18),
                const Text('MyVault', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 24),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF7FB4FF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color) => Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withOpacity(0.35), Colors.transparent]),
        ),
      );
}
