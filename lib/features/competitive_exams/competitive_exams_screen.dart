import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';

class CompetitiveExamsScreen extends ConsumerWidget {
  const CompetitiveExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(currentStudentProvider);
    final exams = ['GATE', 'GRE', 'CAT', 'Bank Exams', 'TSPSC', 'Placement Exams'];
    final resources = ['Recorded Videos', 'Study Material', 'Quiz', 'Mock Tests', 'Previous Papers', 'Cheat Sheets'];

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Competitive Exams', style: AppTextStyles.heading2),
                const SizedBox(height: 4),
                const Text('Prepare for competitive and placement exams', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 20),
                ...exams.map((exam) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.compExams.withValues(alpha: 0.25)),
                      ),
                      child: ExpansionTile(
                        leading: const Icon(Icons.emoji_events_outlined, color: AppColors.compExams),
                        title: Text(exam, style: AppTextStyles.heading3),
                        children: resources
                            .map((r) => ListTile(
                                  dense: true,
                                  leading: Icon(_icon(r), color: AppColors.compExams, size: 18),
                                  title: Text(r, style: AppTextStyles.bodyMedium),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                                ))
                            .toList(),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(String resource) {
    if (resource.contains('Video')) return Icons.play_circle_outline;
    if (resource.contains('Quiz') || resource.contains('Mock')) return Icons.quiz_outlined;
    if (resource.contains('Paper') || resource.contains('Cheat')) return Icons.description_outlined;
    return Icons.article_outlined;
  }
}
