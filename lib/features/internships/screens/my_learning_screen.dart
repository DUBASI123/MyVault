// ============================================================
// screens/my_learning_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/internship_models.dart';
import '../providers/internship_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class MyLearningScreen extends ConsumerStatefulWidget {
  const MyLearningScreen({super.key});

  @override
  ConsumerState<MyLearningScreen> createState() => _MyLearningScreenState();
}

class _MyLearningScreenState extends ConsumerState<MyLearningScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tab,
            labelColor: AppColors.internships,
            unselectedLabelColor: AppColors.textLight,
            indicatorColor: AppColors.internships,
            labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
            tabs: const [
              Tab(text: 'My Courses'),
              Tab(text: 'Certificates'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _MyCoursesTab(),
              _MyCertificatesTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _MyCoursesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(myEnrolledCoursesProvider);

    return progressAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.internships)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (progressList) {
        if (progressList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school_outlined, size: 64, color: AppColors.textLight),
                const SizedBox(height: 16),
                const Text('No courses yet',
                    style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const Text('Browse the Courses tab to enroll!',
                    style: TextStyle(color: AppColors.textLight, fontFamily: 'Poppins', fontSize: 12)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myEnrolledCoursesProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: progressList.length,
            itemBuilder: (_, i) => _ProgressCard(progress: progressList[i])
                .animate(delay: Duration(milliseconds: i * 60))
                .fadeIn()
                .slideY(begin: 0.1),
          ),
        );
      },
    );
  }
}

class _ProgressCard extends ConsumerWidget {
  final StudentCourseProgress progress;
  const _ProgressCard({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(progress.courseId));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: courseAsync.when(
        loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
        error: (e, _) => Text('Course unavailable: $e', style: const TextStyle(color: AppColors.textLight)),
        data: (course) {
          final totalVideos = course.sections.fold(0, (s, sec) => s + sec.videos.length);
          final completed = progress.completedVideoIds.length;
          final progressPct = totalVideos > 0 ? completed / totalVideos : 0.0;
          final isCertified = progress.status == CourseStatus.certified;
          final isCompleted = progress.status == CourseStatus.completed || isCertified;

          Color statusColor;
          String statusText;
          IconData statusIcon;
          if (progress.status == CourseStatus.certified) {
            statusColor = AppColors.success;
            statusText = 'Certified';
            statusIcon = Icons.workspace_premium_rounded;
          } else if (progress.status == CourseStatus.completed) {
            statusColor = AppColors.internships;
            statusText = 'Ready for Test';
            statusIcon = Icons.quiz_rounded;
          } else if (progress.status == CourseStatus.inProgress) {
            statusColor = AppColors.primary;
            statusText = 'In Progress';
            statusIcon = Icons.play_circle_rounded;
          } else {
            statusColor = AppColors.textLight;
            statusText = 'Not Started';
            statusIcon = Icons.radio_button_unchecked;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.title,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins', fontSize: 14),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(course.category,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusText, style: TextStyle(fontSize: 11, color: statusColor,
                            fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress bar
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPct,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCertified ? AppColors.success : AppColors.internships,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('$completed/$totalVideos', style: const TextStyle(fontSize: 11,
                      color: AppColors.textSecondary, fontFamily: 'Poppins')),
                ],
              ),
              const SizedBox(height: 12),
              // CTA
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(AppRoutes.courseDetail, extra: progress.courseId),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('Continue', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                    ),
                  ),
                  if (isCompleted && !isCertified) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.courseTest, extra: progress.courseId),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.internships,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Take Test', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                      ),
                    ),
                  ],
                  if (isCertified) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(AppRoutes.certificateView, extra: progress.courseId),
                        icon: const Icon(Icons.card_membership_rounded, size: 14),
                        label: const Text('Certificate', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MyCertificatesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certsAsync = ref.watch(myCertificatesProvider);

    return certsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.internships)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (certs) {
        if (certs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium_outlined, size: 64, color: AppColors.textLight),
                SizedBox(height: 16),
                Text('No certificates yet', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Text('Complete a course and pass the test!', style: TextStyle(color: AppColors.textLight, fontFamily: 'Poppins', fontSize: 12)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: certs.length,
          itemBuilder: (_, i) {
            final cert = certs[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFF8DC), Color(0xFFFFFAE6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD700),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(cert.grade, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16,
                        color: Colors.white, fontFamily: 'Poppins')),
                  ),
                ),
                title: Text(cert.courseTitle, style: const TextStyle(fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF1A1D3B))),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('${cert.testScore}/${cert.testMaxScore} marks • ${cert.scorePercentage.round()}%',
                        style: TextStyle(color: Colors.brown[600], fontFamily: 'Poppins', fontSize: 12)),
                    Text('Issued ${DateFormat('d MMM yyyy').format(cert.issuedAt)}',
                        style: const TextStyle(color: Colors.brown, fontFamily: 'Poppins', fontSize: 11)),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFFFD700)),
                  onPressed: () => context.push(AppRoutes.certificateView, extra: cert.courseId),
                ),
              ),
            ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1);
          },
        );
      },
    );
  }
}
