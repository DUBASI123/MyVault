import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import 'models/subject_model.dart';
import 'services/academic_service.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

final academicYearProvider = StateProvider<int>((ref) => 1);
final academicSemesterProvider = StateProvider<int>((ref) => 1);

// ─── Content types ────────────────────────────────────────────────────────────

const _contentTypes = [
  _ContentType('Textbooks', Icons.menu_book_outlined, Color(0xFF6C63FF), ['ebook']),
  _ContentType('Recorded Notes', Icons.note_alt_outlined, Color(0xFF00C2A8), ['notes']),
  _ContentType('Video Lectures', Icons.play_circle_outline_rounded, Color(0xFFFF6B6B), ['video']),
  _ContentType('PDFs & Slides', Icons.picture_as_pdf_outlined, Color(0xFFFFB020), ['pdf', 'ppt']),
  _ContentType('Question Banks', Icons.quiz_outlined, Color(0xFF3B82F6), ['other', 'syllabus']),
  _ContentType('Previous Papers', Icons.history_edu_outlined, Color(0xFF9B59B6), ['question_paper']),
  _ContentType('Mock Tests', Icons.fact_check_outlined, Color(0xFF2ECC71), ['other']),
  _ContentType('Practical Questions', Icons.science_outlined, Color(0xFFE67E22), ['other']),
  _ContentType('Lab Manual', Icons.biotech_outlined, Color(0xFF1ABC9C), ['lab_manual']),
  _ContentType('Lab Experiments', Icons.biotech_rounded, Color(0xFFE91E63), ['lab_manual']),
];

