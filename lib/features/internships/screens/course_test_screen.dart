// ============================================================
// screens/course_test_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/internship_models.dart';
import '../providers/internship_providers.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';

class CourseTestScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseTestScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseTestScreen> createState() => _CourseTestScreenState();
}

class _CourseTestScreenState extends ConsumerState<CourseTestScreen> {
  final Map<String, int> _selectedAnswers = {};
  bool _submitted = false;
  Map<String, dynamic>? _result;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(testQuestionsProvider(widget.courseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Final Test', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.internships,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.internships)),
        error: (e, _) => Center(child: Text('Error loading questions: $e')),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text('No test questions yet.', style: TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary)),
            );
          }

          if (_submitted && _result != null) {
            return _buildResultScreen(context, _result!);
          }

          return Column(
            children: [
              // Progress header
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.internships.withValues(alpha: 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_selectedAnswers.length} / ${questions.length} answered',
                        style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontSize: 13)),
                    Text('Pass mark: 60%',
                        style: const TextStyle(fontFamily: 'Poppins', color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (_, i) => _QuestionCard(
                    question: questions[i],
                    index: i,
                    selectedIndex: _selectedAnswers[questions[i].id],
                    onSelect: (optionIndex) {
                      setState(() => _selectedAnswers[questions[i].id] = optionIndex);
                    },
                  ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.1),
                ),
              ),
              // Submit button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_selectedAnswers.length < questions.length || _submitting)
                          ? null
                          : () => _submit(questions),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.internships,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        disabledBackgroundColor: AppColors.border,
                      ),
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              _selectedAnswers.length < questions.length
                                  ? 'Answer all ${questions.length} questions'
                                  : 'Submit Test',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(List<CourseTestQuestion> questions) async {
    setState(() => _submitting = true);
    try {
      final answers = _selectedAnswers.entries
          .map((e) => {'question_id': e.key, 'selected_index': e.value})
          .toList();
      final result = await ref.read(courseProgressNotifierProvider.notifier).submitTest(
            courseId: widget.courseId,
            answers: answers,
          );
      if (mounted) setState(() { _result = result; _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
        setState(() => _submitting = false);
      }
    }
  }

  Widget _buildResultScreen(BuildContext context, Map<String, dynamic> result) {
    final score = result['score'] as int? ?? 0;
    final maxScore = result['max_score'] as int? ?? 1;
    final passed = result['passed'] as bool? ?? false;
    final pct = (score / maxScore * 100).round();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Result icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (passed ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
              ),
              child: Icon(
                passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 60,
                color: passed ? AppColors.success : AppColors.error,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              passed ? '🎉 Congratulations!' : 'Keep Trying!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 8),
            Text(
              passed ? 'You passed the test!' : 'You scored below 60%. Try again!',
              style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 32),
            // Score circle
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: passed
                      ? [const Color(0xFF27AE60), const Color(0xFF2ECC71)]
                      : [const Color(0xFFE74C3C), const Color(0xFFFF6B6B)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (passed ? AppColors.success : AppColors.error).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$pct%', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800,
                      color: Colors.white, fontFamily: 'Poppins')),
                  Text('$score / $maxScore marks', style: const TextStyle(fontSize: 12, color: Colors.white70,
                      fontFamily: 'Poppins')),
                ],
              ),
            ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 40),
            if (passed) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop(); // pop test screen
                    context.push(AppRoutes.certificateView, extra: widget.courseId);
                  },
                  icon: const Icon(Icons.card_membership_rounded),
                  label: const Text('View My Certificate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(passed ? 'Back to Course' : 'Back & Try Again',
                    style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final CourseTestQuestion question;
  final int index;
  final int? selectedIndex;
  final void Function(int) onSelect;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedIndex != null ? AppColors.internships.withValues(alpha: 0.4) : AppColors.border,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.internships,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(question.question,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins', color: AppColors.textPrimary, height: 1.5)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(question.options.length, (i) {
            final selected = selectedIndex == i;
            return InkWell(
              onTap: () => onSelect(i),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppColors.internships.withValues(alpha: 0.1) : AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppColors.internships : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? AppColors.internships : Colors.transparent,
                        border: Border.all(color: selected ? AppColors.internships : AppColors.textLight, width: 1.5),
                      ),
                      child: selected
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(question.options[i],
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            color: selected ? AppColors.internships : AppColors.textPrimary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          )),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (question.marks > 1)
            Align(
              alignment: Alignment.centerRight,
              child: Text('${question.marks} marks',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight, fontFamily: 'Poppins')),
            ),
        ],
      ),
    );
  }
}
