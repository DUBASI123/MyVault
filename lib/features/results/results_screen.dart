import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/app_data_service.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../../shared/widgets/custom_button.dart';
import '../auth/data/auth_repository.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  late final TextEditingController _hallTicket;
  bool _showResults = false;
  bool _loading = false;
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    final student = ref.read(currentStudentProvider);
    _hallTicket = TextEditingController(text: student?.hallTicket ?? 'JNTUH20CS001');
  }

  @override
  void dispose() {
    _hallTicket.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final student = ref.read(currentStudentProvider);
      _results = await AppDataService.getResults(
        branch: student?.branch ?? 'CSE',
        semester: student?.semester,
      );
      setState(() => _showResults = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final results = _results;
    final pass = results.where((r) => r['status'] == 'Pass').length;
    final total = results.fold<int>(0, (s, r) => s + (r['total'] as int));
    final max = results.fold<int>(0, (s, r) => s + (r['max'] as int));

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Results', style: AppTextStyles.heading2),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _hallTicket,
                          decoration: const InputDecoration(
                            labelText: 'Hall Ticket No.',
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Get Result',
                          onPressed: _fetch,
                          isLoading: _loading,
                          icon: Icons.bar_chart_outlined,
                        ),
                      ],
                    ),
                  ),
                  if (_showResults) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _stat('Total', '$total/$max'),
                          _stat('Pass', '$pass'),
                          _stat('Fail', '${results.length - pass}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...results.map(_resultCard),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.7), fontSize: 12)),
      ],
    );
  }

  Widget _resultCard(Map<String, dynamic> r) {
    final isPass = r['status'] == 'Pass';
    final color = isPass ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['subject'], style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                Text(r['code'], style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(r['grade'], style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text('${r['total']}/${r['max']}', style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
