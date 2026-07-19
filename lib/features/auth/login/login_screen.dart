import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/custom_button.dart';
import '../data/auth_repository.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

enum _Step { credentials, otp }

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String _captchaText = '';
  _Step _step = _Step.credentials;
  String? _studentId;
  String? _maskedMobile;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  void _generateCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    _captchaText = String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submitCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    if (_captchaController.text.toUpperCase() != _captchaText) {
      _snack('Invalid CAPTCHA — try again', error: true);
      _generateCaptcha();
      _captchaController.clear();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await ref.read(authRepositoryProvider).login(
            identifier: _identifierController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (!mounted) return;

      if (result is LoginOtpRequired) {
        setState(() {
          _studentId = result.studentId;
          _maskedMobile = result.maskedMobile;
          _step = _Step.otp;
        });
      } else if (result is LoginSuccess) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        _snack(msg, error: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitOtp() async {
    if (_otpController.text.trim().length != 6) {
      _snack('Enter the 6-digit code', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).verifyLoginOtp(
            studentId: _studentId!,
            otp: _otpController.text.trim(),
          );
      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        _snack(msg, error: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_studentId == null) return;
    try {
      await ref.read(authRepositoryProvider).resendLoginOtp(studentId: _studentId!);
      _snack('OTP resent to $_maskedMobile');
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _snack(msg, error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : AppColors.success,
      ),
    );
  }

  static Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Layered gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEDEBFB), Color(0xFFF7F5FF), Color(0xFFE3E8FC)],
              ),
            ),
          ),
          Positioned(
            top: -80,
            right: -60,
            child: _blob(220, const Color(0xFF6C63FF).withOpacity(0.25)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _blob(260, const Color(0xFF4F46E5).withOpacity(0.18)),
          ),
          Positioned(
            top: 260,
            left: -40,
            child: _blob(140, const Color(0xFF9F97FF).withOpacity(0.18)),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    // 3D-style app icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF7F77DD), Color(0xFF4F46E5)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            blurRadius: 8,
                            offset: Offset(-3, -3),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_open_rounded, color: Colors.white, size: 42),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'My Vault',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Student Academic Platform',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 28),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _step == _Step.credentials
                          ? _buildCredentialsCard(key: const ValueKey('creds'))
                          : _buildOtpCard(key: const ValueKey('otp')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard({required Widget child, Key? key}) {
    return ClipRRect(
      key: key,
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildCredentialsCard({Key? key}) {
    return _glassCard(
      key: key,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Login to access your vault',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),

            const Text('Mobile or Hall Ticket *',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _identifierController,
              decoration: _fieldDecoration('Enter mobile number or hall ticket',
                  icon: Icons.person_outline),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            const Text('Password *',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _fieldDecoration(
                'Enter your password',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            const Text('CAPTCHA Verification',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF7F77DD), Color(0xFF4F46E5)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _captchaText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _generateCaptcha();
                    _captchaController.clear();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _captchaController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: _fieldDecoration('Enter CAPTCHA'),
                    validator: (v) => v == null || v.isEmpty ? 'Enter CAPTCHA' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: const Text('Forgot Password?',
                      style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF4F46E5))),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('Register Now →',
                      style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF4F46E5))),
                ),
              ],
            ),
            const SizedBox(height: 12),

            CustomButton(
              text: 'Login to My Vault',
              onPressed: _submitCredentials,
              isLoading: _isLoading,
              icon: Icons.login_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpCard({Key? key}) {
    return _glassCard(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _step = _Step.credentials),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              const Text(
                'Verify your identity',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Enter the 6-digit code sent to ${_maskedMobile ?? "your registered mobile"}',
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, letterSpacing: 10, fontWeight: FontWeight.w700),
            decoration: _fieldDecoration('••••••').copyWith(counterText: ''),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resendOtp,
              child: const Text('Resend OTP',
                  style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF4F46E5))),
            ),
          ),
          const SizedBox(height: 8),
          CustomButton(
            text: 'Verify & Login',
            onPressed: _submitOtp,
            isLoading: _isLoading,
            icon: Icons.verified_rounded,
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white.withOpacity(0.6),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF4F46E5)) : null,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
      ),
    );
  }
}
