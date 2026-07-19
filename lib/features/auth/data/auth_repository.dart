import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/storage/app_storage.dart';
import '../../../shared/models/student_model.dart';

// Point this at the Render production API URL
const String _backendBaseUrl = 'https://myvault-jbd7.onrender.com/api';

// ─── Verification Exception ──────────────────────────────────────────────────
class PendingVerificationException implements Exception {
  final String collegeName;
  final String status; // 'Pending' | 'Rejected'
  final String? rejectionReason;

  PendingVerificationException({
    required this.collegeName,
    required this.status,
    this.rejectionReason,
  });

  @override
  String toString() {
    if (status == 'Rejected') {
      return 'Your registration was rejected by $collegeName.'
          '${rejectionReason != null ? ' Reason: $rejectionReason' : ''}';
    }
    return 'Your account is pending verification by $collegeName. '
        'You will be able to log in once approved.';
  }
}

// ─── OTP result wrapper (kept so UI code doesn't need to change shape) ───────
class OtpSendResult {
  final String? verificationId; // unused with Supabase but kept for UI compatibility
  final bool autoVerified;      // always false with Supabase OTP
  final String? otpPreview;     // always null in production
  const OtpSendResult({this.verificationId, this.autoVerified = false, this.otpPreview});
}

// ─── Backend Login OTP Results ──────────────────────────────────────────────
sealed class LoginResult {}

class LoginSuccess extends LoginResult {}

class LoginOtpRequired extends LoginResult {
  final String studentId;
  final String maskedMobile;
  LoginOtpRequired({required this.studentId, required this.maskedMobile});
}

/// Normalizes an Indian mobile number to E.164 (+91XXXXXXXXXX) for Supabase phone auth.
String normalizePhoneE164(String raw) {
  var digits = raw.trim().replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+')) return digits;
  if (digits.startsWith('91') && digits.length == 12) return '+$digits';
  if (digits.length == 10) return '+91$digits';
  return '+$digits';
}

bool isEmailTarget(String value) => value.contains('@');

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

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<LoginResult> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 403 &&
          data['error'] != null &&
          data['error'].toString().toLowerCase().contains('pending approval')) {
        throw PendingVerificationException(
          collegeName: data['collegeName'] ?? 'your college',
          status: 'Pending',
        );
      }

      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? 'Login failed');
      }

      if (data['requiresOtp'] == true) {
        return LoginOtpRequired(
          studentId: data['studentId'] as String,
          maskedMobile: data['maskedMobile'] as String,
        );
      }

      await _persistSession(data);
      return LoginSuccess();
    } catch (e) {
      if (e is PendingVerificationException) rethrow;
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> verifyLoginOtp({
    required String studentId,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/auth/login/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'studentId': studentId,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? 'Verification failed');
      }

      await _persistSession(data);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> resendLoginOtp({required String studentId}) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/auth/login/resend-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'studentId': studentId}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode != 200) {
        throw Exception(data['error'] ?? 'Failed to resend OTP');
      }
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
      final idCardUrl = await CloudinaryService.uploadFile(File(idCardPath));
      if (idCardUrl == null) throw Exception('Failed to upload Student ID Card.');
      final profilePicUrl = await CloudinaryService.uploadFile(File(profilePicPath));
      if (profilePicUrl == null) throw Exception('Failed to upload Profile Photo.');

      // Update temporary password set during inline verification to user's real password
      await _db.auth.updateUser(UserAttributes(password: password));

      final user = _db.auth.currentUser;
      if (user == null) throw Exception('Session expired. Please verify mobile again.');

      // Post to our Node.js backend to register the Prisma student record
      final response = await http.post(
        Uri.parse('$_backendBaseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': user.id,
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

      final data = jsonDecode(response.body);
      if (response.statusCode != 201) {
        throw Exception(data['error'] ?? 'Registration failed');
      }

      await SupabaseService.signOut();
      _ref.read(currentStudentProvider.notifier).clear();
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password-reset OTP (separate from registration above)
  // ─────────────────────────────────────────────────────────────────────────

  Future<OtpSendResult> sendOtp(String target, {String purpose = 'reset'}) async {
    try {
      if (isEmailTarget(target)) {
        await _db.auth.signInWithOtp(
          email: target.trim().toLowerCase(),
          shouldCreateUser: false,
        );
      } else {
        await _db.auth.signInWithOtp(
          phone: normalizePhoneE164(target),
          shouldCreateUser: false,
        );
      }
      return const OtpSendResult();
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit') || msg.contains('too many')) {
        throw Exception('Too many OTP requests. Please wait a minute and try again.');
      }
      if (msg.contains('not allowed') || msg.contains('not found')) {
        throw Exception('No account found for this mobile/email.');
      }
      throw Exception('Failed to send OTP: ${e.message}');
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  Future<bool> verifyOtp(
    String target,
    String otp, {
    String? verificationId,
    String purpose = 'reset',
  }) async {
    try {
      final AuthResponse response;
      if (isEmailTarget(target)) {
        response = await _db.auth.verifyOTP(
          email: target.trim().toLowerCase(),
          token: otp,
          type: OtpType.email,
        );
      } else {
        response = await _db.auth.verifyOTP(
          phone: normalizePhoneE164(target),
          token: otp,
          type: OtpType.sms,
        );
      }
      return response.session != null;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('expired')) {
        throw Exception('OTP has expired. Please request a new one.');
      }
      if (msg.contains('invalid') || msg.contains('token')) {
        return false;
      }
      throw Exception('OTP verification failed: ${e.message}');
    } catch (e) {
      return false;
    }
  }

  Future<void> resetPassword(
    String contact,
    String otp,
    String newPassword,
  ) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      throw Exception('OTP session expired. Please verify OTP again.');
    }
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
