import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/auth/register/register_screen.dart';
import '../../features/auth/forgot_password/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/academic_hub/academic_hub_screen.dart';
import '../../features/academic_hub/subject_detail_screen.dart';
import '../../features/results/results_screen.dart';
import '../../features/internships/internships_screen.dart';
import '../../features/internships/internship_detail_screen.dart';
import '../../features/projects/projects_screen.dart';
import '../../features/projects/project_detail_screen.dart';
import '../../features/projects/upload_project_screen.dart';
import '../../features/competitive_exams/competitive_exams_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/certificates/certificates_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/documents_hub/documents_hub_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const academicHub = '/academic-hub';
  static const subjectDetail = '/academic-hub/subject-detail';
  static const results = '/results';
  static const internships = '/internships';
  static const internshipDetail = '/internships/detail';
  static const projects = '/projects';
  static const projectDetail = '/projects/detail';
  static const uploadProject = '/projects/upload';
  static const competitiveExams = '/competitive-exams';
  static const notifications = '/notifications';
  static const certificates = '/certificates';
  static const profile = '/profile';
  static const settings = '/settings';
  static const documentsHub = '/documents-hub';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword ||
          state.matchedLocation == AppRoutes.splash;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && (state.matchedLocation == AppRoutes.login || state.matchedLocation == AppRoutes.register)) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.register, builder: (context, state) => const RegisterScreen()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (context, state) => const ForgotPasswordScreen()),
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.academicHub, builder: (context, state) => const AcademicHubScreen()),
      GoRoute(
        path: AppRoutes.subjectDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SubjectDetailScreen(
            subjectId: extra['subjectId'] as String,
            categoryName: extra['categoryName'] as String,
            dbTypes: List<String>.from(extra['dbTypes'] as List),
          );
        },
      ),
      GoRoute(path: AppRoutes.results, builder: (context, state) => const ResultsScreen()),
      GoRoute(path: AppRoutes.internships, builder: (context, state) => const InternshipsScreen()),
      GoRoute(
        path: AppRoutes.internshipDetail,
        builder: (context, state) {
          final internshipId = state.extra as String;
          return InternshipDetailScreen(internshipId: internshipId);
        },
      ),
      GoRoute(path: AppRoutes.projects, builder: (context, state) => const ProjectsScreen()),
      GoRoute(
        path: AppRoutes.projectDetail,
        builder: (context, state) {
          final projectId = state.extra as String;
          return ProjectDetailScreen(projectId: projectId);
        },
      ),
      GoRoute(path: AppRoutes.uploadProject, builder: (context, state) => const UploadProjectScreen()),
      GoRoute(path: AppRoutes.competitiveExams, builder: (context, state) => const CompetitiveExamsScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: AppRoutes.certificates, builder: (context, state) => const CertificatesScreen()),
      GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: AppRoutes.documentsHub, builder: (context, state) => const DocumentsHubScreen()),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});
