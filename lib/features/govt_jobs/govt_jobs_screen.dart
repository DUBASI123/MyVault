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
import 'govt_jobs_providers.dart';

class GovtJobsScreen extends ConsumerStatefulWidget {
  const GovtJobsScreen({super.key});

  @override
  ConsumerState<GovtJobsScreen> createState() => _GovtJobsScreenState();
}

class _GovtJobsScreenState extends ConsumerState<GovtJobsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _sectors = [
    'All',
    'Banking',
    'Railways',
    'Defence',
    'Police',
    'Teaching',
    'Civil Services',
    'State PSC',
    'PSU Technical',
    'Healthcare',
    'Judiciary',
    'Postal',
    'Insurance',
    'Other'
  ];

  String _formatSectorName(String sector) {
    switch (sector.toLowerCase()) {
      case 'central_civil_services': return 'Civil Services';
      case 'state_psc': return 'State PSC';
      case 'psu_technical': return 'PSU Technical';
      default:
        return sector.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final selectedSector = ref.watch(govtJobsSectorProvider);
    final jobsAsync = ref.watch(filteredGovtJobsProvider);

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.go(AppRoutes.home),
                ),
                const SizedBox(width: 8),
                const Text('Govt Jobs Desk', style: AppTextStyles.heading2),
              ],
            ),
          ),
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => ref.read(govtJobsSearchProvider.notifier).state = v,
              decoration: InputDecoration(
                hintText: 'Search by title, organization, criteria...',
                hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: Colors.white38, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          ref.read(govtJobsSearchProvider.notifier).state = '';
                        })
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Sector Horizontal List
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _sectors.length,
              itemBuilder: (ctx, i) {
                final s = _sectors[i];
                final isSelected = s == selectedSector;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(s, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        ref.read(govtJobsSectorProvider.notifier).state = s;
                      }
                    },
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: AppColors.surface,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Jobs Stream View
          Expanded(
            child: jobsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(
                    child: Text('No active government jobs found matching filters.',
                        style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length,
                  itemBuilder: (ctx, i) {
                    final job = list[i];
                    return _buildJobCard(context, job);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
              error: (err, _) => Center(child: Text('Error loading govt jobs: $err', style: const TextStyle(color: Colors.red))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, Map<String, dynamic> job) {
    final title = job['title'] as String? ?? 'Recruitment Drive';
    final org = job['organization'] as String? ?? 'Government of India';
    final sector = job['sector'] as String? ?? 'other';
    final location = job['location'] as String? ?? 'Pan India';
    final vacancies = job['vacancies'] as int?;
    final salary = job['salary'] as String?;
    final deadline = job['apply_deadline'] as String?;
    final testDate = job['test_date'] as String?;
    final eligibility = job['eligibility'] as String? ?? 'Graduate';
    final experience = job['experience'] as String? ?? 'Fresher';
    final applyUrl = job['apply_link'] as String? ?? 'https://google.com';
    final prepExamId = job['prep_exam_id'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with sector label & vacancies badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatSectorName(sector),
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                ),
                if (vacancies != null)
                  Text(
                    '🔥 $vacancies Vacancies',
                    style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text(org, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            // Info Row: Location, Experience, Salary
            Row(
              children: [
                Expanded(
                  child: _infoItem(Icons.location_on_outlined, location),
                ),
                Expanded(
                  child: _infoItem(Icons.work_outline, experience),
                ),
                if (salary != null)
                  Expanded(
                    child: _infoItem(Icons.currency_rupee, salary),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Criteria / Eligibility details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school_outlined, color: Colors.white54, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      eligibility,
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Poppins'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Dates details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (deadline != null)
                  Text(
                    'Apply By: $deadline',
                    style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  )
                else
                  const Text(
                    'Apply By: Rolling/No fixed date',
                    style: TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'Poppins'),
                  ),
                if (testDate != null)
                  Text(
                    'Exam: $testDate',
                    style: const TextStyle(color: Color(0xFF6366F1), fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ).build(
                    context,
                    onPressed: () async {
                      final url = Uri.parse(applyUrl);
                      try {
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      } catch (_) {}
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.launch, size: 16),
                        SizedBox(width: 6),
                        Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ),
                if (prepExamId != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.compExams),
                      foregroundColor: AppColors.compExams,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ).build(
                      context,
                      onPressed: () {
                        context.push(AppRoutes.competitiveExams);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories, size: 16),
                          SizedBox(width: 6),
                          Text('Prepare Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Poppins')),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'Poppins'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Extension to help build buttons in a clean way
extension ButtonBuilder on ButtonStyle {
  Widget build(BuildContext context, {required VoidCallback onPressed, required Widget child}) {
    return TextButton(style: this, onPressed: onPressed, child: child);
  }
}
