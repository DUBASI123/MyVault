import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../../shared/widgets/custom_button.dart';
import '../auth/data/auth_repository.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Projects', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textLight,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'College Based'),
                    Tab(text: 'Self Projects'),
                    Tab(text: 'Upload'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_collegeTab(), _selfTab(), _uploadTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _collegeTab() {
    if (_branch != null && _selectedCategory != null) {
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
            initialValue: _branch,
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
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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

  Widget _uploadTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push(AppRoutes.uploadProject),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text('Tap to submit your project statement', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                  SizedBox(height: 4),
                  Text('Earn rewards and certificates', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Submit Project',
            onPressed: () => context.push(AppRoutes.uploadProject),
            icon: Icons.upload_file_outlined,
          ),
        ],
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
