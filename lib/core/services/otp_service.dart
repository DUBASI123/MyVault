import 'package:supabase_flutter/supabase_flutter.dart';

class OtpService {
  static final SupabaseClient _client = Supabase.instance.client;

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
