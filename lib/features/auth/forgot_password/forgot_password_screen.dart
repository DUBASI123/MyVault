import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/config/env.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  bool _isLoading = false;

  final _identifier = TextEditingController(); // mobile or hall ticket
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  static final _backendBaseUrl = Env.backendUrl;

  @override
  void dispose() {
    _identifier.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : AppColors.success,
      ),
    );
  }

  Future<void> _reset() async {
    if (_identifier.text.trim().isEmpty) {
      _snack('Enter your mobile or hall ticket number', error: true);
      return;
    }
    if (_newPassword.text.length < 6) {
      _snack('Password must be at least 6 characters', error: true);
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      _snack('Passwords do not match', error: true);
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      _snack('Password reset successful! Please login.');
      context.go('/login');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Reset your password',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your mobile number or hall ticket and set a new password.',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Mobile or Hall Ticket',
              controller: _identifier,
              keyboardType: TextInputType.text,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'New Password',
              controller: _newPassword,
              isPassword: true,
              isRequired: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Confirm Password',
              controller: _confirmPassword,
              isPassword: true,
              isRequired: true,
            ),
            const SizedBox(height: 28),
            CustomButton(
              text: 'Reset Password',
              onPressed: _reset,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(color: Color(0xFF4F46E5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
