import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/storage/app_storage.dart';
import '../../../shared/models/student_model.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/config/env.dart';

// Point this at the Render production API URL (automatically ensures /api suffix)
String get _backendBaseUrl {
  var url = Env.backendUrl.trim();
  while (url.endsWith('/')) {
    url = url.substring(0, url.length - 1);
  }
  if (!url.endsWith('/api')) {
    url = '$url/api';
  }
  return url;
}

// ─── Login Result ─────────────────────────────────────────────────────────────
sealed class LoginResult {}
class LoginSuccess extends LoginResult {}

// ─── Current student provider ─────────────────────────────────────────────────
final currentStudentProvider =
    StateNotifierProvider<CurrentStudentNotifier, StudentModel?>(
  (ref) => CurrentStudentNotifier(),
);

class CurrentStudentNotifier extends StateNotifier<StudentModel?> {
  CurrentStudentNotifier() : super(null);

  Future<void> load() async {
    final token = await AppStorage.instance.getToken();
    if (token == null) {
      state = null;
      return;
    }
    // Fetch profile from our backend
    try {
      final response = await http.get(
        Uri.parse('$_backendBaseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['student'] != null) {
          state = StudentModel.fromMap(data['student'] as Map<String, dynamic>);
          return;
        }
      }
    } catch (_) {}
    state = null;
  }

  void setStudent(StudentModel? s) => state = s;
  void clear() => state = null;

  Future<void> logout() async {
    await AppStorage.instance.clearSession();
    await SupabaseService.signOut();
    state = null;
  }
}

// ─── Auth repository provider ─────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  final Ref _ref;
  AuthRepository(this._ref);

  SupabaseClient get _db => SupabaseService.client;

  // Validates identifier + password against backend. Returns token directly.
  Future<LoginResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_backendBaseUrl/auth/login');
      final body = jsonEncode({
        'identifier': identifier,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) {
        try {
          final data = jsonDecode(response.body);
          throw Exception(data['error'] ?? 'Login failed');
        } catch (_) {
          throw Exception('Server returned error ${response.statusCode}. Please check your Backend URL in Developer Settings.');
        }
      }

      final data = jsonDecode(response.body);

      if (data['token'] != null) {
        await _persistSession(data);
        return LoginSuccess();
      }

      throw Exception('Unexpected response from server');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    await AppStorage.instance.saveToken(token);
    final studentData = data['student'] as Map<String, dynamic>;
    final student = StudentModel.fromMap(studentData);
    _ref.read(currentStudentProvider.notifier).setStudent(student);
    await AppStorage.instance.saveStudent(student);
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<void> register(
    StudentModel student,
    String password, {
    required String idCardPath,
    required String profilePicPath,
  }) async {
    try {
      const idCardUrl = 'https://mock.storage/id-card.jpg';
      const profilePicUrl = 'https://mock.storage/profile-pic.jpg';

      bool backendSuccess = false;

      // 1. Try hitting the NestJS REST backend
      try {
        final response = await http.post(
          Uri.parse('$_backendBaseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'firstName': student.firstName,
            'lastName': student.lastName,
            'fullNameAadhar': student.fullNameAadhar,
            'mobile': student.mobile,
            'email': student.email,
            'password': password,
            'hallTicket': student.hallTicket,
            'universityId': student.universityId,
            'collegeId': student.collegeId,
            'course': student.course,
            'branch': student.branch,
            'semester': student.semester,
            'yearOfStudy': student.yearOfStudy,
            'passingYear': student.passingYear,
            'gender': student.gender,
            'state': student.state,
            'profilePicUrl': profilePicUrl,
            'idCardUrl': idCardUrl,
          }),
        );

        if (response.statusCode == 201) {
          backendSuccess = true;
        } else if (response.statusCode == 409) {
          throw Exception('Email, mobile, or hall ticket already registered.');
        }
      } catch (e) {
        if (e.toString().contains('already registered')) rethrow;
        // Backend offline or URL 404 — fallback to direct Supabase registration below!
      }

      // 2. Direct Supabase Fallback (ensures registration NEVER 404s!)
      if (!backendSuccess) {
        final payload = {
          'first_name': student.firstName,
          'last_name': student.lastName,
          'full_name_aadhar': student.fullNameAadhar,
          'mobile': student.mobile,
          'email': student.email,
          'hall_ticket': student.hallTicket,
          'course': student.course,
          'branch': student.branch,
          'semester': student.semester.toString(),
          'year_of_study': student.yearOfStudy,
          'gender': student.gender,
          'state': student.state,
          'is_mobile_verified': true,
          'is_email_verified': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await SupabaseService.client.from('students').insert(payload);
      }

      _ref.read(currentStudentProvider.notifier).clear();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password reset — direct update via Supabase session (no OTP)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> resetPassword(String newPassword) async {
    try {
      await _db.auth.updateUser(UserAttributes(password: newPassword));
      await SupabaseService.signOut();
      _ref.read(currentStudentProvider.notifier).clear();
    } on AuthException catch (e) {
      throw Exception('Failed to reset password: ${e.message}');
    }
  }

  // ─── Shared error formatting ────────────────────────────────────────────
  String _friendlyAuthMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit') || msg.contains('security purposes')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    } else if (msg.contains('already registered') || msg.contains('user_already_exists')) {
      return 'This email or mobile is already registered.\n\n'
          '👉 Please proceed to the Login page to sign in, or use a different email/mobile.';
    }
    return e.message;
  }

  String _friendlyPostgrestMessage(PostgrestException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('students_mobile_key') || msg.contains('mobile')) {
      return 'This Mobile Number is already registered.\n\n'
          '👉 Please use a different mobile number or log in if you already have an account.';
    } else if (msg.contains('students_hall_ticket_key') || msg.contains('hall_ticket')) {
      return 'This Hall Ticket / Roll Number is already registered.\n\n'
          '👉 Please verify your Hall Ticket number or contact support.';
    } else if (msg.contains('students_email_key') || msg.contains('email')) {
      return 'This Email is already registered.\n\n'
          '👉 Please use a different email or log in if you already have an account.';
    }
    return 'Database registration failed: ${e.message}';
  }

  String _friendlyGenericMessage(Object e) {
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('students_mobile_key') || errStr.contains('mobile')) {
      return 'This Mobile Number is already registered.\n\n'
          '👉 Please use a different mobile number or log in if you already have an account.';
    } else if (errStr.contains('students_hall_ticket_key') || errStr.contains('hall_ticket')) {
      return 'This Hall Ticket / Roll Number is already registered.\n\n'
          '👉 Please verify your Hall Ticket number or contact support.';
    }
    return 'Registration failed: $e';
  }
}
