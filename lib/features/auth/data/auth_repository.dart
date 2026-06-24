import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/api_client.dart';
import '../../../core/services/otp_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/student_model.dart';

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

  void setStudent(StudentModel s) => state = s;

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
      if (student == null) throw Exception('Student profile not found. Please contact support.');
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
  Future<StudentModel> register(StudentModel student, String password) async {
    try {
      // 1. Create Supabase Auth user — emailRedirectTo: '' disables email
      //    confirmation requirement so users can log in immediately.
      final response = await SupabaseService.signUp(
        email: student.email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw Exception('Account creation failed. Please try again.');

      // 2. Insert student profile
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
      });

      return student.copyWith(id: user.id);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('rate limit') || msg.contains('over_email_send_rate_limit') || msg.contains('security purposes')) {
        throw Exception(
          'Email rate limit exceeded.\n\n'
          '👉 IMPORTANT: Please turn off "Confirm email" in your Supabase Dashboard '
          '(Authentication -> Providers -> Email -> Turn off "Confirm email") to allow instant registrations.'
        );
      } else {
        throw Exception('Registration failed: ${e.message}');
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
