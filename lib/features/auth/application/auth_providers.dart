// lib/features/auth/application/auth_providers.dart
//
// Riverpod wiring for auth: service providers + an AsyncNotifier that
// screens read for loading/error/success state and call to log in,
// register, or log out.
//
// Add to pubspec.yaml: flutter_riverpod: ^2.5.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/student_model.dart';
import '../data/auth_repository.dart';
import '../data/services/dio_client.dart';
import '../data/services/secure_storage_service.dart';

// --- Service providers ---

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(storage: ref.watch(secureStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dioClient: ref.watch(dioClientProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

// --- Auth state ---

/// Null = signed out. Non-null = signed in with this student.
class AuthController extends AsyncNotifier<Student?> {
  @override
  Future<Student?> build() async {
    // Called on app start (e.g. from the splash screen) to restore session.
    final repo = ref.watch(authRepositoryProvider);
    final hasSession = await repo.hasValidSession();
    if (!hasSession) return null;
    // NOTE: if you don't cache the student profile locally, fetch it here
    // via a `/auth/me` call. Returning null keeps new/expired sessions
    // routed to login rather than assuming a cached profile is still valid.
    return null;
  }

  Future<void> login({required String hallTicketNumber, required String password}) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repo.login(hallTicketNumber: hallTicketNumber, password: password);
      return result.student;
    });
  }

  Future<void> register(Map<String, dynamic> data) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final result = await repo.register(data);
      return result.student;
    });
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AsyncData(null);
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, Student?>(
  AuthController.new,
);

final currentStudentProvider = Provider<Student?>((ref) {
  return ref.watch(authControllerProvider).value;
});

