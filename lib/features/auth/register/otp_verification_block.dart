import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide OtpChannel;

enum OtpChannel { mobile, email }

class _Palette {
  static const bg = Color(0xFF0A0A0F);
  static const surface = Color(0xFF1A1A2E);
  static const accent = Color(0xFF6C63FF);
  static const error = Color(0xFFE5484D);
  static const success = Color(0xFF3ECF8E);
}

/// Small text-link trigger matching your existing "Verify Email" style.
/// Tapping it opens the OTP entry sheet as a modal bottom sheet — keeps
/// your form layout untouched (no permanent gap reserved in the column).
class OtpVerifyTrigger extends StatelessWidget {
  final OtpChannel channel;
  final String target;
  final bool isVerified;
  final VoidCallback onVerified;

  const OtpVerifyTrigger({
    super.key,
    required this.channel,
    required this.target,
    required this.isVerified,
    required this.onVerified,
  });

  String get _label =>
      channel == OtpChannel.mobile ? 'Verify Mobile' : 'Verify Email';

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: _Palette.success, size: 16),
            const SizedBox(width: 6),
            Text(
              channel == OtpChannel.mobile
                  ? 'Mobile verified'
                  : 'Email verified',
              style: const TextStyle(
                color: _Palette.success,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: InkWell(
        onTap: target.trim().isEmpty
            ? null
            : () async {
                final verified = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _OtpSheet(channel: channel, target: target),
                );
                if (verified == true) onVerified();
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: target.trim().isEmpty ? Colors.white24 : _Palette.accent,
            ),
            const SizedBox(width: 6),
            Text(
              _label,
              style: TextStyle(
                color:
                    target.trim().isEmpty ? Colors.white24 : _Palette.accent,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpSheet extends StatefulWidget {
  final OtpChannel channel;
  final String target;

  const _OtpSheet({required this.channel, required this.target});

  @override
  State<_OtpSheet> createState() => _OtpSheetState();
}

class _OtpSheetState extends State<_OtpSheet> {
  static const int _otpLength = 6;

  final _supabase = Supabase.instance.client;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _otpSent = false;
  bool _sending = false;
  bool _verifying = false;
  String? _errorText;
  int _cooldown = 0;
  Timer? _timer;

  String get _channelLabel =>
      widget.channel == OtpChannel.mobile ? 'mobile number' : 'email';

  /// Normalizes mobile numbers to E.164 (+91...) for Supabase phone auth.
  String get _normalizedTarget {
    if (widget.channel == OtpChannel.email) return widget.target.trim();
    final digits = widget.target.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.startsWith('91') && digits.length == 12) return '+$digits';
    return widget.target.trim().startsWith('+')
        ? widget.target.trim()
        : '+$digits';
  }

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());
    _sendOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown--);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _sending = true;
      _errorText = null;
    });
    try {
      if (widget.channel == OtpChannel.email) {
        // shouldCreateUser: true → works whether the email already exists
        // in auth.users or not. This is the fix for the 422
        // user_already_exists error you were hitting with signUp().
        await _supabase.auth.signInWithOtp(
          email: _normalizedTarget,
          shouldCreateUser: true,
        );
      } else {
        await _supabase.auth.signInWithOtp(
          phone: _normalizedTarget,
          shouldCreateUser: true,
        );
      }
      if (!mounted) return;
      setState(() {
        _sending = false;
        _otpSent = true;
      });
      _startCooldown();
      FocusScope.of(context).requestFocus(_focusNodes.first);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _errorText = _friendlyAuthError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _errorText = 'Could not send OTP. Check your connection.';
      });
    }
  }

  Future<void> _verifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != _otpLength) {
      setState(() => _errorText = 'Enter the $_otpLength-digit code');
      return;
    }
    setState(() {
      _verifying = true;
      _errorText = null;
    });
    try {
      final res = await _supabase.auth.verifyOTP(
        type: widget.channel == OtpChannel.email
            ? OtpType.email
            : OtpType.sms,
        token: code,
        email: widget.channel == OtpChannel.email ? _normalizedTarget : null,
        phone: widget.channel == OtpChannel.mobile ? _normalizedTarget : null,
      );
      if (!mounted) return;
      if (res.session != null) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _verifying = false;
          _errorText = 'Incorrect OTP. Please try again.';
        });
        _clearBoxes();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _errorText = _friendlyAuthError(e);
      });
      _clearBoxes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _errorText = 'Verification failed. Try again.';
      });
      _clearBoxes();
    }
  }

  String _friendlyAuthError(AuthException e) {
    if (e.statusCode == '422' || e.message.contains('user_already_exists')) {
      return 'This $_channelLabel is already registered with a verified '
          'account. Try logging in instead.';
    }
    if (e.message.toLowerCase().contains('expired')) {
      return 'OTP expired. Tap Resend to get a new one.';
    }
    if (e.message.toLowerCase().contains('invalid')) {
      return 'Incorrect OTP. Please try again.';
    }
    return e.message;
  }

  void _clearBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    FocusScope.of(context).requestFocus(_focusNodes.first);
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _otpLength - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Verify your $_channelLabel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Code sent to ${widget.target}',
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            if (_sending && !_otpSent)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(color: _Palette.accent),
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (i) {
                  return SizedBox(
                    width: 44,
                    height: 52,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _Palette.bg,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: _Palette.accent, width: 1.5),
                        ),
                      ),
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _cooldown > 0 || _sending ? null : _sendOtp,
                    child: Text(
                      _cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend OTP',
                      style: TextStyle(
                        color:
                            _cooldown > 0 ? Colors.white38 : _Palette.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      onPressed: _verifying ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _Palette.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Verify',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorText!,
                style: const TextStyle(color: _Palette.error, fontSize: 12.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
