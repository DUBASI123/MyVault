import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/otp_service.dart';
import '../../../shared/widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier;              // raw email or normalized 10-digit phone
  final String channel;                 // 'email' | 'mobile'
  final String purpose;                 // 'register', 'reset', etc.
  final Future<void> Function()? onSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.channel,
    required this.purpose,
    this.onSuccess,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  String? _error;
  int _secondsLeft = 30;
  Timer? _timer;

  bool get _isEmail => widget.channel == 'email';
  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) _focusNodes[index + 1].requestFocus();
    if (value.isEmpty && index > 0) _focusNodes[index - 1].requestFocus();
    setState(() => _error = null);
    if (_code.length == 6) _verify();
  }

  Future<void> _verify() async {
    if (_code.length != 6) {
      setState(() => _error = 'Enter the full 6-digit code');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      if (_isEmail) {
        await OtpService.verifyEmailOtp(email: widget.identifier, token: _code);
      } else {
        await OtpService.verifyPhoneOtp(normalizedPhone: widget.identifier, token: _code);
      }
      if (!mounted) return;
      setState(() => _isVerifying = false);
      if (widget.onSuccess != null) await widget.onSuccess!();
    } catch (e) {
      setState(() {
        _isVerifying = false;
        _error = 'Invalid or expired code. Please try again.';
      });
      for (final c in _controllers) c.clear();
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _isResending) return;
    setState(() => _isResending = true);
    try {
      if (_isEmail) {
        await OtpService.resendEmailOtp(widget.identifier);
      } else {
        await OtpService.resendPhoneOtp(widget.identifier);
      }
      if (mounted) {
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code resent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _isEmail ? 'email' : 'mobile number';
    final display = _isEmail ? widget.identifier : '+91 ${widget.identifier}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify ${_isEmail ? 'Email' : 'Mobile'}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_isEmail ? Icons.mark_email_read_outlined : Icons.sms_outlined,
                color: AppColors.primary, size: 48),
            const SizedBox(height: 16),
            Text('Enter the 6-digit code', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'We sent a verification code to your $label\n$display',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, _otpBox),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
            ],
            const SizedBox(height: 32),
            CustomButton(text: 'Verify', isLoading: _isVerifying, onPressed: _verify),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: _secondsLeft == 0 && !_isResending ? _resend : null,
                child: Text(
                  _isResending
                      ? 'Resending...'
                      : _secondsLeft > 0
                          ? 'Resend code in ${_secondsLeft}s'
                          : 'Resend code',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (v) => _onDigitChanged(index, v),
      ),
    );
  }
}
