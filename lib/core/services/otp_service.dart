import 'package:supabase_flutter/supabase_flutter.dart';

class OtpService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String tempPassword = 'TempPassword123!';

  /// Normalizes any raw input into a clean 10-digit Indian mobile number.
  static String normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('91') && digits.length == 12) {
      digits = digits.substring(2);
    }
    if (digits.length > 10) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  /// Converts a normalized 10-digit number to E.164 for Supabase.
  static String toE164(String normalized) => '+91${normalizePhone(normalized)}';

  /// Sends an OTP code. If the user is not authenticated, triggers signUp (primary).
  /// If the user is authenticated, triggers updateUser (secondary linking).
  static Future<void> sendOtp({
    required String identifier,
    required String channel,
  }) async {
    final user = _client.auth.currentUser;
    if (channel == 'email') {
      final email = identifier.trim().toLowerCase();
      if (user == null) {
        await _client.auth.signUp(email: email, password: tempPassword);
      } else {
        await _client.auth.updateUser(UserAttributes(email: email));
      }
    } else {
      final phone = toE164(identifier);
      if (user == null) {
        await _client.auth.signUp(phone: phone, password: tempPassword);
      } else {
        await _client.auth.updateUser(UserAttributes(phone: phone));
      }
    }
  }

  /// Verifies an OTP code. Uses signup/sms for primary, emailChange/phoneChange for secondary.
  static Future<bool> verifyOtp({
    required String identifier,
    required String otp,
    required String channel,
  }) async {
    final user = _client.auth.currentUser;
    final AuthResponse response;

    if (channel == 'email') {
      final email = identifier.trim().toLowerCase();
      if (user == null || user.email != email) {
        response = await _client.auth.verifyOTP(
          email: email,
          token: otp,
          type: OtpType.signup,
        );
      } else {
        response = await _client.auth.verifyOTP(
          email: email,
          token: otp,
          type: OtpType.emailChange,
        );
      }
    } else {
      final phone = toE164(identifier);
      if (user == null || user.phone != phone) {
        response = await _client.auth.verifyOTP(
          phone: phone,
          token: otp,
          type: OtpType.sms,
        );
      } else {
        response = await _client.auth.verifyOTP(
          phone: phone,
          token: otp,
          type: OtpType.phoneChange,
        );
      }
    }
    return response.session != null;
  }

  // ---------- EMAIL ----------

  static Future<void> resendEmailOtp(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  static Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  // ---------- MOBILE ----------

  static Future<void> resendPhoneOtp(String normalizedPhone) async {
    await _client.auth.resend(
      type: OtpType.phoneChange,
      phone: toE164(normalizedPhone),
    );
  }

  static Future<AuthResponse> verifyPhoneOtp({
    required String normalizedPhone,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      phone: toE164(normalizedPhone),
      token: token,
      type: OtpType.phoneChange,
    );
  }
}

/// Kept top-level so existing callers (`normalizePhoneE164(...)`) don't break.
String normalizePhoneE164(String normalizedPhone) => OtpService.toE164(normalizedPhone);
