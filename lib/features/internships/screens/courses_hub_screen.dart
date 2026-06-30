// ============================================================
// screens/courses_hub_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/internship_models.dart';
import '../providers/internship_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';


const _categories = ['All', 'Web Development', 'Data Science', 'UI/UX Design', 'Mobile Development'];

class CoursesHubScreen extends ConsumerStatefulWidget {
  const CoursesHubScreen({super.key});

  @override
  ConsumerState<CoursesHubScreen> createState() => _CoursesHubScreenState();
}

class _CoursesHubScreenState extends ConsumerState<CoursesHubScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider(_selectedCategory == 'All' ? null : _selectedCategory));

    return Column(
      children: [
        // Category filter chips
        SizedBox(
          height: 50,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final selected = cat == _selectedCategory;
              return FilterChip(
                label: Text(cat, style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                )),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
                selectedColor: AppColors.internships,
                backgroundColor: AppColors.surface,
                side: BorderSide(color: selected ? AppColors.internships : AppColors.border),
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: coursesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.internships)),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (courses) {
              if (courses.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 64, color: AppColors.textLight),
                      SizedBox(height: 16),
                      Text('No courses yet', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      SizedBox(height: 8),
                      Text('Check back soon!', style: TextStyle(color: AppColors.textLight, fontFamily: 'Poppins', fontSize: 12)),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: courses.length,
                itemBuilder: (_, i) => _CourseCard(course: courses[i])
                    .animate(delay: Duration(milliseconds: i * 60))
                    .fadeIn()
                    .slideY(begin: 0.1),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  final InternshipCourse course;
  // ignore: prefer_const_constructors_in_immutables
  _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final diffColor = course.difficulty == DifficultyLevel.beginner
        ? const Color(0xFF27AE60)
        : course.difficulty == DifficultyLevel.intermediate
            ? const Color(0xFFF39C12)
            : const Color(0xFFE74C3C);
    final diffLabel = course.difficulty.name[0].toUpperCase() + course.difficulty.name.substring(1);
    final hours = course.durationMinutes ~/ 60;
    final mins = course.durationMinutes % 60;
    final durationStr = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push(AppRoutes.courseDetail, extra: course.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: course.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: course.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _thumbnailFallback(course.category),
                      )
                    : _thumbnailFallback(course.category),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + difficulty
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.internships.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(course.category,
                            style: const TextStyle(color: AppColors.internships, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: diffColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(diffLabel,
                            style: TextStyle(color: diffColor, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(course.title,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Poppins', color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(course.subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  // Instructor
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: course.instructorAvatar.isNotEmpty
                            ? NetworkImage(course.instructorAvatar)
                            : null,
                        backgroundColor: AppColors.primaryLight,
                        child: course.instructorAvatar.isEmpty
                            ? const Icon(Icons.person, size: 14, color: AppColors.primary)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(course.instructorName,
                          style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      const Icon(Icons.play_circle_outline, size: 15, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text('${course.totalVideos} videos',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      const SizedBox(width: 12),
                      const Icon(Icons.timer_outlined, size: 15, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text(durationStr,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                      const Spacer(),
                      const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB020)),
                      const SizedBox(width: 3),
                      Text(course.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                      const SizedBox(width: 4),
                      Text('(${course.enrolledCount})',
                          style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Poppins')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailFallback(String category) {
    return Container(
      color: AppColors.internships.withValues(alpha: 0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_rounded, size: 48, color: AppColors.internships),
            const SizedBox(height: 8),
            Text(category, style: const TextStyle(color: AppColors.internships, fontFamily: 'Poppins', fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
