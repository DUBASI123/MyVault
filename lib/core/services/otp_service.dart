import 'package:dio/dio.dart';
import 'api_client.dart';

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

/// OTP via Node.js backend → Twilio Verify (SMS) / SendGrid (Email).
class OtpService {
  OtpService._();

  static bool get hasLiveProvider => true;

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
    try {
      final data = await ApiClient.post(
        '/auth/send-otp',
        data: {'target': normalized, 'purpose': purpose},
      );

      if (data['error'] != null) {
        throw Exception(data['error'] as String);
      }

      final otpPreview = data['otpPreview']?.toString();
      return OtpSendResult(
        type: type,
        target: normalized,
        otpPreview: otpPreview,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message ?? 'Network error';
      throw Exception('OTP failed: $msg');
    } catch (e) {
      throw Exception('OTP failed: $e');
    }
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

    try {
      final data = await ApiClient.post(
        '/auth/verify-otp',
        data: {'target': normalized, 'otp': otp, 'purpose': purpose},
      );

      return data['verified'] == true;
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? e.message ?? 'Network error';
      throw Exception('OTP verification failed: $msg');
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }
}
