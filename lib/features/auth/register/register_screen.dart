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

  @override
  void dispose() {
    _pageController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _aadharName.dispose();
    _mobile.dispose();
    _email.dispose();
    _hallTicket.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
