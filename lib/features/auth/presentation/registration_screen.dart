// lib/features/auth/presentation/registration_screen.dart
//
// Simple registration/account creation screen for MyVault, supporting both
// B.Tech and Degree student flows via a segmented toggle.
//
// Product rules encoded here (per MyVault conventions):
//  - Full name is stored as "Lastname Firstname"
//  - Hall ticket number doubles as the default password
//  - Semester is stored/displayed as "Xyr-Ysem"
//  - No OTP step, no admin-approval step — registration is self-contained
//
// Wire into GoRouter, e.g.:
//   GoRoute(path: '/register', builder: (_, __) => const RegistrationScreen()),

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/student_model.dart';

enum CourseType { btech, degree }

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key, this.onSubmit});

  /// Called with the collected form data on successful submit.
  final Future<void> Function(Map<String, dynamic> data)? onSubmit;

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  CourseType _courseType = CourseType.btech;
  bool _submitting = false;

  final _fullNameCtrl = TextEditingController();
  final _hallTicketCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();

  String? _university;
  String? _branch;
  String? _degreeCourse;
  int? _year;
  int? _sem;

  static const _universities = ['JNTUH', 'Osmania University', 'RGUKT', 'Other'];
  static const _branches = ['CSE', 'CSE (AI & ML)', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT'];
  static const _degreeCourses = ['B.Sc', 'B.Com', 'B.A', 'BBA', 'BCA'];

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _hallTicketCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  int get _maxYear => _courseType == CourseType.btech ? 4 : 3;

  String? get _semesterLabel =>
      (_year != null && _sem != null) ? '${_year}yr-${_sem}sem' : null;

  /// "Sai Kiran Reddy" -> "Reddy Sai Kiran"
  String _toLastnameFirstname(String input) {
    final parts = input.trim().split(RegExp(r'\s+'));
    if (parts.length < 2) return input.trim();
    final last = parts.removeLast();
    return '$last ${parts.join(' ')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_university == null || _year == null || _sem == null) {
      _showSnack('Please fill all required fields');
      return;
    }
    if (_courseType == CourseType.btech && _branch == null) {
      _showSnack('Please select a branch');
      return;
    }
    if (_courseType == CourseType.degree && _degreeCourse == null) {
      _showSnack('Please select a course');
      return;
    }

    setState(() => _submitting = true);

    final fullNameFormatted = _toLastnameFirstname(_fullNameCtrl.text);
    final nameParts = fullNameFormatted.split(' ');
    final lastName = nameParts.isNotEmpty ? nameParts.first : '';
    final firstName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : fullNameFormatted;

    final data = {
      'courseType': _courseType.name,
      'fullName': fullNameFormatted,
      'university': _university,
      'branch': _courseType == CourseType.btech ? _branch : null,
      'degreeCourse': _courseType == CourseType.degree ? _degreeCourse : null,
      'group': _courseType == CourseType.degree ? _groupCtrl.text.trim() : null,
      'semester': _semesterLabel, // e.g. "2yr-1sem"
      'hallTicketNumber': _hallTicketCtrl.text.trim().toUpperCase(),
      'password': _hallTicketCtrl.text.trim(), // default password = hall ticket
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
    };

    try {
      if (widget.onSubmit != null) {
        await widget.onSubmit!(data);
      } else {
        final student = StudentModel(
          id: '',
          firstName: firstName,
          lastName: lastName,
          fullNameAadhar: fullNameFormatted,
          mobile: _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          hallTicket: _hallTicketCtrl.text.trim().toUpperCase(),
          universityId: '1',
          collegeId: 'c_1',
          universityName: _university ?? '',
          collegeName: 'Main Campus',
          course: _courseType == CourseType.btech ? 'B.Tech' : (_degreeCourse ?? 'Degree'),
          branch: _courseType == CourseType.btech ? (_branch ?? 'CSE') : (_groupCtrl.text.trim().isNotEmpty ? _groupCtrl.text.trim() : 'General'),
          semester: _sem ?? 1,
          yearOfStudy: _year ?? 1,
          gender: 'General',
          state: 'Telangana',
          isMobileVerified: true,
          isEmailVerified: true,
          verificationStatus: 'Approved',
          isVerified: true,
          createdAt: DateTime.now(),
        );

        await ref.read(authRepositoryProvider).register(
          student,
          _hallTicketCtrl.text.trim(),
          idCardPath: '',
          profilePicPath: '',
        );
      }

      if (mounted) {
        _showSnack('Account created 🎓', success: true);
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) _showSnack('Could not create account. ${e.toString()}', success: false);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF12324D) : const Color(0xFF4A1F1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080D),
      body: Stack(
        children: [
          // ambient liquid-glass gradient blobs
          Positioned(
            top: -140,
            left: -120,
            child: _blob(const Color(0xFF3E7BFF)),
          ),
          Positioned(
            bottom: -160,
            right: -100,
            child: _blob(const Color(0xFF00D9F5)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CREATE ACCOUNT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Join MyVault',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'One account gets you study material, results, internships and placements.',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13.5, height: 1.4),
                    ),
                    const SizedBox(height: 22),

                    _CourseToggle(
                      value: _courseType,
                      onChanged: (v) => setState(() {
                        _courseType = v;
                        _branch = null;
                        _degreeCourse = null;
                        if (_year != null && _year! > _maxYear) _year = null;
                      }),
                    ),
                    const SizedBox(height: 20),

                    _label('Full name'),
                    _textField(
                      controller: _fullNameCtrl,
                      hint: 'e.g. Sai Kiran Reddy',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _hint('Stored as Lastname Firstname on your profile.'),
                    const SizedBox(height: 16),

                    _label('University'),
                    _dropdown(
                      value: _university,
                      items: _universities,
                      hint: 'Select university',
                      onChanged: (v) => setState(() => _university = v),
                    ),
                    const SizedBox(height: 16),

                    if (_courseType == CourseType.btech) ...[
                      _label('Branch'),
                      _dropdown(
                        value: _branch,
                        items: _branches,
                        hint: 'Select branch',
                        onChanged: (v) => setState(() => _branch = v),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      _label('Course'),
                      _dropdown(
                        value: _degreeCourse,
                        items: _degreeCourses,
                        hint: 'Select course',
                        onChanged: (v) => setState(() => _degreeCourse = v),
                      ),
                      const SizedBox(height: 16),
                      _label('Group / specialization'),
                      _textField(controller: _groupCtrl, hint: 'e.g. MPC, CEC, Computers'),
                      const SizedBox(height: 16),
                    ],

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Year'),
                              _dropdown(
                                value: _year?.toString(),
                                items: List.generate(_maxYear, (i) => '${i + 1}'),
                                hint: 'Year',
                                onChanged: (v) => setState(() => _year = int.tryParse(v ?? '')),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Semester'),
                              _dropdown(
                                value: _sem?.toString(),
                                items: const ['1', '2'],
                                hint: 'Sem',
                                onChanged: (v) => setState(() => _sem = int.tryParse(v ?? '')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_semesterLabel != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3E7BFF).withOpacity(0.10),
                          border: Border.all(color: const Color(0xFF3E7BFF).withOpacity(0.25)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '📘 $_semesterLabel',
                          style: const TextStyle(color: Color(0xFF9FC4FF), fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    _label('Hall ticket number'),
                    _textField(
                      controller: _hallTicketCtrl,
                      hint: 'e.g. 21A81A0501',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _hint('This is also your default password — you can change it later.'),
                    const SizedBox(height: 16),

                    _label('Email'),
                    _textField(
                      controller: _emailCtrl,
                      hint: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _label('Phone number'),
                    _textField(
                      controller: _phoneCtrl,
                      hint: '10-digit mobile number',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (v) {
                        if (v == null || v.trim().length != 10) return 'Enter a 10-digit number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3E7BFF), Color(0xFF00D9F5)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B4FF).withOpacity(0.28),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: _submitting ? null : _submit,
                            child: Center(
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF04101F)),
                                    )
                                  : const Text(
                                      'Create account',
                                      style: TextStyle(
                                        color: Color(0xFF04101F),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
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

  Widget _blob(Color color) => Container(
        width: 400,
        height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withOpacity(0.35), Colors.transparent]),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(
          text,
          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(text, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11.5, height: 1.4)),
      );

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.28), fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.055),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFF5B9CFF)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: _decoration(hint),
    );
  }

  Widget _dropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: const Color(0xFF12172A),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: _decoration(hint),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }
}

class _CourseToggle extends StatelessWidget {
  const _CourseToggle({required this.value, required this.onChanged});

  final CourseType value;
  final ValueChanged<CourseType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Expanded(child: _segment(context, 'B.Tech', CourseType.btech)),
          Expanded(child: _segment(context, 'Degree', CourseType.degree)),
        ],
      ),
    );
  }

  Widget _segment(BuildContext context, String label, CourseType type) {
    final selected = value == type;
    return GestureDetector(
      onTap: () => onChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFF3E7BFF), Color(0xFF00D9F5)])
              : null,
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF3E7BFF).withOpacity(0.35), blurRadius: 18)]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white.withOpacity(0.55),
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}
