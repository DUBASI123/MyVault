import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/otp_service.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/otp_verification_badge.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  String _mode = 'mobile';
  OtpBadgeStatus _otpStatus = OtpBadgeStatus.pending;
  bool _isLoading = false;
  String? _phoneVerificationId;

  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _hallTicket = TextEditingController();
  final _otp = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _mobile.dispose();
    _hallTicket.dispose();
    _otp.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String get _target => _mode == 'email' ? _email.text.trim() : _mobile.text.trim();

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? AppColors.error : AppColors.success),
    );
  }

  Future<void> _sendOtp() async {
    if (_target.isEmpty) {
      _snack('Enter ${_mode == 'email' ? 'email' : 'mobile'}', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authRepositoryProvider).sendOtp(
            _target,
            purpose: 'reset',
          );
      _phoneVerificationId = result.verificationId;
      if (result.autoVerified) {
        setState(() => _otpStatus = OtpBadgeStatus.verified);
        _snack('Verified automatically');
      } else {
        setState(() => _otpStatus = OtpBadgeStatus.sent);
        var msg = 'OTP sent to ${_mode == 'mobile' ? OtpService.normalizePhone(_target) : _target}';
        if (result.otpPreview != null) {
          msg += '\n[DEV ONLY] Code: ${result.otpPreview}';
        }
        _snack(msg);
      }
    } catch (e) {
      setState(() => _otpStatus = OtpBadgeStatus.failed);
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otp.text.length != 6) {
      _snack('Enter 6-digit OTP', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final ok = await ref.read(authRepositoryProvider).verifyOtp(
            _target,
            _otp.text,
            verificationId: _phoneVerificationId,
            purpose: 'reset',
          );
      setState(() => _otpStatus = ok ? OtpBadgeStatus.verified : OtpBadgeStatus.failed);
      _snack(ok ? 'OTP verified' : 'Invalid OTP', error: !ok);
    } catch (e) {
      setState(() => _otpStatus = OtpBadgeStatus.failed);
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _reset() async {
    if (_otpStatus != OtpBadgeStatus.verified) {
      _snack('Verify OTP first', error: true);
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _snack('Passwords do not match', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final normalizedTarget = _mode == 'email'
          ? _email.text.trim()
          : OtpService.normalizePhone(_mobile.text.trim());
      await ref.read(authRepositoryProvider).resetPassword(
            normalizedTarget,
            _otp.text,
            _newPassword.text,
          );
      if (mounted) {
        _snack('Password reset successful');
        context.go(AppRoutes.login);
      }
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinTheme = PinTheme(
      width: 48,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('OTP Status', style: AppTextStyles.label),
                const Spacer(),
                OtpVerificationBadge(status: _otpStatus),
              ],
            ),
            const SizedBox(height: 20),
            if (_otpStatus != OtpBadgeStatus.verified) ...[
              Row(
                children: [
                  Expanded(child: _modeBtn('Mobile', 'mobile')),
                  const SizedBox(width: 12),
                  Expanded(child: _modeBtn('Email', 'email')),
                ],
              ),
              const SizedBox(height: 20),
              if (_mode == 'email')
                CustomTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress)
              else
                CustomTextField(label: 'Mobile', controller: _mobile, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              CustomTextField(label: 'Hall Ticket', controller: _hallTicket),
              const SizedBox(height: 20),
              if (_otpStatus == OtpBadgeStatus.pending || _otpStatus == OtpBadgeStatus.failed)
                CustomButton(text: 'Send OTP', onPressed: _sendOtp, isLoading: _isLoading, icon: Icons.send_outlined),
              if (_otpStatus == OtpBadgeStatus.sent || _otpStatus == OtpBadgeStatus.failed) ...[
                const SizedBox(height: 16),
                const Text('Enter OTP', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Pinput(controller: _otp, length: 6, defaultPinTheme: pinTheme),
                const SizedBox(height: 16),
                CustomButton(text: 'Verify OTP', onPressed: _verifyOtp, isLoading: _isLoading, icon: Icons.verified_outlined),
              ],
            ],
            if (_otpStatus == OtpBadgeStatus.verified) ...[
              CustomTextField(label: 'New Password', controller: _newPassword, isPassword: true),
              const SizedBox(height: 12),
              CustomTextField(label: 'Confirm Password', controller: _confirmPassword, isPassword: true),
              const SizedBox(height: 20),
              CustomButton(text: 'Reset Password', onPressed: _reset, isLoading: _isLoading),
            ],
          ],
        ),
      ),
    );
  }

  Widget _modeBtn(String label, String mode) {
    final selected = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() {
        _mode = mode;
        _otpStatus = OtpBadgeStatus.pending;
        _phoneVerificationId = null;
        _otp.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: selected ? AppColors.textWhite : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
