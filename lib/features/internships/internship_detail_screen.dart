import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class InternshipDetailScreen extends StatefulWidget {
  final String internshipId;
  const InternshipDetailScreen({super.key, required this.internshipId});

  @override
  State<InternshipDetailScreen> createState() => _InternshipDetailScreenState();
}

class _InternshipDetailScreenState extends State<InternshipDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _applied = false;
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final client = Supabase.instance.client;
    try {
      final row = await client
          .from('internships')
          .select()
          .eq('id', widget.internshipId)
          .maybeSingle();

      final uid = client.auth.currentUser?.id;
      if (uid != null) {
        final app = await client
            .from('internship_applications')
            .select('id')
            .eq('student_id', uid)
            .eq('internship_id', widget.internshipId)
            .maybeSingle();
        if (mounted) setState(() => _applied = app != null);
      }

      if (mounted) setState(() { _data = row; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    setState(() => _applying = true);
    try {
      await Supabase.instance.client.from('internship_applications').insert({
        'student_id': uid,
        'internship_id': widget.internshipId,
      });
      if (mounted) {
        setState(() => _applied = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Applied successfully!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _data;
    return Scaffold(
      appBar: AppBar(
        title: Text(d?['title'] ?? 'Internship'),
        backgroundColor: AppColors.internships,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.internships))
          : d == null
              ? const Center(child: Text('Not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _chip(d['company_name'] ?? '', AppColors.internships),
                      const SizedBox(height: 16),
                      Text(d['title'] ?? '',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      _row(Icons.location_on_rounded, d['location'] ?? 'Remote'),
                      _row(Icons.access_time_rounded, d['duration'] ?? ''),
                      _row(Icons.currency_rupee_rounded, d['stipend'] ?? 'Unpaid'),
                      _row(Icons.laptop_mac_rounded, d['mode'] ?? ''),
                      if (d['deadline'] != null) _row(Icons.event_rounded, 'Deadline: ${d['deadline']}'),
                      const SizedBox(height: 20),
                      if (d['description'] != null) ...[
                        const Text('Description',
                            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Text(d['description'],
                            style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                        const SizedBox(height: 20),
                      ],
                      if (d['skills_required'] != null) ...[
                        const Text('Skills Required',
                            style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                        const SizedBox(height: 8),
                        Text(d['skills_required'],
                            style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                        const SizedBox(height: 24),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _applied || _applying
                              ? null
                              : d['apply_url'] != null
                                  ? () => launchUrl(Uri.parse(d['apply_url']))
                                  : _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _applied ? AppColors.success : AppColors.internships,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: _applying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(_applied ? Icons.check_circle_rounded : Icons.send_rounded),
                          label: Text(_applied ? 'Applied' : 'Apply Now',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
          Text(text,
              style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
        ]),
      );
}
