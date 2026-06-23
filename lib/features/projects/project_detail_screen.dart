import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final row = await Supabase.instance.client
          .from('projects')
          .select()
          .eq('id', widget.projectId)
          .maybeSingle();
      if (mounted) setState(() { _data = row; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color get _diffColor {
    switch (_data?['difficulty']) {
      case 'easy': return AppColors.success;
      case 'hard': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      appBar: AppBar(
        title: Text(d?['title'] ?? 'Project'),
        backgroundColor: AppColors.projects,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.projects))
          : d == null
              ? const Center(child: Text('Project not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _chip(d['project_type'] ?? '', AppColors.projects),
                          const SizedBox(width: 8),
                          if (d['difficulty'] != null) _chip(d['difficulty'], _diffColor),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(d['title'] ?? '',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins')),
                      if (d['domain'] != null) ...[
                        const SizedBox(height: 8),
                        _row(Icons.category_rounded, d['domain']),
                      ],
                      if (d['branch'] != null) _row(Icons.school_rounded, d['branch']),
                      if (d['reward_points'] != null)
                        _row(Icons.stars_rounded, '${d['reward_points']} reward points'),
                      const SizedBox(height: 20),
                      if (d['description'] != null) ...[
                        const Text('Description',
                            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Text(d['description'],
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontFamily: 'Poppins')),
                        const SizedBox(height: 20),
                      ],
                      if (d['tools_required'] != null) ...[
                        const Text('Tools / Tech Stack',
                            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Text(d['tools_required'],
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontFamily: 'Poppins')),
                        const SizedBox(height: 24),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.projects,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.upload_file_rounded),
                          label: const Text('Submit Project',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ].animate(interval: 60.ms).fadeIn().slideY(begin: 0.1),
                  ),
                ),
    );
  }

  Widget _chip(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
      );

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontFamily: 'Poppins')),
          ),
        ]),
      );
}
