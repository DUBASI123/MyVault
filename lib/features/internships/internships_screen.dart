// ============================================================
// internships_screen.dart — rebuilt with 4 tabs
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';
import 'models/internship_models.dart';
import 'providers/internship_providers.dart';
import 'screens/courses_hub_screen.dart';
import 'screens/my_learning_screen.dart';

class InternshipsScreen extends ConsumerStatefulWidget {
  const InternshipsScreen({super.key});

  @override
  ConsumerState<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends ConsumerState<InternshipsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                const Text('Internships', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.internships,
                  unselectedLabelColor: AppColors.textLight,
                  indicatorColor: AppColors.internships,
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 12),
                  unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500, fontSize: 12),
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: const [
                    Tab(text: 'Opportunities'),
                    Tab(text: 'Courses'),
                    Tab(text: 'My Learning'),
                    Tab(text: 'Prep Videos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _OpportunitiesTab(),
                const CoursesHubScreen(),
                const MyLearningScreen(),
                _PrepVideosTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Opportunities Tab ────────────────────────────────────────
class _OpportunitiesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunitiesAsync = ref.watch(opportunitiesProvider(null));

    return opportunitiesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.internships)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (opportunities) {
        if (opportunities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.work_outline_rounded, size: 64, color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text('No opportunities yet', style: TextStyle(color: AppColors.textSecondary,
                    fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Check back soon for internship listings!',
                    style: TextStyle(color: AppColors.textLight, fontFamily: 'Poppins', fontSize: 12)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(opportunitiesProvider(null)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: opportunities.length,
            itemBuilder: (_, i) => _OpportunityCard(opportunity: opportunities[i])
                .animate(delay: Duration(milliseconds: i * 60))
                .fadeIn()
                .slideY(begin: 0.1),
          ),
        );
      },
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final InternshipOpportunity opportunity;
  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final typeColor = switch (opportunity.type) {
      OpportunityType.internship => AppColors.internships,
      OpportunityType.job => AppColors.primary,
      OpportunityType.freelance => AppColors.projects,
    };
    final typeLabel = opportunity.type.name[0].toUpperCase() + opportunity.type.name.substring(1);
    final daysLeft = opportunity.daysLeft;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Company logo
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: opportunity.companyLogoUrl.isNotEmpty
                        ? Image.network(opportunity.companyLogoUrl, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.business_rounded, color: AppColors.textLight, size: 24))
                        : const Icon(Icons.business_rounded, color: AppColors.textLight, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opportunity.companyName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 14)),
                      Text(opportunity.role,
                          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(typeLabel, style: TextStyle(fontSize: 11, color: typeColor,
                      fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Details chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(Icons.location_on_rounded, opportunity.isRemote ? 'Remote' : opportunity.location),
                _chip(Icons.access_time_rounded, opportunity.duration),
                _chip(Icons.currency_rupee_rounded, opportunity.stipend),
                if (daysLeft >= 0)
                  _chip(Icons.calendar_today_rounded, '$daysLeft days left',
                      color: daysLeft <= 7 ? AppColors.error : AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 12),

            // Required skills
            if (opportunity.requiredSkills.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: opportunity.requiredSkills
                    .take(4)
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(s, style: const TextStyle(fontSize: 10, color: AppColors.primary,
                              fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse(opportunity.applyUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: const Text('Apply Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.internships,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, {Color color = AppColors.textSecondary}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontFamily: 'Poppins')),
      ],
    );
  }
}

// ─── Prep Videos Tab (unchanged) ─────────────────────────────
class _PrepVideosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _prepVideos.length,
      itemBuilder: (context, i) {
        final video = _prepVideos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () async {
              final url = Uri.parse(video.youtubeUrl);
              if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnailUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.black12,
                        child: const Icon(Icons.video_library_rounded, size: 48, color: AppColors.textLight),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                        child: Text(video.duration,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(video.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(video.channel,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1);
      },
    );
  }
}

class _PrepVideo {
  final String title, channel, duration, youtubeUrl, thumbnailUrl;
  const _PrepVideo(this.title, this.channel, this.duration, this.youtubeUrl, this.thumbnailUrl);
}

const _prepVideos = [
  _PrepVideo('How to Get an Internship with No Experience', 'Programming with Mosh', '12:45',
      'https://www.youtube.com/watch?v=gT8q3Phs-6c', 'https://img.youtube.com/vi/gT8q3Phs-6c/0.jpg'),
  _PrepVideo('Ace Your Coding Interview: Tips & Tricks', 'Clever Programmer', '18:20',
      'https://www.youtube.com/watch?v=0h5o82-o_U4', 'https://img.youtube.com/vi/0h5o82-o_U4/0.jpg'),
  _PrepVideo('Write a Killer Resume for Internships', 'Jeff Su', '10:15',
      'https://www.youtube.com/watch?v=uG2aEH56aR4', 'https://img.youtube.com/vi/uG2aEH56aR4/0.jpg'),
  _PrepVideo('How to Find Remote Internships Globally', 'Clément Mihailescu', '15:30',
      'https://www.youtube.com/watch?v=Vl3l2PqJ-wI', 'https://img.youtube.com/vi/Vl3l2PqJ-wI/0.jpg'),
];
