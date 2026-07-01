import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/custom_button.dart';
import '../auth/data/auth_repository.dart';

class SubmitProjectWorkScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectTitle;

  const SubmitProjectWorkScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  ConsumerState<SubmitProjectWorkScreen> createState() => _SubmitProjectWorkScreenState();
}

class _SubmitProjectWorkScreenState extends ConsumerState<SubmitProjectWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _githubController = TextEditingController();
  final _demoController = TextEditingController();
  final _notesController = TextEditingController();

  PlatformFile? _selectedFile;
  bool _loading = false;

  @override
  void dispose() {
    _githubController.dispose();
    _demoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'zip', 'doc', 'docx', 'png', 'jpg'],
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() => _selectedFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final student = ref.read(currentStudentProvider);
      if (student == null) throw Exception('No student profile found.');

      // In a real application, we might upload the file to Supabase storage.
      // Here, we can simulate or upload it, and save the link.
      String? uploadUrl = _githubController.text;

      // Insert submission
      await Supabase.instance.client.from('project_submissions').insert({
        'student_id': student.id,
        'project_id': widget.projectId,
        'upload_url': uploadUrl,
        'demo_url': _demoController.text,
        'notes': _notesController.text,
        'status': 'submitted',
        'reward_points': 0, // initially 0, updated on approval
        'submitted_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project submitted successfully! Review will take 24-48h.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting project: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Submit Project',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.projectTitle,
                style: AppTextStyles.heading2.copyWith(color: AppColors.primaryLight),
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide your implementation links and attachments to complete the project statement and earn rewards.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _githubController,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  labelText: 'GitHub Repository URL *',
                  hintText: 'https://github.com/username/project',
                  prefixIcon: Icon(Icons.code_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'GitHub URL is required';
                  if (!val.startsWith('http://') && !val.startsWith('https://')) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _demoController,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Live Demo URL (Optional)',
                  hintText: 'https://project-demo.vercel.app',
                  prefixIcon: Icon(Icons.launch_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                style: const TextStyle(color: AppColors.textWhite),
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Submission Notes / Explanation',
                  hintText: 'Provide a brief summary of how you built the project and any setup instructions...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),
              // File Picker Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFile != null ? _selectedFile!.name : 'Additional Attachments',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _selectedFile != null ? AppColors.textWhite : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedFile != null
                                ? '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'
                                : 'PDF, ZIP, DOC (Max 10MB)',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file, size: 16),
                      label: Text(_selectedFile != null ? 'Change' : 'Browse'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textWhite,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Submit Work',
                onPressed: _submit,
                isLoading: _loading,
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
