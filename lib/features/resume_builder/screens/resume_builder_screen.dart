import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../auth/data/auth_repository.dart';
import '../models/resume_model.dart';
import '../services/resume_pdf_service.dart';

class ResumeBuilderScreen extends ConsumerStatefulWidget {
  const ResumeBuilderScreen({super.key});

  @override
  ConsumerState<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends ConsumerState<ResumeBuilderScreen> {
  late final _nameCtrl = TextEditingController();
  late final _emailCtrl = TextEditingController();
  late final _phoneCtrl = TextEditingController();
  late final _locationCtrl = TextEditingController(text: 'Hyderabad, India');
  late final _githubCtrl = TextEditingController(text: 'github.com/student');
  late final _linkedinCtrl = TextEditingController(text: 'linkedin.com/in/student');
  late final _summaryCtrl = TextEditingController(
      text: 'Passionate engineering student with expertise in mobile software development, databases, and APIs.');
  late final _collegeCtrl = TextEditingController();
  late final _degreeCtrl = TextEditingController(text: 'B.Tech');
  late final _branchCtrl = TextEditingController();
  late final _yearCtrl = TextEditingController(text: '2025');
  late final _cgpaCtrl = TextEditingController(text: '8.5 / 10.0');
  late final _skillsCtrl = TextEditingController(text: 'Flutter, Dart, Node.js, PostgreSQL, Git');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final student = ref.read(currentStudentProvider);
      if (student != null) {
        setState(() {
          _nameCtrl.text = student.displayName;
          _emailCtrl.text = student.email;
          _phoneCtrl.text = student.mobile;
          _collegeCtrl.text = student.collegeName;
          _branchCtrl.text = student.branch;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _githubCtrl.dispose();
    _linkedinCtrl.dispose();
    _summaryCtrl.dispose();
    _collegeCtrl.dispose();
    _degreeCtrl.dispose();
    _branchCtrl.dispose();
    _yearCtrl.dispose();
    _cgpaCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  ResumeModel _buildModel() {
    return ResumeModel(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      github: _githubCtrl.text.trim(),
      linkedin: _linkedinCtrl.text.trim(),
      summary: _summaryCtrl.text.trim(),
      college: _collegeCtrl.text.trim(),
      degree: _degreeCtrl.text.trim(),
      branch: _branchCtrl.text.trim(),
      yearOfGraduation: _yearCtrl.text.trim(),
      cgpa: _cgpaCtrl.text.trim(),
      skills: _skillsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      projects: [
        ResumeProject(
          title: 'MyVault Academic Platform',
          description: 'Full stack academic solution built with Flutter, Riverpod, PostgreSQL, and AWS S3.',
          technologies: 'Flutter, Dart, Node.js, PostgreSQL',
        ),
      ],
      experiences: [
        ResumeExperience(
          role: 'Software Development Intern',
          company: 'MyVault Tech',
          duration: '2024 - Present',
          highlights: 'Designed and deployed mobile applications and backend REST APIs.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Smart Resume Builder',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Build & Export Professional PDF Resume',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your details are auto-filled from your profile.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),

            _field('Full Name', _nameCtrl),
            _field('Email Address', _emailCtrl),
            _field('Mobile Number', _phoneCtrl),
            _field('Location', _locationCtrl),
            _field('GitHub Profile', _githubCtrl),
            _field('LinkedIn Profile', _linkedinCtrl),
            _field('Summary', _summaryCtrl, maxLines: 3),
            _field('College / University', _collegeCtrl),
            _field('Branch / Specialization', _branchCtrl),
            _field('CGPA', _cgpaCtrl),
            _field('Technical Skills (Comma separated)', _skillsCtrl),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final resume = _buildModel();
                  ResumePdfService.printOrExport(resume);
                },
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                label: const Text(
                  'Preview & Export PDF Resume',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins'),
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
