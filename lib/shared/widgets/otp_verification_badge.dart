import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum OtpBadgeStatus { pending, sent, verified, failed }

class OtpVerificationBadge extends StatelessWidget {
  final OtpBadgeStatus status;

  const OtpVerificationBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      OtpBadgeStatus.pending => ('Not verified', AppColors.warning, Icons.schedule_outlined),
      OtpBadgeStatus.sent => ('OTP sent', AppColors.info, Icons.sms_outlined),
      OtpBadgeStatus.verified => ('Verified', AppColors.success, Icons.verified_outlined),
      OtpBadgeStatus.failed => ('Failed', AppColors.error, Icons.error_outline),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
