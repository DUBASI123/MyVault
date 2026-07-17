import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/master_service.dart';
import '../../../core/storage/app_storage.dart';
import '../../../shared/models/college_model.dart';
import '../../../core/services/otp_service.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _aadharName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _hallTicket = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // --- OTP verification state ---
  final _mobileOtpController = TextEditingController();
  final _emailOtpController = TextEditingController();

  bool _mobileOtpSent = false;
  bool _emailOtpSent = false;
  bool _mobileVerified = false;
  bool _emailVerified = false;
  bool _sendingMobileOtp = false;
  bool _sendingEmailOtp = false;
  bool _verifyingMobileOtp = false;
  bool _verifyingEmailOtp = false;
  int _mobileResendCooldown = 0;
  int _emailResendCooldown = 0;
  Timer? _mobileCooldownTimer;
  Timer? _emailCooldownTimer;
  String? _lastVerifiedMobile;
  String? _lastVerifiedEmail;

  String? _university;
  String? _college;
  String? _universityId;
  String? _collegeId;
  List<CollegeModel> _colleges = [];
  String? _course;
  String? _branch;
  String? _semester;
  String? _year;
  String? _gender;
  String? _state;

  String? _studentIdPath;
  String? _profilePhotoPath;

  @override
  void initState() {
    super.initState();
    _loadColleges();
    _mobile.addListener(_onMobileChanged);
    _email.addListener(_onEmailChanged);
  }

  Future<void> _loadColleges() async {
    try {
      final cols = await MasterService.getAllColleges();
      if (cols.isEmpty) {
        if (mounted) setState(() => _colleges = MockData.colleges);
      } else {
        if (mounted) setState(() => _colleges = cols);
      }
    } catch (_) {
      if (mounted) setState(() => _colleges = MockData.colleges);
    }
  }

  void _onCollegeSelected(String? name) {
    setState(() {
      _college = name;
      final selectedCol = _colleges.where((c) => c.name == name).firstOrNull;
      _collegeId = selectedCol?.id;
      _universityId = selectedCol?.universityId;
      _university = selectedCol?.universityId;
    });
  }

  // If the user edits the mobile/email after verifying it, invalidate the
  // previous verification so they can't sneak an unverified value through.
  void _onMobileChanged() {
    if (_mobileVerified && _mobile.text.trim() != _lastVerifiedMobile) {
      setState(() {
        _mobileVerified = false;
        _mobileOtpSent = false;
        _mobileOtpController.clear();
      });
      _mobileCooldownTimer?.cancel();
      _mobileResendCooldown = 0;
    }
  }

  void _onEmailChanged() {
    if (_emailVerified && _email.text.trim() != _lastVerifiedEmail) {
      setState(() {
        _emailVerified = false;
        _emailOtpSent = false;
        _emailOtpController.clear();
      });
      _emailCooldownTimer?.cancel();
      _emailResendCooldown = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _aadharName.dispose();
    _mobile.removeListener(_onMobileChanged);
    _email.removeListener(_onEmailChanged);
    _mobile.dispose();
    _email.dispose();
    _hallTicket.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _mobileOtpController.dispose();
    _emailOtpController.dispose();
    _mobileCooldownTimer?.cancel();
    _emailCooldownTimer?.cancel();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentPage = page);
  }

  // --- Mobile OTP ---

  Future<void> _sendMobileOtp() async {
    final raw = _mobile.text.trim();
    if (raw.isEmpty) {
      _snack('Enter your mobile number first', error: true);
      return;
    }
    setState(() => _sendingMobileOtp = true);
    try {
      final normalized = OtpService.normalizePhone(raw);
      await OtpService.sendOtp(identifier: normalized, channel: 'mobile');
      if (!mounted) return;
      setState(() {
        _mobileOtpSent = true;
        _sendingMobileOtp = false;
      });
      _startMobileCooldown();
      _snack('OTP sent to your mobile number');
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendingMobileOtp = false);
      _snack('Failed to send OTP: ${e.toString()}', error: true);
    }
  }

  Future<void> _verifyMobileOtp() async {
    final code = _mobileOtpController.text.trim();
    if (code.isEmpty) {
      _snack('Enter the OTP sent to your mobile', error: true);
      return;
    }
    setState(() => _verifyingMobileOtp = true);
    try {
      final normalized = OtpService.normalizePhone(_mobile.text.trim());
      final ok = await OtpService.verifyOtp(
        identifier: normalized,
        otp: code,
        channel: 'mobile',
      );
      if (!mounted) return;
      setState(() => _verifyingMobileOtp = false);
      if (ok) {
        setState(() {
          _mobileVerified = true;
          _lastVerifiedMobile = _mobile.text.trim();
        });
        _mobileCooldownTimer?.cancel();
        _snack('Mobile number verified');
      } else {
        _snack('Incorrect OTP, please try again', error: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifyingMobileOtp = false);
      _snack('Verification failed: ${e.toString()}', error: true);
    }
  }

  void _startMobileCooldown() {
    _mobileCooldownTimer?.cancel();
    setState(() => _mobileResendCooldown = 30);
    _mobileCooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_mobileResendCooldown <= 1) {
        t.cancel();
        setState(() => _mobileResendCooldown = 0);
      } else {
        setState(() => _mobileResendCooldown--);
      }
    });
  }

  // --- Email OTP ---

  Future<void> _sendEmailOtp() async {
    final raw = _email.text.trim();
    if (raw.isEmpty) {
      _snack('Enter your email first', error: true);
      return;
    }
    setState(() => _sendingEmailOtp = true);
    try {
      await OtpService.sendOtp(identifier: raw, channel: 'email');
      if (!mounted) return;
      setState(() {
        _emailOtpSent = true;
        _sendingEmailOtp = false;
      });
      _startEmailCooldown();
      _snack('OTP sent to your email');
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendingEmailOtp = false);
      _snack('Failed to send OTP: ${e.toString()}', error: true);
    }
  }

  Future<void> _verifyEmailOtp() async {
    final code = _emailOtpController.text.trim();
    if (code.isEmpty) {
      _snack('Enter the OTP sent to your email', error: true);
      return;
    }
    setState(() => _verifyingEmailOtp = true);
    try {
      final ok = await OtpService.verifyOtp(
        identifier: _email.text.trim(),
        otp: code,
        channel: 'email',
      );
      if (!mounted) return;
      setState(() => _verifyingEmailOtp = false);
      if (ok) {
        setState(() {
          _emailVerified = true;
          _lastVerifiedEmail = _email.text.trim();
        });
        _emailCooldownTimer?.cancel();
        _snack('Email verified');
      } else {
        _snack('Incorrect OTP, please try again', error: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifyingEmailOtp = false);
      _snack('Verification failed: ${e.toString()}', error: true);
    }
  }

  void _startEmailCooldown() {
    _emailCooldownTimer?.cancel();
    setState(() => _emailResendCooldown = 30);
    _emailCooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_emailResendCooldown <= 1) {
        t.cancel();
        setState(() => _emailResendCooldown = 0);
      } else {
        setState(() => _emailResendCooldown--);
      }
    });
  }

  Future<void> _pickStudentId() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _studentIdPath = result.files.single.path;
      });
    }
  }

  Future<void> _pickProfilePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _profilePhotoPath = result.files.single.path;
      });
    }
  }

  Future<void> _register() async {
    if (_password.text != _confirmPassword.text) {
      _snack('Passwords do not match', error: true);
      return;
    }
    if (_studentIdPath == null) {
      _snack('Please upload your Student ID Card', error: true);
      return;
    }
    if (_profilePhotoPath == null) {
      _snack('Please upload your Profile Photo', error: true);
      return;
    }
    if (!_mobileVerified || !_emailVerified) {
      _snack('Please verify your mobile and email before submitting', error: true);
      return;
    }

    setState(() => _isLoading = true);

    final emailTarget = _email.text.trim();
    final mobileTarget = OtpService.normalizePhone(_mobile.text.trim());

    try {
      final student = StudentModel(
        id: '',
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        fullNameAadhar: _aadharName.text.trim(),
        mobile: mobileTarget,
        email: emailTarget,
        hallTicket: _hallTicket.text.trim(),
        universityId: _universityId ?? '1',
        collegeId: _collegeId ?? 'c_1',
        universityName: _university ?? '',
        collegeName: _college ?? '',
        course: _course ?? 'B.Tech',
        branch: _branch ?? 'CSE',
        semester: int.tryParse(_semester ?? '1') ?? 1,
        yearOfStudy: int.tryParse(_year ?? '1') ?? 1,
        gender: _gender ?? '',
        state: _state ?? '',
        // Both were already verified via OTP in Step 1.
        isMobileVerified: true,
        isEmailVerified: true,
        verificationStatus: 'Approved',
        isVerified: true,
        createdAt: DateTime.now(),
      );

      final response = await ref.read(authRepositoryProvider).register(
        student,
        _password.text,
        idCardPath: _studentIdPath!,
        profilePicPath: _profilePhotoPath!,
      );

      final user = response.user;
      if (user == null) throw Exception('Failed to sign up user.');

      await AppStorage.instance.clearSession();
      await Supabase.instance.client.auth.signOut();
      ref.read(currentStudentProvider.notifier).clear();

      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go(AppRoutes.login);
      _snack('Registration completed successfully! Please log in.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _snack('Failed to register: ${e.toString()}', error: true);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? AppColors.error : AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : () => context.pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('Step ${_currentPage + 1}/4')),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_page1(), _page2(), _page3(), _page4()],
      ),
    );
  }

  // Reusable OTP send / verify block, used for both mobile and email.
  Widget _otpVerificationBlock({
    required String label,
    required TextEditingController otpController,
    required bool sent,
    required bool verified,
    required bool sending,
    required bool verifying,
    required int cooldown,
    required VoidCallback onSend,
    required VoidCallback onVerify,
  }) {
    if (verified) {
      return const Padding(
        padding: EdgeInsets.only(top: 6, bottom: 4),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 18),
            SizedBox(width: 6),
            Text(
              'Verified',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (!sent) {
      return Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: sending ? null : onSend,
            icon: sending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sms_outlined, size: 16),
            label: Text(sending ? 'Sending OTP...' : 'Verify $label'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                isDense: true,
                counterText: '',
                hintText: 'Enter OTP',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: ElevatedButton(
              onPressed: verifying ? null : onVerify,
              child: verifying
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Verify'),
            ),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: cooldown > 0 ? null : onSend,
            child: Text(cooldown > 0 ? 'Resend (${cooldown}s)' : 'Resend'),
          ),
        ],
      ),
    );
  }

  Widget _page1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(label: 'First Name', controller: _firstName, isRequired: true),
          const SizedBox(height: 12),
          CustomTextField(label: 'Last Name / Surname', controller: _lastName, isRequired: true),
          const SizedBox(height: 12),
          CustomTextField(label: 'Full Name (Aadhaar)', controller: _aadharName, isRequired: true),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Mobile',
            controller: _mobile,
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
          _otpVerificationBlock(
            label: 'Mobile',
            otpController: _mobileOtpController,
            sent: _mobileOtpSent,
            verified: _mobileVerified,
            sending: _sendingMobileOtp,
            verifying: _verifyingMobileOtp,
            cooldown: _mobileResendCooldown,
            onSend: _sendMobileOtp,
            onVerify: _verifyMobileOtp,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          _otpVerificationBlock(
            label: 'Email',
            otpController: _emailOtpController,
            sent: _emailOtpSent,
            verified: _emailVerified,
            sending: _sendingEmailOtp,
            verifying: _verifyingEmailOtp,
            cooldown: _emailResendCooldown,
            onSend: _sendEmailOtp,
            onVerify: _verifyEmailOtp,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _college,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Select College'),
            items: _colleges.map((c) {
              final label = c.district != null ? '${c.name} — ${c.district}' : c.name;
              return DropdownMenuItem(value: c.name, child: Text(label));
            }).toList(),
            onChanged: _onCollegeSelected,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Next: Academic Info',
            onPressed: () {
              if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty || _aadharName.text.trim().isEmpty) {
                _snack('Please fill in First Name, Last Name and Aadhaar Name', error: true);
                return;
              }
              if (_mobile.text.trim().isEmpty || _email.text.trim().isEmpty) {
                _snack('Please fill in Mobile and Email', error: true);
                return;
              }
              if (!_mobileVerified) {
                _snack('Please verify your mobile number', error: true);
                return;
              }
              if (!_emailVerified) {
                _snack('Please verify your email', error: true);
                return;
              }
              if (_college == null) {
                _snack('Please select College', error: true);
                return;
              }
              _goToPage(1);
            },
          ),
        ],
      ),
    );
  }

  Widget _page2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _dropdown('Course', _course, ['B.Tech', 'M.Tech', 'MBA'], (v) => setState(() => _course = v)),
          const SizedBox(height: 12),
          CustomTextField(label: 'Hall Ticket', controller: _hallTicket, isRequired: true),
          const SizedBox(height: 12),
          _dropdown('Branch', _branch, ['CSE', 'ECE', 'EEE', 'MECH'], (v) => setState(() => _branch = v)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _dropdown('Year', _year, ['1', '2', '3', '4'], (v) => setState(() => _year = v))),
              const SizedBox(width: 12),
              Expanded(child: _dropdown('Semester', _semester, ['1', '2'], (v) => setState(() => _semester = v))),
            ],
          ),
          const SizedBox(height: 12),
          _dropdown('Gender', _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v)),
          const SizedBox(height: 12),
          _dropdown('State', _state, ['Telangana', 'Andhra Pradesh', 'Karnataka'], (v) => setState(() => _state = v)),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Next: Security & OTP',
            onPressed: () {
              if (_hallTicket.text.trim().isEmpty) {
                _snack('Please fill in your Hall Ticket', error: true);
                return;
              }
              if (_course == null || _branch == null || _year == null || _semester == null) {
                _snack('Please fill in all academic details', error: true);
                return;
              }
              _goToPage(2);
            },
          ),
        ],
      ),
    );
  }

  Widget _page3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(label: 'Password', controller: _password, isPassword: true, isRequired: true),
          const SizedBox(height: 12),
          CustomTextField(label: 'Confirm Password', controller: _confirmPassword, isPassword: true, isRequired: true),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Next: Upload Documents',
            onPressed: () {
              if (_password.text.isEmpty || _confirmPassword.text.isEmpty) {
                _snack('Please enter password and confirm it', error: true);
                return;
              }
              if (_password.text != _confirmPassword.text) {
                _snack('Passwords do not match', error: true);
                return;
              }
              _goToPage(3);
            },
          ),
        ],
      ),
    );
  }

  Widget _page4() {
    final studentIdName = _studentIdPath != null ? _studentIdPath!.split(Platform.pathSeparator).last : 'No file selected';
    final profilePhotoName = _profilePhotoPath != null ? _profilePhotoPath!.split(Platform.pathSeparator).last : 'No file selected';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identity Verification',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please upload your identity documents to submit your account for administrator approval.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Student ID Card',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    studentIdName,
                    style: TextStyle(color: _studentIdPath != null ? Colors.black87 : Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickStudentId,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose ID Card'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.account_box_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Profile Photo',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profilePhotoName,
                    style: TextStyle(color: _profilePhotoPath != null ? Colors.black87 : Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickProfilePhoto,
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Choose Photo'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Submit Registration',
            onPressed: _register,
            isLoading: _isLoading,
            icon: Icons.done_all,
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }
}
