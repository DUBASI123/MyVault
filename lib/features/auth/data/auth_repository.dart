// lib/features/auth/data/auth_repository.dart
//
// Talks to the NestJS backend's /auth endpoints. Registration is
// self-contained (no OTP step, no admin-approval step) — a successful
// POST to /auth/register returns a token immediately, same shape as login.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/student_model.dart';
import 'services/dio_client.dart';
import 'services/secure_storage_service.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({required DioClient dioClient, required SecureStorageService storage})
      : _dio = dioClient.dio,
        _storage = storage;

  final Dio _dio;
  final SecureStorageService _storage;

  Future<AuthResult> login({
    required String hallTicketNumber,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'hallTicketNumber': hallTicketNumber,
        'password': password,
      });
      final result = AuthResult.fromJson(response.data as Map<String, dynamic>);
      await _storage.saveToken(result.token);
      return result;
    } on DioException catch (e) {
      throw AuthException(_messageFor(e, fallback: 'Login failed. Check your hall ticket number and password.'));
    }
  }

  Future<AuthResult> register(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/auth/register', data: data);
      final result = AuthResult.fromJson(response.data as Map<String, dynamic>);
      await _storage.saveToken(result.token);
      return result;
    } on DioException catch (e) {
      throw AuthException(_messageFor(e, fallback: 'Could not create your account. Please try again.'));
    }
  }

  Future<void> logout() async {
    await _storage.clearToken();
  }

  Future<bool> hasValidSession() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }

  String _messageFor(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) return data['message'] as String;
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return 'Could not reach the server. Check your connection and try again.';
    }
    return fallback;
  }
}

final currentStudentProvider = Provider<Student?>((ref) {
  return null;
});

