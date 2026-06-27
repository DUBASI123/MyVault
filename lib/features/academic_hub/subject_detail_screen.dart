import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../../../core/constants/app_colors.dart';

class SubjectDetailScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const SubjectDetailScreen({super.key, required this.subjectId});

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

      final res = await Supabase.instance.client
          .from('academic_contents')
          .select()
          .eq('subject_id', widget.subjectId)
          .order('unit_number');

      if (mounted) {
        setState(() {
          _subject = sub;
          _resources = List<Map<String, dynamic>>.from(res);
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
        title: Text(_subject?['name'] ?? 'Subject'),
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
                            ? () => _downloadAndOpenFile(
                                  context,
                                  _resolveFileUrl(r['file_url'] as String?),
                                  r['title'] as String? ?? 'document',
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
                            ? const Icon(Icons.download_rounded, color: AppColors.primary)
                            : null,
                      ),
                    ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1);
                  },
                ),
    );
  }

  String _resolveFileUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final cleanUrl = url.startsWith('/') ? url : '/$url';
    return 'https://college-admin-portal-zdet.onrender.com$cleanUrl';
  }

  Future<void> _downloadAndOpenFile(BuildContext context, String fileUrl, String title) async {
    // Show download progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Downloading file...', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final tempDir = await getTemporaryDirectory();
      
      // Derive file extension from URL or default to pdf
      String ext = 'pdf';
      try {
        final uri = Uri.parse(fileUrl);
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final last = pathSegments.last;
          if (last.contains('.')) {
            ext = last.split('.').last.toLowerCase();
          }
        }
      } catch (_) {}

      // Clean file name to prevent path escape issues
      final safeTitle = title.replaceAll(RegExp(r'[^\w\s\-]'), '_').trim();
      final savePath = '${tempDir.path}/${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final dio = Dio();
      await dio.download(fileUrl, savePath);

      // Close loading dialog
      if (context.mounted) Navigator.pop(context);

      // Open using native handler
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file: ${result.message}'),
            backgroundColor: AppColors.error,
          ),
        ); 
      }
    } catch (e) {
      // Close dialog
      if (context.mounted) Navigator.pop(context);
      
      debugPrint('Direct download failed, falling back to browser: $e');
      // Fallback: URL Launcher in browser
      final url = Uri.parse(fileUrl);
      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open file link: $err'),
              backgroundColor: AppColors.error,
            ),
          ); 
        }
      }
    }
  }
}