class _ContentType {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> dbTypes;
  const _ContentType(this.name, this.icon, this.color, this.dbTypes);
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class AcademicHubScreen extends ConsumerStatefulWidget {
  const AcademicHubScreen({super.key});

  @override
  ConsumerState<AcademicHubScreen> createState() => _AcademicHubScreenState();
}

class _AcademicHubScreenState extends ConsumerState<AcademicHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SubjectModel> _subjects = [];
  bool _loadingSubjects = true;
  String? _loadedBranch;
  int? _loadedSemester;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSemester());
  }

  void _initSemester() {
    final student = ref.read(currentStudentProvider);
    if (student != null) {
      // Set initial year and semester from student registration
      final sem = student.semester; // int
      final year = ((sem - 1) ~/ 2) + 1;
      ref.read(academicYearProvider.notifier).state = year;
      ref.read(academicSemesterProvider.notifier).state = sem;
    }
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final student = ref.read(currentStudentProvider);
    final semester = ref.read(academicSemesterProvider);
    if (student == null) return;

    // Avoid reload if same
    if (_loadedBranch == student.branch && _loadedSemester == semester) return;

    setState(() => _loadingSubjects = true);
    final list = await AcademicService.getSubjects(
      branch: student.branch,
      semester: semester,
    );
    if (mounted) {
      setState(() {
        _subjects = list;
        _loadingSubjects = false;
        _loadedBranch = student.branch;
        _loadedSemester = semester;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<int> _semestersForYear(int year) {
    final s1 = (year - 1) * 2 + 1;
    final s2 = (year - 1) * 2 + 2;
    return [s1, s2];
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final selectedYear = ref.watch(academicYearProvider);
    final selectedSemester = ref.watch(academicSemesterProvider);

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),

          // ── Year & Semester Selector ───────────────────────────────────────
          _YearSemesterSelector(
            selectedYear: selectedYear,
            selectedSemester: selectedSemester,
            onYearChanged: (y) {
              ref.read(academicYearProvider.notifier).state = y;
              // Set first semester of that year by default
              final sems = _semestersForYear(y);
              ref.read(academicSemesterProvider.notifier).state = sems[0];
              _loadedSemester = null;
              _loadSubjects();
            },
            onSemesterChanged: (s) {
              ref.read(academicSemesterProvider.notifier).state = s;
              _loadedSemester = null;
              _loadSubjects();
            },
            semestersForYear: _semestersForYear,
          ),

          // ── Tabs ─────────────────────────────────────────────────────────
          Material(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textLight,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2.5,
              tabs: const [
                Tab(text: 'Subjects'),
                Tab(text: 'Tech Skills'),
                Tab(text: 'Exam Prep'),
                Tab(text: 'Comm Skills'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _subjectsTab(selectedSemester, student),
                _techTab(),
                _examPrepTab(),
                _commTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Subjects Tab ─────────────────────────────────────────────────────────────
  Widget _subjectsTab(int semester, dynamic student) {
    return Column(
      children: [
        // Batch info bar
        if (student != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.academicHub.withValues(alpha: 0.06),
            child: Row(
              children: [
                const Icon(Icons.school_rounded, size: 14, color: AppColors.academicHub),
                const SizedBox(width: 6),
                Text(
                  '${student.branch} • Semester $semester • ${student.course}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.academicHub,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loadingSubjects
              ? const Center(child: CircularProgressIndicator())
              : _subjects.isEmpty
                  ? _emptySubjects(semester)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _subjects.length,
                      itemBuilder: (_, i) => _subjectCard(_subjects[i], i),
                    ),
        ),
      ],
    );
  }

  Widget _emptySubjects(int semester) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.academicHub.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded, size: 48, color: AppColors.academicHub),
          ),
          const SizedBox(height: 16),
          Text(
            'No subjects for Semester $semester',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Content is being curated.\nCheck back soon!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textLight, fontFamily: 'Poppins', fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _subjectCard(SubjectModel subject, int index) {
    final colors = [
      AppColors.primary,
      const Color(0xFF4F46E5),
      AppColors.warning,
      AppColors.info,
      AppColors.success,
      AppColors.results,
    ];
    final icons = [
      Icons.calculate_outlined,
      Icons.science_outlined,
      Icons.account_tree_outlined,
      Icons.storage_outlined,
      Icons.data_object_outlined,
      Icons.electrical_services_outlined,
    ];
    final color = colors[index % colors.length];
    final icon = icons[index % icons.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            subject.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: subject.code != null
              ? Text(subject.code!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins'))
              : null,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          children: [
            _contentGrid(color, subject),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _contentGrid(Color color, SubjectModel subject) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.3,
      children: _contentTypes.map((ct) => _contentChip(ct, subject)).toList(),
    );
  }

  Widget _contentChip(_ContentType ct, SubjectModel subject) {
    return GestureDetector(
      onTap: () {
        // Navigate to subject detail with content type pre-selected
        context.push(AppRoutes.subjectDetail, extra: {
          'subjectId': subject.id,
          'categoryName': ct.name,
          'dbTypes': ct.dbTypes,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: ct.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ct.color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(ct.icon, color: ct.color, size: 18),
            const SizedBox(height: 4),
            Text(
              ct.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: ct.color,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── Tech Skills Tab ──────────────────────────────────────────────────────────
  Widget _techTab() {
    final techSubjects = [
      _TechSubject('Java Programming', Icons.coffee_rounded, const Color(0xFFFF6B35)),
      _TechSubject('Python Programming', Icons.code_rounded, const Color(0xFF3B82F6)),
      _TechSubject('Web Development', Icons.web_rounded, const Color(0xFF2ECC71)),
      _TechSubject('Flutter / Dart', Icons.flutter_dash_rounded, const Color(0xFF6C63FF)),
      _TechSubject('Data Structures', Icons.account_tree_outlined, const Color(0xFF9B59B6)),
      _TechSubject('Database (SQL)', Icons.storage_rounded, const Color(0xFFE67E22)),
      _TechSubject('Machine Learning', Icons.psychology_rounded, const Color(0xFF00C2A8)),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: techSubjects
          .asMap()
          .entries
          .map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: entry.value.color.withValues(alpha: 0.2)),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: entry.value.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(entry.value.icon, color: entry.value.color, size: 20),
                  ),
                  title: Text(entry.value.name, style: AppTextStyles.heading3),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.4,
                        children: ['Video Lectures', 'Notes', 'Quiz', 'Mock Test', 'Interview Qs', 'Projects']
                            .map((label) => Container(
                                  decoration: BoxDecoration(
                                    color: entry.value.color.withValues(alpha: 0.07),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: entry.value.color.withValues(alpha: 0.2)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10, color: entry.value.color, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: entry.key * 60))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          )
          .toList(),
    );
  }

  // ── Exam Prep Tab ────────────────────────────────────────────────────────────
  Widget _examPrepTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _examSection('Aptitude & Reasoning', Icons.psychology_outlined, AppColors.compExams, [
          'Quantitative Aptitude',
          'Logical Reasoning',
          'Verbal Ability',
          'Data Interpretation',
        ]),
        const SizedBox(height: 12),
        _examSection('Competitive Exams', Icons.emoji_events_outlined, AppColors.warning, [
          'GATE Preparation',
          'GRE / GMAT',
          'CAT / MBA',
          'UPSC / PSC',
        ]),
        const SizedBox(height: 12),
        _examSection('Placement Prep', Icons.work_outlined, AppColors.internships, [
          'Resume Writing',
          'HR Questions',
          'Technical Questions',
          'Group Discussion Tips',
        ]),
      ],
    );
  }

  Widget _examSection(String title, IconData icon, Color color, List<String> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(title, style: AppTextStyles.heading3),
          initiallyExpanded: true,
          children: items.map((item) => ListTile(
            leading: const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.textSecondary),
            title: Text(item, style: AppTextStyles.bodyMedium),
            trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textSecondary),
            dense: true,
            onTap: () {},
          )).toList(),
        ),
      ),
    );
  }

  // ── Comm Skills Tab ──────────────────────────────────────────────────────────
  Widget _commTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _examSection('Communication Skills', Icons.record_voice_over_outlined, AppColors.notifications, [
          'Business English',
          'Public Speaking',
          'Email Writing',
          'Presentation Skills',
        ]),
        const SizedBox(height: 12),
        _examSection('Soft Skills', Icons.handshake_outlined, AppColors.success, [
          'Team Collaboration',
          'Leadership Skills',
          'Time Management',
          'Problem Solving',
        ]),
      ],
    );
  }
}

// ─── Helper classes ──────────────────────────────────────────────────────────

class _TechSubject {
  final String name;
  final IconData icon;
  final Color color;
  _TechSubject(this.name, this.icon, this.color);
}

// ─── Year Semester Selector ──────────────────────────────────────────────────

class _YearSemesterSelector extends StatelessWidget {
  final int selectedYear;
  final int selectedSemester;
  final void Function(int) onYearChanged;
  final void Function(int) onSemesterChanged;
  final List<int> Function(int) semestersForYear;

  const _YearSemesterSelector({
    required this.selectedYear,
    required this.selectedSemester,
    required this.onYearChanged,
    required this.onSemesterChanged,
    required this.semestersForYear,
  });

  @override
  Widget build(BuildContext context) {
    final sems = semestersForYear(selectedYear);

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year selector
          Row(
            children: [
              const Text(
                'Year:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Poppins'),
              ),
              const SizedBox(width: 10),
              ...List.generate(4, (i) => i + 1).map((y) => GestureDetector(
                onTap: () => onYearChanged(y),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selectedYear == y ? AppColors.academicHub : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedYear == y ? AppColors.academicHub : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Y$y',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selectedYear == y ? Colors.white : AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              )),
              const Spacer(),
              // Semester selector
              const Text(
                'Sem:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Poppins'),
              ),
              const SizedBox(width: 10),
              ...sems.map((s) => GestureDetector(
                onTap: () => onSemesterChanged(s),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  width: 42,
                  height: 36,
                  decoration: BoxDecoration(
                    color: selectedSemester == s ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selectedSemester == s ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'S$s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selectedSemester == s ? Colors.white : AppColors.textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
