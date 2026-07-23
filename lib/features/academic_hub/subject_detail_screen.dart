import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

      // If academic_contents is empty, fetch directly from cms_study_materials uploaded via CMS website
      if (list.isEmpty) {
        try {
          final cmsData = await Supabase.instance.client
              .from('cms_study_materials')
              .select()
              .eq('active', true)
              .order('created_at', ascending: false);

          final cmsList = (cmsData as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          if (cmsList.isNotEmpty) {
            list = cmsList;
          }
        } catch (_) {}
      }

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
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.academicHub))
          : _resources.isEmpty
              ? const Center(
                  child: Text(
                    'No resources available yet.',
                    style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'),
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

  /// Extracts extension from the file_url or file_name field and builds
  /// a properly-named filename so FileTypeUtils can detect the correct viewer.
  String _buildFileName(Map<String, dynamic> r) {
    // 1. Try explicit file_name column first
    final storedName = r['file_name'] as String? ?? r['original_file_name'] as String? ?? '';
    if (storedName.isNotEmpty && storedName.contains('.')) return storedName;

    // 2. Extract extension from the URL
    final url = r['file_url'] as String? ?? '';
    String ext = '';
    try {
      final uri = Uri.parse(url);
      final pathParts = uri.path.split('/');
      final lastSegment = pathParts.last.split('?').first; // strip query params
      if (lastSegment.contains('.')) {
        ext = '.${lastSegment.split('.').last.toLowerCase()}';
      }
    } catch (_) {}

    // 3. Fall back to content_type hint
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

