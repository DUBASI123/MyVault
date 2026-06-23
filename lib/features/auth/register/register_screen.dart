import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _register() async {
    if (_password.text != _confirmPassword.text) {
      _snack('Passwords do not match', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final student = StudentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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
        createdAt: DateTime.now(),
      );
      await ref.read(authRepositoryProvider).register(student, _password.text);
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Registration Successful'),
            content: const Text(
              'Your account has been created successfully.\n\n'
              'You can now log in immediately using your credentials.',
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
            child: Center(child: Text('Step ${_currentPage + 1}/3')),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_page1(), _page2(), _page3()],
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
          CustomButton(text: 'Next: Security', onPressed: () => _goToPage(2)),
        ],
      ),
    );
  }

  Widget _page3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CustomTextField(label: 'Password', controller: _password, isPassword: true, isRequired: true),
          const SizedBox(height: 12),
          CustomTextField(label: 'Confirm Password', controller: _confirmPassword, isPassword: true, isRequired: true),
          const SizedBox(height: 24),
          CustomButton(text: 'Create Account', onPressed: _register, isLoading: _isLoading, icon: Icons.person_add),
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
