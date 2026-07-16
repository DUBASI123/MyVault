import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/otp_service.dart';
import '../../shared/widgets/custom_button.dart';
import 'data/auth_repository.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String identifier;
  final String purpose;
  final VoidCallback onSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.purpose,
    required this.onSuccess,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isLoading = false;
  bool _canResend = false;
  int _secondsRemaining = 30;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
      _canResend = false;
      _errorMessage = null;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer?.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).sendOtp(widget.identifier, purpose: widget.purpose);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification code sent to ${widget.identifier}'),
          backgroundColor: AppColors.primary,
        ),
      );
      _startTimer();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to resend code: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _pinController.text;
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter a 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref.read(authRepositoryProvider).verifyOtp(
      widget.identifier,
      otp,
      purpose: widget.purpose,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      widget.onSuccess();
    } else {
      setState(() {
        _errorMessage = 'Invalid or expired verification code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = OtpService.targetType(widget.identifier) == OtpTargetType.email;
    final channelName = isEmail ? 'email address' : 'phone number';

    // Theme values for pinput boxes
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text('Enter Code', style: AppTextStyles.heading1),
              const SizedBox(height: 8),
              Text(
                'We sent a 6-digit verification code to your $channelName:',
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 4),
              Text(
                widget.identifier,
                style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 36),
              // 6-box input from pinput
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _focusNode,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  keyboardType: TextInputType.number,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (_) => _verifyOtp(),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'Poppins'),
                  ),
                ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Verify Code',
                onPressed: _verifyOtp,
                isLoading: _isLoading,
                icon: Icons.verified_user_outlined,
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: _canResend ? _resendOtp : null,
                  child: Text(
                    _canResend ? 'Resend Verification Code' : 'Resend code in ${_secondsRemaining}s',
                    style: TextStyle(
                      color: _canResend ? AppColors.primary : Colors.white38,
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
