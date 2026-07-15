import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';
import 'exam_rotation_providers.dart';

class CompetitiveExamsScreen extends ConsumerWidget {
  const CompetitiveExamsScreen({super.key});

  String _mapExamId(String exam) {
    switch (exam) {
      case 'GATE': return 'gate';
      case 'GRE': return 'gre';
      case 'CAT': return 'cat';
      case 'Bank Exams': return 'bank_exams';
      case 'TSPSC': return 'tspsc';
      case 'Placement Exams': return 'placement_exams';
      default: return exam.toLowerCase().replaceAll(' ', '_');
    }
  }

  String _mapContentType(String resource) {
    switch (resource) {
      case 'Recorded Videos': return 'recorded_video';
      case 'Study Material': return 'study_material';
      case 'Quiz': return 'quiz';
      case 'Mock Tests': return 'mock_test';
      case 'Previous Papers': return 'previous_paper';
      case 'Cheat Sheets': return 'cheat_sheet';
      default: return 'recorded_video';
    }
  }

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
                                  onTap: () => _showLiveResources(context, ref, exam, r),
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

  void _showLiveResources(BuildContext context, WidgetRef ref, String exam, String category) {
    final examId = _mapExamId(exam);
    final contentType = _mapContentType(category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.compExams.withValues(alpha: 0.1),
                    child: Icon(_icon(category), color: AppColors.compExams, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exam, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Poppins')),
                        Text(category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer(
                  builder: (context, ref, _) {
                    if (contentType == 'quiz') {
                      return _buildQuizView(ref, examId, scrollController);
                    } else if (contentType == 'mock_test') {
                      return _buildMockTestView(ref, examId, scrollController);
                    } else {
                      return _buildStaticContentView(ref, examId, contentType, scrollController);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizView(WidgetRef ref, String examId, ScrollController sc) {
    final todayAsync = ref.watch(todaysQuizProvider(examId));
    final allAsync = ref.watch(quizArchiveProvider(examId));

    return ListView(
      controller: sc,
      children: [
        const Text("Today's Daily Challenge", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.compExams, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        todayAsync.when(
          data: (quiz) {
            if (quiz == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("No daily challenge for today.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                ),
              );
            }
            return _buildContentCard(quiz, isFeatured: true);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading today\'s quiz: $err')),
        ),
        const SizedBox(height: 24),
        const Text("Quiz Archive & Practice Sets", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        allAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text("No quizzes found in database.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (ctx, i) => _buildContentCard(list[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading archive: $err')),
        ),
      ],
    );
  }

  Widget _buildMockTestView(WidgetRef ref, String examId, ScrollController sc) {
    final todayAsync = ref.watch(thisMonthMockProvider(examId));
    final allAsync = ref.watch(mockTestArchiveProvider(examId));

    return ListView(
      controller: sc,
      children: [
        const Text("This Month's Mock Test", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.compExams, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        todayAsync.when(
          data: (mock) {
            if (mock == null) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: Text("No mock test active for this month.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                ),
              );
            }
            return _buildContentCard(mock, isFeatured: true);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading mock test: $err')),
        ),
        const SizedBox(height: 24),
        const Text("Full Mock Test Series", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary, fontFamily: 'Poppins')),
        const SizedBox(height: 8),
        allAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Center(child: Text("No mocks found in database.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (ctx, i) => _buildContentCard(list[i]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error loading archive: $err')),
        ),
      ],
    );
  }

  Widget _buildStaticContentView(WidgetRef ref, String examId, String contentType, ScrollController sc) {
    final listAsync = ref.watch(examStaticContentProvider((examId: examId, contentType: contentType)));

    return listAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Text('No resources available for this section yet.',
                style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13)),
          );
        }
        return ListView.builder(
          controller: sc,
          itemCount: list.length,
          itemBuilder: (ctx, i) => _buildContentCard(list[i]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item, {bool isFeatured = false}) {
    final title = item['title'] as String? ?? 'Unnamed Resource';
    final desc = item['description'] as String? ?? '';
    final urlStr = item['file_url'] as String? ?? item['external_link'] as String? ?? 'https://google.com';
    final qCount = item['question_count'] as int?;
    final tLimit = item['time_limit_minutes'] as int?;
    
    String subtitleText = desc;
    if (qCount != null && tLimit != null) {
      subtitleText = '$qCount Qs • $tLimit Mins • $desc';
    } else if (item['year'] != null) {
      subtitleText = 'Year: ${item['year']} • $desc';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isFeatured ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isFeatured ? const BorderSide(color: AppColors.compExams, width: 1.5) : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins', color: isFeatured ? AppColors.compExams : AppColors.textPrimary)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitleText, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins')),
        ),
        trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.compExams, size: 18),
        onTap: () async {
          final url = Uri.parse(urlStr);
          try {
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          } catch (_) {}
        },
      ),
    );
  }
}

