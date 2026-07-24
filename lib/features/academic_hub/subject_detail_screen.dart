import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/file_action_handler.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  final String categoryName;
  final List<String> dbTypes;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.categoryName,
    required this.dbTypes,
  });

  @override
  ConsumerState<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends ConsumerState<SubjectDetailScreen> {
  List<Map<String, dynamic>> _resources = [];
  Map<String, dynamic>? _subject;
  bool _loading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sub = await Supabase.instance.client
          .from('subjects')
          .select()
          .eq('id', widget.subjectId)
          .maybeSingle();

      var list = <Map<String, dynamic>>[];

      try {
        var query = Supabase.instance.client
            .from('academic_contents')
            .select()
            .eq('subject_id', widget.subjectId);

        if (widget.dbTypes.isNotEmpty) {
          query = query.inFilter('content_type', widget.dbTypes);
        }

        final res = await query.order('unit_number');
        list = List<Map<String, dynamic>>.from(res);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _subject = sub;
          _resources = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showUploadModal() async {
    final titleController = TextEditingController();
    String selectedType = widget.dbTypes.isNotEmpty ? widget.dbTypes.first : 'notes';
    PlatformFile? pickedFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload File for ${widget.categoryName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'File Title (e.g. Unit 1 Notes)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title_rounded, color: AppColors.academicHub),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Category / Content Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.category_rounded, color: AppColors.academicHub),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'notes', child: Text('Lecture Notes / Slides')),
                      DropdownMenuItem(value: 'syllabus', child: Text('Syllabus & Blueprint')),
                      DropdownMenuItem(value: 'question_paper', child: Text('Previous Question Paper')),
                      DropdownMenuItem(value: 'assignment', child: Text('Assignment / Lab Manual')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'txt'],
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setModalState(() => pickedFile = result.files.first);
                        if (titleController.text.isEmpty) {
                          titleController.text = result.files.first.name;
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.academicHub, width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.academicHub.withValues(alpha: 0.05),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_upload_rounded, color: AppColors.academicHub),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              pickedFile != null ? pickedFile!.name : 'Tap to select PDF / Document file',
                              style: TextStyle(
                                color: pickedFile != null ? AppColors.textPrimary : AppColors.textSecondary,
                                fontWeight: pickedFile != null ? FontWeight.w600 : FontWeight.normal,
                                fontFamily: 'Poppins',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_isUploading || pickedFile == null)
                          ? null
                          : () async {
                              final title = titleController.text.trim();
                              if (title.isEmpty) return;

                              Navigator.pop(ctx);
                              await _performFileUpload(pickedFile!, title, selectedType);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.academicHub,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Upload to Subject', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performFileUpload(PlatformFile file, String title, String contentType) async {
    setState(() => _isUploading = true);

    try {
      String fileUrl = '';

      // Try uploading to Supabase Storage bucket
      try {
        final bytes = file.bytes;
        final path = 'academic/${widget.subjectId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

        if (bytes != null) {
          await Supabase.instance.client.storage.from('documents').uploadBinary(path, bytes);
        } else if (file.path != null) {
          final ioFile = File(file.path!);
          await Supabase.instance.client.storage.from('documents').upload(path, ioFile);
        }
        fileUrl = Supabase.instance.client.storage.from('documents').getPublicUrl(path);
      } catch (_) {
        fileUrl = file.path ?? '';
      }

      // Insert record to academic_contents table
      final newRecord = {
        'id': 'ac_${DateTime.now().millisecondsSinceEpoch}',
        'subject_id': widget.subjectId,
        'title': title,
        'content_type': contentType,
        'file_url': fileUrl,
        'file_name': file.name,
        'unit_number': 1,
        'created_at': DateTime.now().toIso8601String(),
      };

      try {
        await Supabase.instance.client.from('academic_contents').insert(newRecord);
      } catch (_) {}

      // Add to local state list immediately
      if (mounted) {
        setState(() {
          _resources.insert(0, newRecord);
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ "$title" uploaded successfully to ${widget.categoryName}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_subject != null
            ? '${_subject!['name']} - ${widget.categoryName}'
            : widget.categoryName),
        backgroundColor: AppColors.academicHub,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadModal,
        backgroundColor: AppColors.academicHub,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Upload File', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.academicHub))
          : _resources.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'No resources available yet.',
                        style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showUploadModal,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text('Upload First Subject File'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.academicHub,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resources.length,
                  itemBuilder: (context, i) {
                    final r = _resources[i];
                    final contentType = r['content_type'] ?? r['contentType'] ?? r['resource_type'] ?? 'resource';
                    final formattedType = contentType.toString().replaceAll('_', ' ').toUpperCase();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: r['file_url'] != null
                            ? () => FileActionHandler.handleFileTap(
                                  context: context,
                                  fileUrl: _resolveFileUrl(r['file_url'] as String?),
                                  fileName: _buildFileName(r),
                                )
                            : null,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.academicHub.withValues(alpha: 0.1),
                          child: const Icon(Icons.file_present_rounded,
                              color: AppColors.academicHub),
                        ),
                        title: Text(r['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        subtitle: Text(formattedType,
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 11)),
                        trailing: r['file_url'] != null
                            ? const Icon(Icons.remove_red_eye_rounded, color: AppColors.primary)
                            : null,
                      ),
                    ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1);
                  },
                ),
    );
  }

  String _buildFileName(Map<String, dynamic> r) {
    final storedName = r['file_name'] as String? ?? r['original_file_name'] as String? ?? '';
    if (storedName.isNotEmpty && storedName.contains('.')) return storedName;

    final url = r['file_url'] as String? ?? '';
    String ext = '';
    try {
      final uri = Uri.parse(url);
      final pathParts = uri.path.split('/');
      final lastSegment = pathParts.last.split('?').first;
      if (lastSegment.contains('.')) {
        ext = '.${lastSegment.split('.').last.toLowerCase()}';
      }
    } catch (_) {}

    if (ext.isEmpty) {
      final ct = r['content_type'] as String? ?? '';
      if (ct.contains('pdf') || ct == 'slides' || ct == 'notes') ext = '.pdf';
      if (ct == 'video') ext = '.mp4';
    }

    final title = r['title'] as String? ?? 'document';
    return '$title$ext';
  }

  String _resolveFileUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return 'https://college-admin-portal-zdet.onrender.com$cleanUrl';
  }
}
