import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/cloudinary_service.dart';
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
    final user = SupabaseService.currentUser;
    if (user == null) {
      state = null;
      return;
    }
    final row = await SupabaseService.client
        .from('students')
        .select('*, universities(name), colleges(name, logo_url)')
        .eq('id', user.id)
        .maybeSingle();
    if (row != null) state = StudentModel.fromMap(row);
  }

  void setStudent(StudentModel? s) => state = s;
  void clear() => state = null;

  Future<void> logout() async {
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
  Future<StudentModel> login({
    required String identifier,
    required String password,
  }) async {
    String email;
    if (identifier.contains('@')) {
      email = identifier.trim();
    } else {
      final row = await _db
          .from('students')
          .select('email')
          .or('hall_ticket.eq.${identifier.trim()},mobile.eq.${identifier.trim()}')
          .maybeSingle();
      if (row == null) throw Exception('No account found for this Hall Ticket / Mobile number.');
      email = row['email'] as String;
    }

    try {
      final response = await SupabaseService.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw Exception('Login failed — please try again.');

      await _ref.read(currentStudentProvider.notifier).load();
      final student = _ref.read(currentStudentProvider);
      if (student == null) {
        await SupabaseService.signOut();
        throw Exception('Student profile not found. Please contact support.');
      }
      return student;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid') || msg.contains('credentials') || msg.contains('wrong')) {
        throw Exception('Incorrect email or password. Please try again.');
      } else if (msg.contains('email not confirmed') || msg.contains('not confirmed')) {
        throw Exception('Please verify your email first. Check your inbox for a confirmation link.');
      } else if (msg.contains('too many')) {
        throw Exception('Too many login attempts. Please wait a moment and try again.');
      } else {
        throw Exception('Login failed: ${e.message}');
      }
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  Future<AuthResponse> register(
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
      if (user == null) throw Exception('Session expired. Please verify email and mobile again.');

      await _db.from('students').insert({
        'id': user.id,
        'first_name': student.firstName,
        'last_name': student.lastName,
        'full_name_aadhar': student.fullNameAadhar,
        'mobile': student.mobile,
        'email': student.email,
        'hall_ticket': student.hallTicket,
        'university_id': student.universityId,
        'college_id': student.collegeId,
        'course': student.course,
        'branch': student.branch,
        'semester': student.semester,
        'year_of_study': student.yearOfStudy,
        'passing_year': student.passingYear,
        'gender': student.gender,
        'state': student.state,
        'is_mobile_verified': true,
        'is_email_verified': true,
        'profile_pic_url': profilePicUrl,
        'id_card_url': idCardUrl,
        'verification_status': 'Approved',
        'is_verified': true,
      });

      await SupabaseService.signOut();
      _ref.read(currentStudentProvider.notifier).clear();

      return AuthResponse(user: user);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit') || msg.contains('security purposes')) {
        throw Exception('Too many registration attempts. Please wait a few minutes and try again.');
      } else if (msg.contains('already registered') || msg.contains('user_already_exists')) {
        throw Exception(
          'This email is already registered.\n\n'
          '👉 Please proceed directly to the Login page to sign in with your credentials.',
        );
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } on PostgrestException catch (e) {
      throw Exception(_friendlyPostgrestMessage(e));
    } catch (e) {
      throw Exception(_friendlyGenericMessage(e));
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
