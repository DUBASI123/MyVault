import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';
import '../../core/router/app_router.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  const ProjectsScreen({super.key});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _branch;
  String? _selectedCategory; // 'mini' or 'major'
  String? _selectedDomain;

  int _totalRewardPoints = 0;
  List<Map<String, dynamic>> _mySubmissions = [];
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final student = ref.read(currentStudentProvider);
    _branch = student?.branch ?? 'CSE';
    _fetchStatsAndSubmissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatsAndSubmissions() async {
    setState(() => _loadingStats = true);
    try {
      final student = ref.read(currentStudentProvider);
      if (student == null) return;

      // Query submissions joined with projects
      final response = await Supabase.instance.client
          .from('project_submissions')
          .select('*, projects(*)')
          .eq('student_id', student.id);

      final List<Map<String, dynamic>> subs = List<Map<String, dynamic>>.from(response);

      // Sum only approved submission points
      int totalPoints = 0;
      for (var sub in subs) {
        if (sub['status'] == 'approved') {
          // If points are recorded in submission, use that. Otherwise use project points.
          final subPts = sub['reward_points'] as int? ?? 0;
          final projPts = sub['projects']?['reward_points'] as int? ?? 0;
          totalPoints += subPts > 0 ? subPts : projPts;
        }
      }

      setState(() {
        _mySubmissions = subs;
        _totalRewardPoints = totalPoints;
      });
    } catch (e) {
      debugPrint('Error fetching project stats: $e');
    } finally {
      setState(() => _loadingStats = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollegeProjects() async {
    final res = await Supabase.instance.client
        .from('projects')
        .select()
        .eq('project_type', 'college_based')
        .eq('category', _selectedCategory!)
        .eq('branch', _branch!);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> _fetchSelfProjects() async {
    final res = await Supabase.instance.client
        .from('projects')
        .select()
        .eq('project_type', 'self_project')
        .eq('domain', _selectedDomain!);
    return List<Map<String, dynamic>>.from(res);
  }

  String _getRankBadge(int points) {
    if (points >= 1500) return 'Gold Developer';
    if (points >= 500) return 'Silver Innovator';
    return 'Bronze Creator';
  }

  Color _getRankColor(int points) {
    if (points >= 1500) return Colors.amber;
    if (points >= 500) return const Color(0xFFC0C0C0);
    return const Color(0xFFCD7F32);
  }

  int _getNextMilestone(int points) {
    if (points >= 1500) return 3000;
    if (points >= 500) return 1500;
    return 500;
  }

  Future<void> _generateProjectCertificate(String projectTitle) async {
    final student = ref.read(currentStudentProvider);
    final studentName = student?.displayName ?? 'Student';
    final collegeName = student?.collegeName ?? 'MyVault Academy';

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber700, width: 6),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('MyVault Credentials', style: pw.TextStyle(fontSize: 18, color: PdfColors.blueGrey700)),
                pw.SizedBox(height: 10),
                pw.Text('CERTIFICATE OF ACCOMPLISHMENT', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.amber800)),
                pw.SizedBox(height: 15),
                pw.Text('This is proudly presented to', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Text(studentName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                pw.SizedBox(height: 10),
                pw.Text('for successfully completing the project statement:', style: pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 8),
                pw.Text('"$projectTitle"', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.SizedBox(height: 15),
                pw.Text('Offered under the academic hub of $collegeName', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.Divider(color: PdfColors.amber700, thickness: 1.5, indent: 80, endIndent: 80),
                pw.SizedBox(height: 12),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(children: [pw.Text('MyVault Director'), pw.Text('Verified Digitally', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500))]),
                    pw.Column(children: [pw.Text(DateTime.now().toLocal().toString().substring(0, 10)), pw.Text('Date', style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500))]),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final rankBadge = _getRankBadge(_totalRewardPoints);
    final rankColor = _getRankColor(_totalRewardPoints);
    final nextMilestone = _getNextMilestone(_totalRewardPoints);
    final progress = _totalRewardPoints / nextMilestone;

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          // Rewards Wallet Header Hero Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: rankColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.stars, color: rankColor, size: 36),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rankBadge,
                          style: TextStyle(
                            color: rankColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalRewardPoints / $nextMilestone XP to next milestone',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress > 1.0 ? 1.0 : progress,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'College Based'),
                Tab(text: 'Self Projects'),
                Tab(text: 'Submissions'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _collegeTab(),
                _selfTab(),
                _submissionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _collegeTab() {
    if (_selectedCategory != null) {
      final categoryTitle = _selectedCategory == 'mini' ? 'Mini Projects' : 'Major Projects';
      return _projectsListFuture(
        _fetchCollegeProjects(),
        () => setState(() => _selectedCategory = null),
        '$_branch - $categoryTitle',
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _branch,
            decoration: const InputDecoration(labelText: 'Select Branch'),
            items: ['CSE', 'ECE', 'EEE', 'MECH']
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),
            onChanged: (v) => setState(() {
              _branch = v;
              _selectedCategory = null;
            }),
          ),
          if (_branch != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = 'mini'),
                    borderRadius: BorderRadius.circular(16),
                    child: _typeCard('Mini Projects', Icons.code),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = 'major'),
                    borderRadius: BorderRadius.circular(16),
                    child: _typeCard('Major Projects', Icons.rocket_launch),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _typeCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 36),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.heading3.copyWith(fontSize: 14), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _selfTab() {
    if (_selectedDomain != null) {
      return _projectsListFuture(
        _fetchSelfProjects(),
        () => setState(() => _selectedDomain = null),
        _selectedDomain!,
      );
    }

    final domains = ['Web Dev', 'Mobile Apps', 'AI/ML', 'IoT', 'Cloud'];
    final domainIcons = {
      'Web Dev': Icons.web_rounded,
      'Mobile Apps': Icons.phone_android_rounded,
      'AI/ML': Icons.psychology_rounded,
      'IoT': Icons.settings_input_antenna_rounded,
      'Cloud': Icons.cloud_queue_rounded,
    };

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: domains.length,
      itemBuilder: (_, i) {
        final d = domains[i];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () => setState(() => _selectedDomain = d),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(domainIcons[d] ?? Icons.code_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(height: 10),
                  Text(d, style: AppTextStyles.heading3.copyWith(fontSize: 13), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _submissionsTab() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_mySubmissions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, size: 48, color: AppColors.textSecondary),
              SizedBox(height: 12),
              Text(
                'No submissions yet',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Pick a project statement and submit it to see history.',
                style: TextStyle(color: AppColors.textLight, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchStatsAndSubmissions,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mySubmissions.length,
        itemBuilder: (context, index) {
          final sub = _mySubmissions[index];
          final project = sub['projects'] as Map<String, dynamic>?;
          final String title = project?['title'] ?? 'Self Project Submission';
          final String status = sub['status']?.toString() ?? 'submitted';
          final int rewardPoints = sub['reward_points'] as int? ?? 0;
          final int projPoints = project?['reward_points'] as int? ?? 0;
          final int finalPoints = rewardPoints > 0 ? rewardPoints : projPoints;

          Color statusColor = AppColors.warning;
          if (status == 'approved') statusColor = AppColors.success;
          if (status == 'rejected') statusColor = AppColors.error;

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '+$finalPoints XP',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (sub['upload_url'] != null)
                    Text(
                      'Repo: ${sub['upload_url']}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (status == 'approved') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _generateProjectCertificate(title),
                        icon: const Icon(Icons.workspace_premium_rounded, size: 16),
                        label: const Text('View Certificate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _projectsListFuture(Future<List<Map<String, dynamic>>> future, VoidCallback onBack, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                onPressed: onBack,
              ),
              Text(title, style: AppTextStyles.heading3),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(child: Text('Error: ${snap.error}'));
              }
              final list = snap.data ?? [];
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'No project statements uploaded yet.',
                    style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final p = list[i];
                  final diff = p['difficulty'] as String? ?? 'medium';
                  Color diffColor = AppColors.warning;
                  if (diff == 'easy') diffColor = AppColors.success;
                  if (diff == 'hard') diffColor = AppColors.error;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(
                        p['title'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins'),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: diffColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  diff.toUpperCase(),
                                  style: TextStyle(color: diffColor, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${p['reward_points'] ?? 0} pts',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.primary),
                      onTap: () => context.push(AppRoutes.projectDetail, extra: p['id'] as String),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
