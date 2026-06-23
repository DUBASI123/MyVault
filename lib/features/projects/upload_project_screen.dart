import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

class UploadProjectScreen extends ConsumerStatefulWidget {
  const UploadProjectScreen({super.key});

  @override
  ConsumerState<UploadProjectScreen> createState() => _UploadProjectScreenState();
}

class _UploadProjectScreenState extends ConsumerState<UploadProjectScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _projectType = 'self_project';
  String? _category = 'mini';
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a project title'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) throw Exception('Not logged in');

      final project = await Supabase.instance.client.from('projects').insert({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'project_type': _projectType,
        'category': _projectType == 'college_based' ? _category : null,
        'is_active': true,
      }).select().single();

      await Supabase.instance.client.from('project_submissions').insert({
        'student_id': uid,
        'project_id': project['id'],
        'status': 'submitted',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project submitted!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Project'),
        backgroundColor: AppColors.projects,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Project Title *'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _projectType,
              decoration: const InputDecoration(labelText: 'Project Type'),
              items: const [
                DropdownMenuItem(value: 'self_project', child: Text('Self Project')),
                DropdownMenuItem(value: 'college_based', child: Text('College Based')),
              ],
              onChanged: (v) => setState(() => _projectType = v),
            ),
            if (_projectType == 'college_based') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: const [
                  DropdownMenuItem(value: 'mini', child: Text('Mini Project')),
                  DropdownMenuItem(value: 'major', child: Text('Major Project')),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.projects,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.upload_file_rounded),
                label: const Text('Submit Project',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
