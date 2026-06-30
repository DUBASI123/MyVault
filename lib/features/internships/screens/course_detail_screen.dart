// ============================================================
// screens/course_detail_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/internship_models.dart';
import '../providers/internship_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _enrolling = false;
  final Set<int> _expandedSections = {0};

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final progressAsync = ref.watch(courseProgressProvider(widget.courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.internships)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (course) {
          final progress = progressAsync.value;
          final isEnrolled = progress != null;
          final isCertified = progress?.status == CourseStatus.certified;
          final isCompleted = progress?.status == CourseStatus.completed || isCertified;

          final totalVideos = course.sections.fold(0, (s, sec) => s + sec.videos.length);
          final completedCount = progress?.completedVideoIds.length ?? 0;
          final progressPct = totalVideos > 0 ? completedCount / totalVideos : 0.0;

          return CustomScrollView(
            slivers: [
              // Hero AppBar with thumbnail
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.internships,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: course.thumbnailUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.thumbnailUrl,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withValues(alpha: 0.3),
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(color: AppColors.internships),
                        )
                      : Container(color: AppColors.internships),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.internships.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(course.category,
                            style: const TextStyle(color: AppColors.internships, fontFamily: 'Poppins',
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      Text(course.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins', color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text(course.subtitle,
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      const SizedBox(height: 16),

                      // Stats row
                      Row(
                        children: [
                          _statChip(Icons.play_circle_outline, '${course.totalVideos} videos'),
                          const SizedBox(width: 12),
                          _statChip(Icons.assignment_outlined, '${course.totalAssignments} tasks'),
                          const SizedBox(width: 12),
                          _statChip(Icons.star_rounded, '${course.rating}', color: const Color(0xFFFFB020)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Progress bar (if enrolled)
                      if (isEnrolled) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progress', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                            Text('$completedCount / $totalVideos videos',
                                style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPct,
                            minHeight: 8,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCertified ? AppColors.success : AppColors.internships,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Enroll / Take Test / View Certificate CTA
                      _buildCTA(course, progress, isEnrolled, isCompleted, isCertified, totalVideos),
                      const SizedBox(height: 24),

                      // Description
                      const Text('About this course',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                      const SizedBox(height: 8),
                      Text(course.description,
                          style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', height: 1.6)),
                      const SizedBox(height: 20),

                      // Skills
                      if (course.skillsYouLearn.isNotEmpty) ...[
                        const Text('What you\'ll learn',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: course.skillsYouLearn
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(s,
                                        style: const TextStyle(color: AppColors.primary, fontSize: 12,
                                            fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Curriculum
                      const Text('Curriculum',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Sections accordion
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final section = course.sections[i];
                    final expanded = _expandedSections.contains(i);
                    return _SectionTile(
                      section: section,
                      expanded: expanded,
                      isEnrolled: isEnrolled,
                      completedVideoIds: progress?.completedVideoIds ?? {},
                      submittedAssignmentIds: progress?.submittedAssignmentIds ?? {},
                      totalVideos: course.sections.fold(0, (s, sec) => s + sec.videos.length),
                      totalAssignments: course.totalAssignments,
                      courseId: widget.courseId,
                      onToggle: () => setState(() {
                        if (expanded) {
                          _expandedSections.remove(i);
                        } else {
                          _expandedSections.add(i);
                        }
                      }),
                    ).animate(delay: Duration(milliseconds: i * 40)).fadeIn();
                  },
                  childCount: course.sections.length,
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCTA(
    InternshipCourse course,
    StudentCourseProgress? progress,
    bool isEnrolled,
    bool isCompleted,
    bool isCertified,
    int totalVideos,
  ) {
    if (isCertified) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.certificateView, extra: widget.courseId),
              icon: const Icon(Icons.card_membership_rounded),
              label: const Text('View Certificate'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    }

    if (isCompleted) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF27AE60).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF27AE60)),
                SizedBox(width: 12),
                Expanded(
                  child: Text('All content completed! Take the final test to earn your certificate.',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Color(0xFF27AE60))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.courseTest, extra: widget.courseId),
              icon: const Icon(Icons.quiz_rounded),
              label: const Text('Take Final Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.internships,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      );
    }

    if (isEnrolled) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.internships.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.internships.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_rounded, color: AppColors.internships),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Keep watching videos and completing assignments to unlock the test.',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: AppColors.internships)),
            ),
          ],
        ),
      );
    }

    // Not enrolled
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _enrolling ? null : () => _enroll(course),
        icon: _enrolling
            ? const SizedBox(width: 18, height: 18,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.school_rounded),
        label: Text(_enrolling ? 'Enrolling...' : 'Enroll for Free'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.internships,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Future<void> _enroll(InternshipCourse course) async {
    setState(() => _enrolling = true);
    try {
      final repo = ref.read(internshipRepositoryProvider);
      await repo.enrollInCourse(widget.courseId);
      ref.invalidate(courseProgressProvider(widget.courseId));
      ref.invalidate(myEnrolledCoursesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enrolled in ${course.title}!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  Widget _statChip(IconData icon, String text, {Color color = AppColors.textSecondary}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontFamily: 'Poppins')),
      ],
    );
  }
}

// ─── Section Tile ────────────────────────────────────────────
class _SectionTile extends ConsumerWidget {
  final CourseSection section;
  final bool expanded;
  final bool isEnrolled;
  final Set<String> completedVideoIds;
  final Set<String> submittedAssignmentIds;
  final int totalVideos;
  final int totalAssignments;
  final String courseId;
  final VoidCallback onToggle;

  const _SectionTile({
    required this.section,
    required this.expanded,
    required this.isEnrolled,
    required this.completedVideoIds,
    required this.submittedAssignmentIds,
    required this.totalVideos,
    required this.totalAssignments,
    required this.courseId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.internships.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text('${section.orderIndex}',
                          style: const TextStyle(color: AppColors.internships, fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins', fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13)),
                        Text('${section.videos.length} videos • ${section.assignments.length} assignment',
                            style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                  Icon(expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.textLight),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            ...section.videos.map((video) => _VideoRow(
                  video: video,
                  isEnrolled: isEnrolled,
                  isCompleted: completedVideoIds.contains(video.id),
                  courseId: courseId,
                  totalVideos: totalVideos,
                  totalAssignments: totalAssignments,
                )),
            ...section.assignments.map((assignment) => _AssignmentRow(
                  assignment: assignment,
                  isEnrolled: isEnrolled,
                  isSubmitted: submittedAssignmentIds.contains(assignment.id),
                  courseId: courseId,
                  totalVideos: totalVideos,
                  totalAssignments: totalAssignments,
                )),
          ],
        ],
      ),
    );
  }
}

class _VideoRow extends ConsumerWidget {
  final CourseVideo video;
  final bool isEnrolled;
  final bool isCompleted;
  final String courseId;
  final int totalVideos;
  final int totalAssignments;

  const _VideoRow({
    required this.video,
    required this.isEnrolled,
    required this.isCompleted,
    required this.courseId,
    required this.totalVideos,
    required this.totalAssignments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canWatch = isEnrolled || video.isPreview;

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: isCompleted
            ? AppColors.success.withValues(alpha: 0.1)
            : (video.isPreview ? AppColors.internships.withValues(alpha: 0.1) : AppColors.border),
        child: Icon(
          isCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
          size: 18,
          color: isCompleted ? AppColors.success : (video.isPreview ? AppColors.internships : AppColors.textLight),
        ),
      ),
      title: Text(video.title,
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            color: canWatch ? AppColors.textPrimary : AppColors.textLight,
          )),
      subtitle: Row(
        children: [
          Text(video.formattedDuration,
              style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Poppins')),
          if (video.isPreview) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.internships.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('FREE', style: TextStyle(fontSize: 9, color: AppColors.internships, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
      trailing: canWatch
          ? (isCompleted
              ? null
              : IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.textLight),
                  tooltip: 'Mark as watched',
                  onPressed: () async {
                    // Launch video in browser
                    final url = Uri.parse(video.videoUrl);
                    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                    // Mark completed
                    await ref.read(courseProgressNotifierProvider.notifier).markVideoWatched(
                          courseId: courseId,
                          videoId: video.id,
                          totalVideos: totalVideos,
                          totalAssignments: totalAssignments,
                        );
                  },
                ))
          : const Icon(Icons.lock_outlined, size: 18, color: AppColors.textLight),
      onTap: canWatch
          ? () async {
              final url = Uri.parse(video.videoUrl);
              if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          : null,
    );
  }
}

class _AssignmentRow extends ConsumerWidget {
  final CourseAssignment assignment;
  final bool isEnrolled;
  final bool isSubmitted;
  final String courseId;
  final int totalVideos;
  final int totalAssignments;

  const _AssignmentRow({
    required this.assignment,
    required this.isEnrolled,
    required this.isSubmitted,
    required this.courseId,
    required this.totalVideos,
    required this.totalAssignments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: isSubmitted
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.1),
        child: Icon(
          isSubmitted ? Icons.check_rounded : Icons.assignment_rounded,
          size: 16,
          color: isSubmitted ? AppColors.success : AppColors.primary,
        ),
      ),
      title: Text(assignment.title,
          style: const TextStyle(fontSize: 13, fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
      subtitle: Text('Max ${assignment.maxScore} pts',
          style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Poppins')),
      trailing: isEnrolled && !isSubmitted
          ? TextButton(
              onPressed: () => _showSubmitDialog(context, ref),
              child: const Text('Submit', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            )
          : isSubmitted
              ? const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20)
              : null,
    );
  }

  Future<void> _showSubmitDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(assignment.title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(assignment.instructions,
                style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your submission',
                hintText: 'Paste a link or describe your work...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      await ref.read(courseProgressNotifierProvider.notifier).submitAssignment(
            courseId: courseId,
            assignmentId: assignment.id,
            submissionText: controller.text.trim(),
            attachmentUrls: [],
            totalVideos: totalVideos,
            totalAssignments: totalAssignments,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment submitted!'), backgroundColor: AppColors.success),
        );
      }
    }
  }
}
