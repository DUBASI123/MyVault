import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';
import 'otp_verification_badge.dart';

/// Mobile or email OTP block with badge, send, and verify.
class OtpVerificationPanel extends StatelessWidget {
  final String label;
  final TextEditingController valueController;
  final TextEditingController otpController;
  final TextInputType keyboardType;
  final OtpBadgeStatus status;
  final bool isLoading;
  final bool readOnlyValue;
  final VoidCallback onSendOtp;
  final VoidCallback onVerify;

  const OtpVerificationPanel({
    super.key,
    required this.label,
    required this.valueController,
    required this.otpController,
    required this.status,
    required this.onSendOtp,
    required this.onVerify,
    this.keyboardType = TextInputType.text,
    this.isLoading = false,
    this.readOnlyValue = false,
  });

  bool get _isVerified => status == OtpBadgeStatus.verified;

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 48,
      height: 52,
      textStyle: AppTextStyles.bodyLarge,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: AppTextStyles.label),
            ),
            OtpVerificationBadge(status: status),
          ],
        ),
        const SizedBox(height: 6),
        CustomTextField(
          label: label,
          controller: valueController,
          keyboardType: keyboardType,
          readOnly: readOnlyValue || _isVerified,
          isRequired: true,
        ),
        if (!_isVerified) ...[
          const SizedBox(height: 12),
          if (status == OtpBadgeStatus.pending || status == OtpBadgeStatus.failed)
            CustomButton(
              text: 'Send OTP',
              onPressed: isLoading ? null : onSendOtp,
              isLoading: isLoading,
              icon: Icons.send_outlined,
              height: 46,
            ),
          if (status == OtpBadgeStatus.sent || status == OtpBadgeStatus.failed) ...[
            const Text('Enter 6-digit OTP', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            Pinput(
              controller: otpController,
              length: 6,
              defaultPinTheme: pinTheme,
              focusedPinTheme: pinTheme.copyWith(
                decoration: pinTheme.decoration?.copyWith(
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Verify OTP',
              onPressed: isLoading ? null : onVerify,
              isLoading: isLoading,
              icon: Icons.verified_user_outlined,
              height: 46,
            ),
          ],
        ],
      ],
    );
  }
}
