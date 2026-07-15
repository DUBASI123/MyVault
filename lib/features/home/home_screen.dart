import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../shared/widgets/live_notification_ticker.dart';
import '../auth/data/auth_repository.dart';
import '../academic_hub/academic_hub_screen.dart';
import '../results/results_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, label: 'Home', color: AppColors.primary),
    _NavItem(icon: Icons.menu_book_rounded, label: 'Academics', color: AppColors.academicHub),
    _NavItem(icon: Icons.bar_chart_rounded, label: 'Results', color: AppColors.results),
    _NavItem(icon: Icons.person_rounded, label: 'Profile', color: AppColors.primary),
  ];

  @override
  void initState() {
    super.initState();
    ref.read(currentStudentProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);

    // Update college logo watermark
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (student?.collegeLogoUrl != null) {
        ref.read(collegeLogoProvider.notifier).state = student?.collegeLogoUrl;
      }
    });

    return AppScaffold(
      showAppBar: false,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: _navItems
            .map((n) => BottomNavigationBarItem(
                  icon: Icon(n.icon),
                  label: n.label,
                  activeIcon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: n.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(n.icon, color: n.color),
                  ),
                ))
            .toList(),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(student: student),
          const AcademicHubScreen(),
          const ResultsScreen(),
          const ProfileScreen(),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  _NavItem({required this.icon, required this.label, required this.color});
}


// ─── Live Stats Provider ────────────────────────────────────────────────────────
final _homeStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return {};
  final Map<String, dynamic> stats = {};

  // Certificates earned
  try {
    final certs = await Supabase.instance.client
        .from('certificates').select('id').eq('student_id', uid);
    final courseCerts = await Supabase.instance.client
        .from('course_certificates').select('id').eq('student_id', uid);
    stats['certs'] = (certs as List).length + (courseCerts as List).length;
  } catch (_) { stats['certs'] = 0; }

  // Exam results → compute CGPA
  try {
    final results = await Supabase.instance.client
        .from('exam_results').select('grade, credits').eq('student_id', uid);
    const gradeMap = {'O':10,'A+':9,'S':9,'A':8,'B+':7,'B':6,'C':5,'D':4,'E':4,'F':0,'Ab':0};
    double totalPoints = 0; int totalCredits = 0;
    for (final r in results as List) {
      final g = gradeMap[r['grade'] ?? 'B'] ?? 7;
      final cr = (r['credits'] as num?)?.toInt() ?? 3;
      totalPoints += g * cr; totalCredits += cr;
    }
    stats['cgpa'] = totalCredits > 0 ? (totalPoints / totalCredits) : 0.0;
  } catch (_) { stats['cgpa'] = 0.0; }

  // Courses in progress
  try {
    final prog = await Supabase.instance.client
        .from('student_course_progress')
        .select('id').eq('student_id', uid).eq('is_completed', false);
    stats['inProgress'] = (prog as List).length;
  } catch (_) { stats['inProgress'] = 0; }

  return stats;
});

// ─── Home tab ──────────────────────────────────────────────────────────────────
class _HomeTab extends ConsumerWidget {
  final dynamic student;
  const _HomeTab({this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = _greeting();
    final name = student?.firstName ?? 'Student';
    final statsAsync = ref.watch(_homeStatsProvider);

    final modules = [
      _Module('Academic Hub', Icons.menu_book_rounded, AppColors.academicHub, AppRoutes.academicHub),
      _Module('My Results', Icons.bar_chart_rounded, AppColors.results, AppRoutes.results),
      _Module('Documents Hub', Icons.folder_rounded, AppColors.certificates, AppRoutes.documentsHub),
      _Module('Internships', Icons.work_rounded, AppColors.internships, AppRoutes.internships),
      _Module('Placement Desk', Icons.business_center_rounded, AppColors.results, AppRoutes.placementDesk),
      _Module('Govt Jobs', Icons.account_balance_rounded, const Color(0xFF10B981), AppRoutes.govtJobs),
      _Module('Projects', Icons.code_rounded, AppColors.projects, AppRoutes.projects),
      _Module('Study Planner', Icons.calendar_month_rounded, const Color(0xFF6366F1), AppRoutes.studyPlanner),
      _Module('Competitive Exams', Icons.emoji_events_rounded, AppColors.compExams, AppRoutes.competitiveExams),
      _Module('Notifications', Icons.notifications_rounded, AppColors.notifications, AppRoutes.notifications),
      _Module('Certificates', Icons.workspace_premium_rounded, AppColors.warning, AppRoutes.certificates),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting 👋',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings icon
                  IconButton(
                    onPressed: () => context.push(AppRoutes.settings),
                    icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.profile),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: student?.profilePicUrl != null
                          ? NetworkImage(student!.profilePicUrl!)
                          : null,
                      child: student?.profilePicUrl == null
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'S',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Live notification ticker ──────────────────────────────────
            const LiveNotificationTicker(),

            // Info card
            if (student != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _InfoCard(student: student).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              ),

            const SizedBox(height: 12),

            // ── Live Stats Strip ──────────────────────────────────────────
            statsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (stats) {
                final cgpa = (stats['cgpa'] as double? ?? 0.0);
                final certs = stats['certs'] as int? ?? 0;
                final inProg = stats['inProgress'] as int? ?? 0;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: [
                      Expanded(child: _StatTile(
                        label: 'CGPA',
                        value: cgpa > 0 ? cgpa.toStringAsFixed(2) : '--',
                        icon: Icons.bar_chart_rounded,
                        color: AppColors.results,
                        onTap: () => context.push(AppRoutes.results),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(
                        label: 'Certificates',
                        value: '$certs',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.certificates,
                        onTap: () => context.push(AppRoutes.certificates),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _StatTile(
                        label: 'In Progress',
                        value: '$inProg',
                        icon: Icons.play_circle_rounded,
                        color: AppColors.internships,
                        onTap: () => context.push(AppRoutes.internships),
                      )),
                    ],
                  ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.15),
                );
              },
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Quick Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ).animate().fadeIn(delay: 150.ms),
            ),

            const SizedBox(height: 12),

            // Modules grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: modules.length,
                itemBuilder: (context, i) {
                  final m = modules[i];
                  return _ModuleCard(module: m, index: i);
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}

// ─── Stat Tile ─────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                    color: color, fontFamily: 'Poppins')),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary,
                    fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}


class _InfoCard extends StatelessWidget {
  final dynamic student;
  const _InfoCard({this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.school_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student?.collegeName ?? 'College',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${student?.branch ?? ''} • Sem ${student?.semester ?? ''}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Module {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _Module(this.label, this.icon, this.color, this.route);
}

class _ModuleCard extends StatefulWidget {
  final _Module module;
  final int index;
  const _ModuleCard({required this.module, required this.index});

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        context.push(m.route);
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: m.color.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(m.icon, color: m.color, size: 28),
              ),
              const SizedBox(height: 10),
              Text(
                m.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 60))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
