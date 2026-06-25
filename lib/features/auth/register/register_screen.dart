import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/master_service.dart';
import '../../../shared/models/college_model.dart';
import '../../../shared/models/university_model.dart';
import '../../../core/services/otp_service.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/otp_verification_badge.dart';
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

  OtpBadgeStatus _mobileStatus = OtpBadgeStatus.pending;
  OtpBadgeStatus _emailStatus = OtpBadgeStatus.pending;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _aadharName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _hallTicket = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _mobileOtp = TextEditingController();
  final _emailOtp = TextEditingController();

  String? _university;
  String? _college;
  String? _universityId;
  String? _collegeId;
  List<UniversityModel> _universities = [];
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
    _mobile.addListener(_onMobileChanged);
    _email.addListener(_onEmailChanged);
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final unis = await MasterService.getUniversities();
      if (unis.isEmpty) {
        if (mounted) setState(() => _universities = MockData.universities);
      } else {
        if (mounted) setState(() => _universities = unis);
      }
    } catch (_) {
      if (mounted) setState(() => _universities = MockData.universities);
    }
  }

  Future<void> _onUniversitySelected(String? name) async {
    setState(() {
      _university = name;
      _college = null;
      _collegeId = null;
      _colleges = [];
    });
    if (name == null) return;
    final uni = _universities.where((u) => u.name == name).firstOrNull;
    if (uni == null) return;
    _universityId = uni.id;
    try {
      final cols = await MasterService.getColleges(uni.id);
      if (cols.isEmpty) {
        if (mounted) {
          setState(() => _colleges = MockData.colleges.where((c) => c.universityId == uni.id).toList());
        }
      } else {
        if (mounted) setState(() => _colleges = cols);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _colleges = MockData.colleges.where((c) => c.universityId == uni.id).toList());
      }
    }
  }

  void _onCollegeSelected(String? name) {
    setState(() {
      _college = name;
      _collegeId = _colleges.where((c) => c.name == name).firstOrNull?.id;
    });
  }

  void _onMobileChanged() {
    if (_mobileStatus != OtpBadgeStatus.pending) {
      setState(() {
        _mobileStatus = OtpBadgeStatus.pending;
        _mobileOtp.clear();
      });
    }
  }

  void _onEmailChanged() {
    if (_emailStatus != OtpBadgeStatus.pending) {
      setState(() {
        _emailStatus = OtpBadgeStatus.pending;
        _emailOtp.clear();
      });
    }
  }

  @override
  void dispose() {
    _mobile.removeListener(_onMobileChanged);
    _email.removeListener(_onEmailChanged);
    _pageController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _aadharName.dispose();
    _mobile.dispose();
    _email.dispose();
    _hallTicket.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _mobileOtp.dispose();
    _emailOtp.dispose();
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

  Future<void> _sendMobileOtp() async {
    final phone = _mobile.text.trim();
    if (phone.isEmpty) {
      _snack('Please enter your mobile number', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(authRepositoryProvider).sendOtp(
        OtpService.normalizePhone(phone),
        purpose: 'register',
      );
      setState(() {
        _mobileStatus = OtpBadgeStatus.sent;
      });
      _snack('OTP sent to $phone');
      if (res.otpPreview != null) {
        _snack('Dev preview OTP: ${res.otpPreview}', error: false);
      }
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyMobileOtp() async {
    final phone = _mobile.text.trim();
    final otp = _mobileOtp.text.trim();
    if (otp.isEmpty) {
      _snack('Please enter the mobile OTP', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final verified = await ref.read(authRepositoryProvider).verifyOtp(
        OtpService.normalizePhone(phone),
        otp,
        purpose: 'register',
      );
      if (verified) {
        setState(() {
          _mobileStatus = OtpBadgeStatus.verified;
        });
        _snack('Mobile number verified successfully!');
      } else {
        setState(() {
          _mobileStatus = OtpBadgeStatus.failed;
        });
        _snack('Incorrect mobile OTP code', error: true);
      }
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendEmailOtp() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      _snack('Please enter your email address', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await ref.read(authRepositoryProvider).sendOtp(
        email,
        purpose: 'register',
      );
      setState(() {
        _emailStatus = OtpBadgeStatus.sent;
      });
      _snack('OTP sent to $email');
      if (res.otpPreview != null) {
        _snack('Dev preview OTP: ${res.otpPreview}', error: false);
      }
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmailOtp() async {
    final email = _email.text.trim();
    final otp = _emailOtp.text.trim();
    if (otp.isEmpty) {
      _snack('Please enter the email OTP', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final verified = await ref.read(authRepositoryProvider).verifyOtp(
        email,
        otp,
        purpose: 'register',
      );
      if (verified) {
        setState(() {
          _emailStatus = OtpBadgeStatus.verified;
        });
        _snack('Email address verified successfully!');
      } else {
        setState(() {
          _emailStatus = OtpBadgeStatus.failed;
        });
        _snack('Incorrect email OTP code', error: true);
      }
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      setState(() => _isLoading = false);
    }
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
    if (_mobileStatus != OtpBadgeStatus.verified) {
      _snack('Please verify your mobile number first', error: true);
      return;
    }
    if (_emailStatus != OtpBadgeStatus.verified) {
      _snack('Please verify your email address first', error: true);
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

    setState(() => _isLoading = true);
    try {
      final student = StudentModel(
        id: '',
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        fullNameAadhar: _aadharName.text.trim(),
        mobile: OtpService.normalizePhone(_mobile.text.trim()),
        email: _email.text.trim(),
        hallTicket: _hallTicket.text.trim(),
        universityId: _universityId ?? '00000000-0000-0000-0000-000000000001',
        collegeId: _collegeId ?? '00000000-0000-0000-0000-000000000101',
        universityName: _university ?? '',
        collegeName: _college ?? '',
        course: _course ?? 'B.Tech',
        branch: _branch ?? 'CSE',
        semester: int.tryParse(_semester ?? '1') ?? 1,
        yearOfStudy: int.tryParse(_year ?? '1') ?? 1,
        gender: _gender ?? '',
        state: _state ?? '',
        isMobileVerified: true,
        isEmailVerified: true,
        verificationStatus: 'Pending',
        isVerified: false,
        createdAt: DateTime.now(),
      );
      await ref.read(authRepositoryProvider).register(
        student,
        _password.text,
        idCardPath: _studentIdPath!,
        profilePicPath: _profilePhotoPath!,
      );
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Registration Submitted'),
            content: const Text(
              'Your registration has been submitted successfully.\n\n'
              'Your account is awaiting college administrator approval. '
              'You will receive access after verification is complete.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.login);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Email',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          const SizedBox(height: 20),
          _dropdown('University', _university, _universities.map((u) => u.name).toList(), _onUniversitySelected),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _college,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'College'),
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
              if (_university == null) {
                _snack('Please select University', error: true);
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
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text('OTP Verification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile: ${_mobile.text}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        OtpVerificationBadge(status: _mobileStatus),
                      ],
                    ),
                  ],
                ),
              ),
              if (_mobileStatus == OtpBadgeStatus.pending || _mobileStatus == OtpBadgeStatus.failed)
                ElevatedButton(
                  onPressed: _sendMobileOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Send OTP'),
                ),
            ],
          ),
          if (_mobileStatus == OtpBadgeStatus.sent || _mobileStatus == OtpBadgeStatus.failed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Enter Mobile OTP',
                    controller: _mobileOtp,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _verifyMobileOtp,
                  child: const Text('Verify'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${_email.text}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        OtpVerificationBadge(status: _emailStatus),
                      ],
                    ),
                  ],
                ),
              ),
              if (_emailStatus == OtpBadgeStatus.pending || _emailStatus == OtpBadgeStatus.failed)
                ElevatedButton(
                  onPressed: _sendEmailOtp,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: const Text('Send OTP'),
                ),
            ],
          ),
          if (_emailStatus == OtpBadgeStatus.sent || _emailStatus == OtpBadgeStatus.failed) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Enter Email OTP',
                    controller: _emailOtp,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _verifyEmailOtp,
                  child: const Text('Verify'),
                ),
              ],
            ),
          ],
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
              if (_mobileStatus != OtpBadgeStatus.verified) {
                _snack('Please verify your mobile number first', error: true);
                return;
              }
              if (_emailStatus != OtpBadgeStatus.verified) {
                _snack('Please verify your email address first', error: true);
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
                      const SizedBox(width: 8),
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
                      const SizedBox(width: 8),
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
