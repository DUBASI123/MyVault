import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/master_service.dart';
import '../../../shared/models/college_model.dart';
import '../../../shared/models/student_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../application/auth_providers.dart';


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

  // Registration state
  bool _aadharManuallyEdited = false;

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
    _firstName.addListener(_syncFullNameAadhar);
    _lastName.addListener(_syncFullNameAadhar);
  }

  // Auto-fills fullNameAadhar from first + last name as the user types.
  // If the student manually edits the Aadhar field afterwards, we stop overwriting.
  void _syncFullNameAadhar() {
    if (_aadharManuallyEdited) return;
    final combined =
        '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim();
    _aadharName.value = TextEditingValue(
      text: combined,
      selection: TextSelection.collapsed(offset: combined.length),
    );
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


  @override
  void dispose() {
    _pageController.dispose();
    _firstName.removeListener(_syncFullNameAadhar);
    _lastName.removeListener(_syncFullNameAadhar);
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

    final mobileTarget = _mobile.text.trim();

    try {
      final student = StudentModel(
        id: '',
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        fullNameAadhar: _aadharName.text.trim(),
        mobile: mobileTarget,
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
        verificationStatus: 'Approved',
        isVerified: true,
        createdAt: DateTime.now(),
      );

      // Use new AuthController to register through the unified auth module
      await ref.read(authControllerProvider.notifier).register({
        'fullName': student.fullName,
        'hallTicketNumber': student.hallTicket,
        'password': _password.text,
        'email': student.email,
        'phone': student.mobile,
        'university': student.collegeName,
        'courseType': 'btech',
        'semester': student.semester,
      });

      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/login');
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

  static Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _glassCard({required Widget child}) {
    return ClipRRect(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEDEBFB), Color(0xFFF7F5FF), Color(0xFFE3E8FC)],
              ),
            ),
          ),
          Positioned(top: -80, right: -60, child: _blob(220, const Color(0xFF6C63FF).withOpacity(0.25))),
          Positioned(bottom: -100, left: -80, child: _blob(260, const Color(0xFF4F46E5).withOpacity(0.18))),
          Positioned(top: 300, left: -40, child: _blob(140, const Color(0xFF9F97FF).withOpacity(0.18))),

          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFF1A1A2E)),
                        onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : () => context.pop(),
                      ),
                      Text(
                        'Create your vault',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          'Step ${_currentPage + 1}/4',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _glassContainer(_page1()),
                      _glassContainer(_page2()),
                      _glassContainer(_page3()),
                      _glassContainer(_page4()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassContainer(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _glassCard(child: child),
    );
  }

  Widget _page1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(label: 'First Name', controller: _firstName, isRequired: true),
        const SizedBox(height: 16),
        CustomTextField(label: 'Last Name / Surname', controller: _lastName, isRequired: true),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Full Name (Aadhaar)',
          controller: _aadharName,
          isRequired: true,
          onChanged: (_) => setState(() => _aadharManuallyEdited = true),
        ),
        if (_aadharManuallyEdited)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: GestureDetector(
              onTap: () {
                setState(() => _aadharManuallyEdited = false);
                _syncFullNameAadhar();
              },
              child: const Text(
                'Reset to first + last name',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF4F46E5),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Mobile',
          controller: _mobile,
          keyboardType: TextInputType.phone,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          isRequired: true,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _college,
          isExpanded: true,
          style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A1A2E), fontSize: 14),
          decoration: InputDecoration(
            labelText: 'Select College',
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
            ),
          ),
          items: _colleges.map((c) {
            final label = c.district != null ? '${c.name} — ${c.district}' : c.name;
            return DropdownMenuItem(value: c.name, child: Text(label));
          }).toList(),
          onChanged: _onCollegeSelected,
        ),
        const SizedBox(height: 28),
        CustomButton(
          text: 'Next: Academic Info',
          onPressed: () {
            if (_firstName.text.trim().isEmpty || _lastName.text.trim().isEmpty || _aadharName.text.trim().isEmpty) {
              _snack('Please fill in First Name, Last Name and Aadhaar Name', error: true);
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
    );
  }

  Widget _page2() {
    return Column(
      children: [
        _dropdown('Course', _course, ['B.Tech', 'M.Tech', 'MBA'], (v) => setState(() => _course = v)),
        const SizedBox(height: 16),
        CustomTextField(label: 'Hall Ticket', controller: _hallTicket, isRequired: true),
        const SizedBox(height: 16),
        _dropdown('Branch', _branch, ['CSE', 'ECE', 'EEE', 'MECH'], (v) => setState(() => _branch = v)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _dropdown('Year', _year, ['1', '2', '3', '4'], (v) => setState(() => _year = v))),
            const SizedBox(width: 12),
            Expanded(child: _dropdown('Semester', _semester, ['1', '2'], (v) => setState(() => _semester = v))),
          ],
        ),
        const SizedBox(height: 16),
        _dropdown('Gender', _gender, ['Male', 'Female', 'Other'], (v) => setState(() => _gender = v)),
        const SizedBox(height: 16),
        _dropdown('State', _state, ['Telangana', 'Andhra Pradesh', 'Karnataka'], (v) => setState(() => _state = v)),
        const SizedBox(height: 28),
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
    );
  }

  Widget _page3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(label: 'Password', controller: _password, isPassword: true, isRequired: true),
        const SizedBox(height: 16),
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
    );
  }

  Widget _page4() {
    final studentIdName = _studentIdPath != null ? _studentIdPath!.split(Platform.pathSeparator).last : 'No file selected';
    final profilePhotoName = _profilePhotoPath != null ? _profilePhotoPath!.split(Platform.pathSeparator).last : 'No file selected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identity Verification',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Please upload your identity documents to submit your account for administrator approval.',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 24),
        Card(
          elevation: 0,
          color: Colors.white.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.badge_outlined, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8),
                    Text(
                      'Student ID Card',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  studentIdName,
                  style: TextStyle(fontFamily: 'Poppins', color: _studentIdPath != null ? const Color(0xFF1A1A2E) : Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickStudentId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: const Text('Choose ID Card', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Colors.white.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_box_outlined, color: Color(0xFF4F46E5)),
                    SizedBox(width: 8),
                    Text(
                      'Profile Photo',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  profilePhotoName,
                  style: TextStyle(fontFamily: 'Poppins', color: _profilePhotoPath != null ? const Color(0xFF1A1A2E) : Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _pickProfilePhoto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                  label: const Text('Choose Photo', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
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
    );
  }

  Widget _dropdown(String label, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      style: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF1A1A2E), fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white.withOpacity(0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
        ),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }
}
