import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
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
                            ? () async {
                                final urlString = r['file_url'] as String;
                                final url = Uri.parse(urlString);
                                try {
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } else {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not open file URL: $e')),
                                    );
                                  }
                                }
                              }
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
}

