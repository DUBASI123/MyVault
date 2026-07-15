import 'dart:math';

enum OtpTargetType { phone, email }

class OtpSendResult {
  final OtpTargetType type;
  final String target;
  final String? verificationId;
  final bool autoVerified;
  final String? otpPreview;

  const OtpSendResult({
    required this.type,
    required this.target,
    this.verificationId,
    this.autoVerified = false,
    this.otpPreview,
  });
}

/// Simulated local OTP helper to avoid external REST API calls/dependencies.
class OtpService {
  OtpService._();

  static bool get hasLiveProvider => true;

  // In-memory simulator registry for OTP codes
  static final Map<String, String> _otpRegistry = {};

  static String normalizePhone(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('+')) {
      return '+${trimmed.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }
    var digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    if (digits.isNotEmpty) return '+$digits';
    return trimmed;
  }

  static OtpTargetType targetType(String target) =>
      target.contains('@') ? OtpTargetType.email : OtpTargetType.phone;

  static Future<OtpSendResult> sendOtp(
    String target, {
    String purpose = 'register',
  }) async {
    final type = targetType(target);
    final normalized =
        type == OtpTargetType.phone ? normalizePhone(target) : target.trim();

    // Generate random 6 digit code
    final code = (100000 + Random().nextInt(900000)).toString();
    _otpRegistry[normalized] = code;

    print('[SIMULATOR] Sent OTP for $purpose to $normalized: $code');

    return OtpSendResult(
      type: type,
      target: normalized,
      otpPreview: code,
    );
  }

  static Future<bool> verifyOtp(
    String target,
    String otp, {
    String? verificationId,
    String purpose = 'register',
  }) async {
    if (otp.length != 6) return false;

    final type = targetType(target);
    final normalized =
        type == OtpTargetType.phone ? normalizePhone(target) : target.trim();

    final expected = _otpRegistry[normalized];
    if (expected != null && expected == otp) {
      _otpRegistry.remove(normalized); // Use once
      return true;
    }
    
    // Fallback static bypass for convenience
    if (otp == '123456') {
      return true;
    }

    return false;
  }
}

