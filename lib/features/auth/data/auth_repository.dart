import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/otp_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../shared/models/student_model.dart';

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
    // identifier may be email, hall-ticket, or mobile
    String email;
    if (identifier.contains('@')) {
      email = identifier.trim();
    } else {
      // Look up email from students table by hall_ticket or mobile
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
      if (!student.isVerified) {
        await SupabaseService.signOut();
        _ref.read(currentStudentProvider.notifier).clear();
        throw PendingVerificationException(
          collegeName: student.collegeName.isNotEmpty ? student.collegeName : 'your college',
          status: student.verificationStatus,
          rejectionReason: student.rejectionReason,
        );
      }
      return student;
    } on AuthException catch (e) {
      // Map raw Supabase auth errors to user-friendly messages
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
  Future<StudentModel> register(
    StudentModel student,
    String password, {
    required String idCardPath,
    required String profilePicPath,
  }) async {
    try {
      // 1. Upload files first
      final idCardUrl = await CloudinaryService.uploadFile(File(idCardPath));
      if (idCardUrl == null) throw Exception('Failed to upload Student ID Card.');

      final profilePicUrl = await CloudinaryService.uploadFile(File(profilePicPath));
      if (profilePicUrl == null) throw Exception('Failed to upload Profile Photo.');

      // 2. Create Supabase Auth user
      final response = await SupabaseService.signUp(
        email: student.email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw Exception('Account creation failed. Please try again.');

      // 3. Insert student profile
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
        'is_mobile_verified': student.isMobileVerified,
        'is_email_verified': student.isEmailVerified,
        'profile_pic_url': profilePicUrl,
        'id_card_url': idCardUrl,
        'verification_status': 'Pending',
        'is_verified': false,
      });

      return student.copyWith(
        id: user.id,
        profilePicUrl: profilePicUrl,
        idCardUrl: idCardUrl,
        verificationStatus: 'Pending',
        isVerified: false,
      );
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit') || msg.contains('security purposes')) {
        throw Exception(
          'Email rate limit exceeded.\n\n'
          '👉 IMPORTANT: Please turn off "Confirm email" in your Supabase Dashboard '
          '(Authentication -> Providers -> Email -> Turn off "Confirm email") to allow instant registrations.'
        );
      } else if (msg.contains('already registered') || msg.contains('user_already_exists')) {
        throw Exception(
          'This email is already registered.\n\n'
          '👉 FIX: If your previous registration failed halfway, please go to your Supabase Dashboard -> Authentication -> Users, delete this user record, and register again.'
        );
      } else {
        throw Exception('Registration failed: ${e.message}');
      }
    } on PostgrestException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('students_mobile_key') || msg.contains('mobile')) {
        throw Exception(
          'This Mobile Number is already registered.\n\n'
          '👉 Please use a different mobile number or log in if you already have an account.'
        );
      } else if (msg.contains('students_hall_ticket_key') || msg.contains('hall_ticket')) {
        throw Exception(
          'This Hall Ticket / Roll Number is already registered.\n\n'
          '👉 Please verify your Hall Ticket number or contact support.'
        );
      } else if (msg.contains('students_email_key') || msg.contains('email')) {
        throw Exception(
          'This Email is already registered.\n\n'
          '👉 Please use a different email or log in if you already have an account.'
        );
      } else {
        throw Exception('Database registration failed: ${e.message}');
      }
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('students_mobile_key') || errStr.contains('mobile')) {
        throw Exception(
          'This Mobile Number is already registered.\n\n'
          '👉 Please use a different mobile number or log in if you already have an account.'
        );
      } else if (errStr.contains('students_hall_ticket_key') || errStr.contains('hall_ticket')) {
        throw Exception(
          'This Hall Ticket / Roll Number is already registered.\n\n'
          '👉 Please verify your Hall Ticket number or contact support.'
        );
      } else {
        throw Exception('Registration failed: $e');
      }
    }
  }

  // ── OTP helpers ───────────────────────────────────────────────────────────
  Future<OtpSendResult> sendOtp(String target, {String purpose = 'register'}) =>
      OtpService.sendOtp(target, purpose: purpose);

  Future<bool> verifyOtp(
    String target,
    String otp, {
    String? verificationId,
    String purpose = 'register',
  }) =>
      OtpService.verifyOtp(target, otp,
          verificationId: verificationId, purpose: purpose);

  // ── Reset password via Node.js backend ────────────────────────────────────
  Future<void> resetPassword(
    String contact,
    String otp,
    String newPassword,
  ) async {
    // OTP must already be verified by the caller before this is called.
    final data = await ApiClient.post('/auth/reset-password', data: {
      'identifier': contact,
      'otp': otp,
      'newPassword': newPassword,
    });
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }
  }
}
