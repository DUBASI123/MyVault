// lib/features/auth/presentation/login_screen.dart
//
// Login screen wired to authControllerProvider. Posts hall ticket number +
// password to the NestJS backend via AuthRepository, shows loading/error
// state from the provider, and routes to /home on success.
//
// Long-pressing the logo opens Developer Settings (change backend URL
// without rebuilding — for when a device's configured backend URL goes stale).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hallTicketCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscure = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _hallTicketCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(
          hallTicketNumber: _hallTicketCtrl.text.trim().toUpperCase(),
          password: _passwordCtrl.text,
        );
    final state = ref.read(authControllerProvider);
    if (state.hasValue && state.value != null && mounted) {
      context.go('/home');
    } else if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: const Color(0xFF4A1F1F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final submitting = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: Stack(
        children: [
          Positioned(top: -140, left: -120, child: _blob(const Color(0xFF3E7BFF))),
          Positioned(bottom: -160, right: -100, child: _blob(const Color(0xFF00D9F5))),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onLongPress: () => context.push('/dev-settings'),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(colors: [Color(0xFF3E7BFF), Color(0xFF00D9F5)]),
                              boxShadow: [BoxShadow(color: const Color(0xFF00B4FF).withOpacity(0.35), blurRadius: 32)],
                            ),
                            alignment: Alignment.center,
                            child: const Text('🎓', style: TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('MyVault', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Your college, in your pocket',
                            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Text('Welcome back', style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Log in with your hall ticket number to continue.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13.5, height: 1.4)),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Hall ticket number'),
                        _textField(
                          controller: _hallTicketCtrl,
                          hint: 'e.g. 21A81A0501',
                          textCapitalization: TextCapitalization.characters,
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _label('Password'),
                        _textField(
                          controller: _passwordCtrl,
                          hint: 'Your password',
                          obscure: _obscure,
                          suffix: TextButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            child: Text(_obscure ? 'SHOW' : 'HIDE',
                                style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11, fontWeight: FontWeight.w700)),
                          ),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
                                      gradient: _rememberMe
                                          ? const LinearGradient(colors: [Color(0xFF3E7BFF), Color(0xFF00D9F5)])
                                          : null,
                                      color: _rememberMe ? null : Colors.white.withOpacity(0.055),
                                    ),
                                    child: _rememberMe ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Remember me', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.5)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Contact your department admin to reset')),
                              ),
                              child: const Text('Forgot password?',
                                  style: TextStyle(color: Color(0xFF7FB4FF), fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _gradientButton(label: 'Log in', loading: submitting, onTap: submitting ? null : _submit),
                      ],
                    ),
                  ),
                  _divider('New to MyVault'),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => context.push('/register'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.09),
                        side: BorderSide(color: Colors.white.withOpacity(0.10)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Create an account',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Your hall ticket number is your default password.\nYou can change it anytime from Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 12, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color) => Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(0.35), Colors.transparent])),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, fontWeight: FontWeight.w600)),
      );

  Widget _divider(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            Expanded(child: Divider(color: Colors.white.withOpacity(0.10))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(text.toUpperCase(),
                  style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
            Expanded(child: Divider(color: Colors.white.withOpacity(0.10))),
          ],
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    Widget? suffix,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.28), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.055),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.white.withOpacity(0.10))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFF5B9CFF))),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFFF6B6B))),
      ),
    );
  }

  Widget _gradientButton({required String label, required bool loading, required VoidCallback? onTap}) {
    return SizedBox(
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF3E7BFF), Color(0xFF00D9F5)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: const Color(0xFF00B4FF).withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Center(
              child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF04101F)))
                  : Text(label, style: const TextStyle(color: Color(0xFF04101F), fontWeight: FontWeight.w700, fontSize: 14.5)),
            ),
          ),
        ),
      ),
    );
  }
}
