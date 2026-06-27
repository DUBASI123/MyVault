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
                                  onTap: () => _showResources(context, exam, r),
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

  void _showResources(BuildContext context, String exam, String category) {
    final list = _examResourcesData[exam]?[category] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$exam - $category',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.compExams,
              ),
            ),
            const SizedBox(height: 16),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No resources available for this section yet.',
                    style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final item = list[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.compExams.withValues(alpha: 0.1),
                          child: Icon(_icon(category), color: AppColors.compExams, size: 20),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Poppins')),
                        subtitle: Text(item.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontFamily: 'Poppins')),
                        trailing: const Icon(Icons.open_in_new_rounded, color: AppColors.compExams, size: 18),
                        onTap: () async {
                          final url = Uri.parse(item.url);
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          } catch (_) {}
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ExamResource {
  final String title;
  final String description;
  final String url;
  const ExamResource(this.title, this.description, this.url);
}

const Map<String, Map<String, List<ExamResource>>> _examResourcesData = {
  'GATE': {
    'Recorded Videos': [
      ExamResource('GATE CSE Lectures by Gate Smashers', 'Complete course coverage with simplified explanations for CSE.', 'https://www.youtube.com/playlist?list=PLxCzCOWd7aiGz9donHRrE9I3Mwn6XdP8p'),
      ExamResource('GATE ECE Lectures by NPTEL', 'Premium high-quality lectures from IIT professors covering the ECE syllabus.', 'https://www.youtube.com/playlist?list=PL3D11EBEA54D4F4F3'),
    ],
    'Study Material': [
      ExamResource('GeeksforGeeks GATE CS Notes', 'Topic-wise detailed study notes and quick cheat sheets for CS.', 'https://www.geeksforgeeks.org/gate-cs-notes-gq/'),
      ExamResource('GATE ECE Study Notes (Kreatryx)', 'Detailed handbook and formula sheets for Core Electronics.', 'https://www.google.com/search?q=Kreatryx+GATE+ECE+handbook+pdf'),
    ],
    'Quiz': [
      ExamResource('IndiaBIX GATE Technical Quiz', 'Interactive online practice quizzes for GATE technical topics.', 'https://www.indiabix.com/online-test/gate-preparation/'),
    ],
    'Mock Tests': [
      ExamResource('Testbook GATE CSE Free Mock Test', 'Full-length simulated mock exam matching current pattern.', 'https://testbook.com/gate-cs/mock-test'),
    ],
    'Previous Papers': [
      ExamResource('GATE official website past papers', 'Official question booklets and keys from current/past organizing IITs.', 'https://gate2024.iiscl.ac.in/'),
    ],
    'Cheat Sheets': [
      ExamResource('GATE CSE Quick Revision Cheat Sheet', 'Short summary formulas and rules compiled in one PDF.', 'https://gate.unacademy.com/'),
    ],
  },
  'GRE': {
    'Recorded Videos': [
      ExamResource('GregMat GRE Preparation Videos', 'Excellent strategies for Verbal and Quantitative reasoning.', 'https://www.youtube.com/@GregMat'),
    ],
    'Study Material': [
      ExamResource('Official GRE prep guide (ETS)', 'Official study guide containing tips directly from the exam setters.', 'https://www.ets.org/gre/prepare.html'),
    ],
    'Mock Tests': [
      ExamResource('Princeton Review Free GRE Practice Test', 'Full-length practice test with details on performance breakdown.', 'https://www.princetonreview.com/grad/free-gre-practice-test'),
    ],
  },
  'CAT': {
    'Recorded Videos': [
      ExamResource('CAT Quantitative Aptitude (Rodha)', 'Comprehensive free video lectures for QA and LRDI sections.', 'https://www.youtube.com/@Rodha'),
    ],
    'Study Material': [
      ExamResource('Shiksha CAT Exam Preparation Guide', 'Detailed syllabus notes, book lists, and preparation calendar.', 'https://www.shiksha.com/mba/cat-exam-preparation'),
    ],
    'Previous Papers': [
      ExamResource('CAT Previous Years Solved Papers', 'Direct downloads of solved question papers from the past 5 years.', 'https://www.collegedekho.com/articles/cat-previous-years-question-papers/'),
    ],
  },
  'Bank Exams': {
    'Recorded Videos': [
      ExamResource('Adda247 Banking Preparation Channel', 'Daily live lectures covering quantitative aptitude and reasoning.', 'https://www.youtube.com/@Adda247live'),
    ],
    'Study Material': [
      ExamResource('IBPS Guide Free Study Materials', 'Preparation handbooks for SBI PO, clerk, and IBPS RRB.', 'https://www.ibpsguide.com/'),
    ],
  },
  'TSPSC': {
    'Recorded Videos': [
      ExamResource('TSPSC Telugu Medium Lectures (VMR Logics)', 'Top rated coaching lectures in Telugu for TSPSC Group exams.', 'https://www.youtube.com/@vmrlogics'),
    ],
    'Study Material': [
      ExamResource('TSPSC Group preparation guide', 'Official notifications, syllabus guides, and free study notes.', 'https://www.tspsc.gov.in/'),
    ],
  },
  'Placement Exams': {
    'Recorded Videos': [
      ExamResource('PrepInsta Placement Preparation Guide', 'Step-by-step videos to crack TCS NQT, Wipro, Infosys, and Cognizant.', 'https://www.youtube.com/@PrepInsta'),
    ],
    'Study Material': [
      ExamResource('GeeksforGeeks Placement Prep', 'Must-do coding questions, coding practice, and puzzle sheets.', 'https://www.geeksforgeeks.org/lmns-gq/'),
    ],
    'Mock Tests': [
      ExamResource('IndiaBIX Aptitude Practice Tests', 'Free mock practice questions for Quantitative, Verbal, and Logical sections.', 'https://www.indiabix.com/'),
    ],
  },
};
