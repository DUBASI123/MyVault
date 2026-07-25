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
  List<SubjectModel> _academicSubjects = [];
  List<SubjectModel> _techSubjects = [];
  List<SubjectModel> _examSubjects = [];
  List<SubjectModel> _commSubjects = [];
  bool _loading = true;
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
      final sem = student.semester;
      final year = ((sem - 1) ~/ 2) + 1;
      ref.read(academicYearProvider.notifier).state = year;
      ref.read(academicSemesterProvider.notifier).state = sem;
    }
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final student = ref.read(currentStudentProvider);
    final semester = ref.read(academicSemesterProvider);
    if (student == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }

    if (_loadedBranch == student.branch && _loadedSemester == semester) return;

    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        AcademicService.getSubjects(branch: student.branch, semester: semester, subjectType: 'academic'),
        AcademicService.getSubjects(branch: student.branch, semester: semester, subjectType: 'tech_skill'),
        AcademicService.getSubjects(branch: student.branch, semester: semester, subjectType: 'exam_prep'),
        AcademicService.getSubjects(branch: student.branch, semester: semester, subjectType: 'comm_skill'),
      ]);

      if (mounted) {
        setState(() {
          _academicSubjects = results[0];
          _techSubjects = results[1];
          _examSubjects = results[2];
          _commSubjects = results[3];
          _loading = false;
          _loadedBranch = student.branch;
          _loadedSemester = semester;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
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

          _YearSemesterSelector(
            selectedYear: selectedYear,
            selectedSemester: selectedSemester,
            onYearChanged: (y) {
              ref.read(academicYearProvider.notifier).state = y;
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

  Widget _buildSubjectsTab({
    required int semester,
    required dynamic student,
    required List<SubjectModel> subjectsList,
    required String emptyTitle,
    required String emptySubtitle,
    required IconData emptyIcon,
    required Color colorTheme,
  }) {
    return Column(
      children: [
        if (student != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: colorTheme.withValues(alpha: 0.06),
            child: Row(
              children: [
                Icon(Icons.school_rounded, size: 14, color: colorTheme),
                const SizedBox(width: 6),
                Text(
                  '${student.branch} • Semester $semester • ${student.course}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorTheme,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : subjectsList.isEmpty
                  ? _emptySubjects(semester, emptyTitle, emptySubtitle, emptyIcon, colorTheme)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: subjectsList.length,
                      itemBuilder: (_, i) => _subjectCard(subjectsList[i], i),
                    ),
        ),
      ],
    );
  }

  Widget _subjectsTab(int semester, dynamic student) {
    return _buildSubjectsTab(
      semester: semester,
      student: student,
      subjectsList: _academicSubjects,
      emptyTitle: 'No subjects for Semester $semester',
      emptySubtitle: 'Content is being curated.\nCheck back soon!',
      emptyIcon: Icons.menu_book_rounded,
      colorTheme: AppColors.academicHub,
    );
  }

  Widget _emptySubjects(int semester, String title, String subtitle, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: color),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textLight, fontFamily: 'Poppins', fontSize: 12),
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

  Widget _techTab() {
    final student = ref.watch(currentStudentProvider);
    final selectedSemester = ref.watch(academicSemesterProvider);
    return _buildSubjectsTab(
      semester: selectedSemester,
      student: student,
      subjectsList: _techSubjects,
      emptyTitle: 'No tech skills for Semester $selectedSemester',
      emptySubtitle: 'Premium tech skill courses are being curated.\nCheck back soon!',
      emptyIcon: Icons.code_rounded,
      colorTheme: const Color(0xFF6C63FF),
    );
  }

  Widget _examPrepTab() {
    final student = ref.watch(currentStudentProvider);
    final selectedSemester = ref.watch(academicSemesterProvider);
    return _buildSubjectsTab(
      semester: selectedSemester,
      student: student,
      subjectsList: _examSubjects,
      emptyTitle: 'No exam prep materials for Semester $selectedSemester',
      emptySubtitle: 'Quantitative aptitude, logical reasoning, and GATE prep files are being curated.\nCheck back soon!',
      emptyIcon: Icons.psychology_outlined,
      colorTheme: AppColors.compExams,
    );
  }

  Widget _commTab() {
    final student = ref.watch(currentStudentProvider);
    final selectedSemester = ref.watch(academicSemesterProvider);
    return _buildSubjectsTab(
      semester: selectedSemester,
      student: student,
      subjectsList: _commSubjects,
      emptyTitle: 'No comm skills materials for Semester $selectedSemester',
      emptySubtitle: 'Business communication and soft skills resources are being curated.\nCheck back soon!',
      emptyIcon: Icons.record_voice_over_outlined,
      colorTheme: AppColors.notifications,
    );
  }
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
