// lib/core/router/app_router.dart
//
// GoRouter setup without authentication requirement.
// Opens directly to the main Academic Hub screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/academic_hub/academic_hub_screen.dart';
import '../../features/academic_hub/subject_detail_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String notifications = '/notifications';
  static const String subjectDetail = '/subject-detail';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const AcademicHubScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const AcademicHubScreen(),
      ),
      GoRoute(
        path: '/subject-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final subjectId = extra?['subjectId'] as String? ?? '';
          final categoryName = extra?['categoryName'] as String? ?? 'Notes';
          final dbTypes = (extra?['dbTypes'] as List<dynamic>?)?.cast<String>() ?? ['notes'];
          return SubjectDetailScreen(
            subjectId: subjectId,
            categoryName: categoryName,
            dbTypes: dbTypes,
          );
        },
      ),
    ],
  );
});
