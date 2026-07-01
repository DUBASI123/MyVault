// ============================================================
// study_planner_screen.dart
// MyVault — Premium Study Planner & Timetable
// Features: Weekly timetable grid, subject tasks, study sessions,
//           streak tracker, Pomodoro timer, progress rings
// ============================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

enum TaskPriority { low, medium, high }
enum TaskStatus   { pending, inProgress, done }

class StudyTask {
  final String id;
  final String subject;
  final String description;
  final TaskPriority priority;
  TaskStatus status;
  final DateTime dueDate;
  final int estimatedMinutes;
  int loggedMinutes;

  StudyTask({
    required this.id,
    required this.subject,
    required this.description,
    required this.priority,
    this.status = TaskStatus.pending,
    required this.dueDate,
    required this.estimatedMinutes,
    this.loggedMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'subject': subject, 'description': description,
    'priority': priority.index, 'status': status.index,
    'dueDate': dueDate.toIso8601String(),
    'estimatedMinutes': estimatedMinutes, 'loggedMinutes': loggedMinutes,
  };

  factory StudyTask.fromJson(Map<String, dynamic> j) => StudyTask(
    id: j['id'], subject: j['subject'], description: j['description'],
    priority: TaskPriority.values[j['priority'] as int],
    status: TaskStatus.values[j['status'] as int],
    dueDate: DateTime.parse(j['dueDate']),
    estimatedMinutes: j['estimatedMinutes'],
    loggedMinutes: j['loggedMinutes'] ?? 0,
  );
}

class TimetableSlot {
  final String id;
  final int dayIndex; // 0=Mon…6=Sun
  final int startHour;
  final int durationHours;
  final String subject;
  final Color color;

  const TimetableSlot({
    required this.id, required this.dayIndex,
    required this.startHour, required this.durationHours,
    required this.subject, required this.color,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'dayIndex': dayIndex, 'startHour': startHour,
    'durationHours': durationHours, 'subject': subject,
    'color': color.value,
  };

  factory TimetableSlot.fromJson(Map<String, dynamic> j) => TimetableSlot(
    id: j['id'], dayIndex: j['dayIndex'], startHour: j['startHour'],
    durationHours: j['durationHours'], subject: j['subject'],
    color: Color(j['color'] as int),
  );
}

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────

class StudyPlannerNotifier extends StateNotifier<List<StudyTask>> {
  StudyPlannerNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('study_tasks_v1');
    if (raw != null) {
      state = (jsonDecode(raw) as List).map((e) => StudyTask.fromJson(e)).toList();
    } else {
      // Sample starter tasks
      state = _starterTasks();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('study_tasks_v1', jsonEncode(state.map((t) => t.toJson()).toList()));
  }

  void add(StudyTask t)  { state = [...state, t]; _save(); }
  void remove(String id) { state = state.where((t) => t.id != id).toList(); _save(); }
  void updateStatus(String id, TaskStatus s) {
    state = [for (final t in state) if (t.id == id) (t..status = s) else t];
    _save();
  }
  void logTime(String id, int minutes) {
    state = [for (final t in state) if (t.id == id) (t..loggedMinutes += minutes) else t];
    _save();
  }

  List<StudyTask> _starterTasks() {
    final now = DateTime.now();
    return [
      StudyTask(id: '1', subject: 'Data Structures', description: 'Revise Trees & Graphs', priority: TaskPriority.high, dueDate: now.add(const Duration(days: 1)), estimatedMinutes: 90),
      StudyTask(id: '2', subject: 'Operating Systems', description: 'Process scheduling algorithms', priority: TaskPriority.medium, dueDate: now.add(const Duration(days: 2)), estimatedMinutes: 60),
      StudyTask(id: '3', subject: 'DBMS', description: 'SQL joins and transactions', priority: TaskPriority.high, dueDate: now.add(const Duration(days: 3)), estimatedMinutes: 75),
      StudyTask(id: '4', subject: 'Computer Networks', description: 'TCP/IP and OSI model', priority: TaskPriority.low, dueDate: now.add(const Duration(days: 5)), estimatedMinutes: 45),
      StudyTask(id: '5', subject: 'Compiler Design', description: 'Parsing techniques — LL and LR', priority: TaskPriority.medium, dueDate: now.add(const Duration(days: 7)), estimatedMinutes: 120),
    ];
  }
}

final studyPlannerProvider = StateNotifierProvider<StudyPlannerNotifier, List<StudyTask>>((ref) {
  return StudyPlannerNotifier();
});

class TimetableNotifier extends StateNotifier<List<TimetableSlot>> {
  TimetableNotifier() : super([]) { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('timetable_v1');
    if (raw != null) {
      state = (jsonDecode(raw) as List).map((e) => TimetableSlot.fromJson(e)).toList();
    } else {
      state = _defaultSlots();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('timetable_v1', jsonEncode(state.map((s) => s.toJson()).toList()));
  }

  void add(TimetableSlot s) { state = [...state, s]; _save(); }
  void remove(String id)    { state = state.where((s) => s.id != id).toList(); _save(); }

  List<TimetableSlot> _defaultSlots() => [
    TimetableSlot(id: 'a', dayIndex: 0, startHour: 9,  durationHours: 1, subject: 'Maths',    color: AppColors.primary),
    TimetableSlot(id: 'b', dayIndex: 0, startHour: 11, durationHours: 1, subject: 'Physics',  color: AppColors.compExams),
    TimetableSlot(id: 'c', dayIndex: 1, startHour: 10, durationHours: 2, subject: 'DSA',      color: AppColors.results),
    TimetableSlot(id: 'd', dayIndex: 2, startHour: 9,  durationHours: 1, subject: 'DBMS',     color: AppColors.academicHub),
    TimetableSlot(id: 'e', dayIndex: 3, startHour: 14, durationHours: 2, subject: 'OS Lab',   color: AppColors.projects),
    TimetableSlot(id: 'f', dayIndex: 4, startHour: 11, durationHours: 1, subject: 'CN',       color: AppColors.internships),
  ];
}

final timetableProvider = StateNotifierProvider<TimetableNotifier, List<TimetableSlot>>((ref) {
  return TimetableNotifier();
});

// Streak provider (days studied this week)
final studyStreakProvider = Provider<int>((ref) {
  final tasks = ref.watch(studyPlannerProvider);
  final doneTasks = tasks.where((t) => t.status == TaskStatus.done);
  final days = doneTasks.map((t) => t.dueDate.weekday).toSet();
  return days.length;
});

// ─────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────

class StudyPlannerScreen extends ConsumerStatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  ConsumerState<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends ConsumerState<StudyPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks  = ref.watch(studyPlannerProvider);
    final streak = ref.watch(studyStreakProvider);
    final done   = tasks.where((t) => t.status == TaskStatus.done).length;
    final total  = tasks.length;
    final pct    = total > 0 ? done / total : 0.0;

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          _buildHeader(context, streak, done, total, pct),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _TasksTab(),
                _TimetableTab(),
                const _PomodoroTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int streak, int done, int total, double pct) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Study Planner',
                    style: TextStyle(color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
              ),
              GestureDetector(
                onTap: () => _showAddTaskSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('Add Task', style: TextStyle(color: Colors.white, fontSize: 12,
                          fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$done / $total tasks done',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${(pct * 100).toStringAsFixed(0)}% complete',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700,
                            fontSize: 14, fontFamily: 'Poppins')),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _StreakWidget(streak: streak),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF6366F1),
      child: TabBar(
        controller: _tab,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
        tabs: const [
          Tab(text: 'Tasks'),
          Tab(text: 'Timetable'),
          Tab(text: 'Pomodoro'),
        ],
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final descCtrl    = TextEditingController();
    final minsCtrl    = TextEditingController(text: '60');
    TaskPriority priority = TaskPriority.medium;
    DateTime dueDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Study Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins', color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              _inputField(subjectCtrl, 'Subject (e.g. Data Structures)', Icons.book_outlined),
              const SizedBox(height: 12),
              _inputField(descCtrl, 'What to study?', Icons.edit_note_rounded),
              const SizedBox(height: 12),
              _inputField(minsCtrl, 'Estimated minutes', Icons.timer_outlined, isNumber: true),
              const SizedBox(height: 12),
              // Priority selector
              Row(
                children: [
                  const Text('Priority:', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 12),
                  ...TaskPriority.values.map((p) {
                    final selected = priority == p;
                    final color = [AppColors.success, AppColors.warning, AppColors.error][p.index];
                    return GestureDetector(
                      onTap: () => setS(() => priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? color : color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ['Low', 'Medium', 'High'][p.index],
                          style: TextStyle(color: selected ? Colors.white : color,
                              fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 12),
              // Due date
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx, initialDate: dueDate,
                    firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60)),
                  );
                  if (d != null) setS(() => dueDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.inputFill,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text('Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (subjectCtrl.text.isEmpty) return;
                    ref.read(studyPlannerProvider.notifier).add(StudyTask(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      subject: subjectCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      priority: priority,
                      dueDate: dueDate,
                      estimatedMinutes: int.tryParse(minsCtrl.text) ?? 60,
                    ));
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Add Task',
                      style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController c, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13, fontFamily: 'Poppins'),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// STREAK WIDGET
// ─────────────────────────────────────────────────────────────

class _StreakWidget extends StatelessWidget {
  final int streak;
  const _StreakWidget({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 22)),
              Text('$streak', style: const TextStyle(color: Colors.white, fontSize: 18,
                  fontWeight: FontWeight.w800, fontFamily: 'Poppins')),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text('day streak', style: TextStyle(color: Colors.white60, fontSize: 10, fontFamily: 'Poppins')),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TASKS TAB
// ─────────────────────────────────────────────────────────────

class _TasksTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(studyPlannerProvider);
    final pending    = tasks.where((t) => t.status == TaskStatus.pending).toList();
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final done       = tasks.where((t) => t.status == TaskStatus.done).toList();

    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 72, color: AppColors.textLight),
            SizedBox(height: 16),
            Text('No tasks yet!\nTap + Add Task to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 14, height: 1.6)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (inProgress.isNotEmpty) ...[
          _groupHeader('In Progress', AppColors.info, inProgress.length),
          ...inProgress.asMap().entries.map((e) => _TaskCard(task: e.value, index: e.key)),
          const SizedBox(height: 12),
        ],
        if (pending.isNotEmpty) ...[
          _groupHeader('Pending', AppColors.warning, pending.length),
          ...pending.asMap().entries.map((e) => _TaskCard(task: e.value, index: e.key)),
          const SizedBox(height: 12),
        ],
        if (done.isNotEmpty) ...[
          _groupHeader('Completed', AppColors.success, done.length),
          ...done.asMap().entries.map((e) => _TaskCard(task: e.value, index: e.key)),
        ],
      ],
    );
  }

  Widget _groupHeader(String label, Color color, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, fontFamily: 'Poppins')),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Text('$count', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TASK CARD
// ─────────────────────────────────────────────────────────────

class _TaskCard extends ConsumerWidget {
  final StudyTask task;
  final int index;
  const _TaskCard({required this.task, required this.index});

  Color get _priorityColor => [AppColors.success, AppColors.warning, AppColors.error][task.priority.index];
  String get _priorityLabel => ['LOW', 'MED', 'HIGH'][task.priority.index];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = task.status == TaskStatus.done;
    final progress = task.estimatedMinutes > 0 ? (task.loggedMinutes / task.estimatedMinutes).clamp(0.0, 1.0) : 0.0;
    final now = DateTime.now();
    final isOverdue = !isDone && task.dueDate.isBefore(now);
    final daysLeft = task.dueDate.difference(now).inDays;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) => ref.read(studyPlannerProvider.notifier).remove(task.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDone ? AppColors.inputFill : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDone ? AppColors.border : _priorityColor.withValues(alpha: 0.3)),
          boxShadow: isDone ? [] : [
            BoxShadow(color: _priorityColor.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () {
                      final next = isDone ? TaskStatus.pending : TaskStatus.done;
                      ref.read(studyPlannerProvider.notifier).updateStatus(task.id, next);
                    },
                    child: Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? AppColors.success : Colors.transparent,
                        border: Border.all(color: isDone ? AppColors.success : AppColors.textLight, width: 2),
                      ),
                      child: isDone ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(task.subject,
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins',
                                      color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                                      decoration: isDone ? TextDecoration.lineThrough : null)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _priorityColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_priorityLabel, style: TextStyle(color: _priorityColor, fontSize: 9,
                                  fontWeight: FontWeight.w700, fontFamily: 'Poppins', letterSpacing: 0.5)),
                            ),
                          ],
                        ),
                        if (task.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(task.description,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                                    fontFamily: 'Poppins'), maxLines: 2),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.schedule_rounded, size: 12, color: isOverdue ? AppColors.error : AppColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              isOverdue ? 'Overdue!' : (daysLeft == 0 ? 'Due today' : 'Due in $daysLeft days'),
                              style: TextStyle(fontSize: 11, fontFamily: 'Poppins',
                                  color: isOverdue ? AppColors.error : AppColors.textSecondary,
                                  fontWeight: isOverdue ? FontWeight.w700 : FontWeight.normal),
                            ),
                            const Spacer(),
                            Icon(Icons.timer_outlined, size: 12, color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text('${task.loggedMinutes}/${task.estimatedMinutes}m',
                                style: const TextStyle(fontSize: 11, fontFamily: 'Poppins', color: AppColors.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            if (!isDone)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.inputFill,
                    valueColor: AlwaysStoppedAnimation<Color>(_priorityColor),
                    minHeight: 4,
                  ),
                ),
              ),
            // Actions
            if (!isDone)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  children: [
                    _miniBtn('Start', AppColors.info, Icons.play_arrow_rounded, () {
                      ref.read(studyPlannerProvider.notifier).updateStatus(task.id, TaskStatus.inProgress);
                    }),
                    const SizedBox(width: 8),
                    _miniBtn('Log 30m', AppColors.primary, Icons.add_rounded, () {
                      ref.read(studyPlannerProvider.notifier).logTime(task.id, 30);
                    }),
                  ],
                ),
              ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 350.ms).slideY(begin: 0.1),
    );
  }

  Widget _miniBtn(String label, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TIMETABLE TAB
// ─────────────────────────────────────────────────────────────

class _TimetableTab extends ConsumerWidget {
  static const _days  = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(timetableProvider);
    final todayIdx = (DateTime.now().weekday - 1).clamp(0, 6); // 0=Mon

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _days.length,
              itemBuilder: (ctx, i) {
                final isToday = i == todayIdx;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF6366F1) : AppColors.inputFill,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(_days[i],
                      style: TextStyle(
                          fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600,
                          color: isToday ? Colors.white : AppColors.textSecondary)),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Timetable grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hour labels
              Column(
                children: _hours.map((h) => SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: Text('${h.toString().padLeft(2, '0')}:00',
                        style: const TextStyle(fontSize: 10, color: AppColors.textLight, fontFamily: 'Poppins')),
                  ),
                )).toList(),
              ),
              // Day columns
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(7, (dayIdx) {
                    final daySlots = slots.where((s) => s.dayIndex == dayIdx).toList();
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 2),
                        child: Column(
                          children: _hours.map((hour) {
                            final slot = daySlots.where((s) => s.startHour == hour).firstOrNull;
                            return GestureDetector(
                              onTap: slot != null
                                  ? () => _showSlotOptions(context, ref, slot)
                                  : () => _showAddSlotSheet(context, ref, dayIdx, hour),
                              child: Container(
                                height: 56,
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: slot != null
                                      ? slot.color.withValues(alpha: 0.85)
                                      : AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(6),
                                  border: dayIdx == todayIdx
                                      ? Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3), width: 1)
                                      : null,
                                ),
                                child: slot != null
                                    ? Center(
                                        child: Text(slot.subject,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white, fontSize: 9,
                                                fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
                                            maxLines: 2),
                                      )
                                    : const Center(child: Icon(Icons.add, size: 12, color: AppColors.textLight)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          const Text('Tap any slot to add or remove a class.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  void _showSlotOptions(BuildContext context, WidgetRef ref, TimetableSlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(slot.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
            Text('${slot.startHour}:00 – ${slot.startHour + slot.durationHours}:00',
                style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.error),
              title: const Text('Remove this slot', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins')),
              onTap: () {
                ref.read(timetableProvider.notifier).remove(slot.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSlotSheet(BuildContext context, WidgetRef ref, int dayIdx, int hour) {
    final ctrl = TextEditingController();
    Color selectedColor = AppColors.primary;
    final colors = [AppColors.primary, AppColors.results, AppColors.academicHub,
                    AppColors.projects, AppColors.internships, AppColors.compExams,
                    AppColors.notifications, AppColors.certificates];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Class — ${_days[dayIdx]} ${hour}:00',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins', color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: 'Subject name',
                  filled: true, fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: colors.map((c) => GestureDetector(
                  onTap: () => setS(() => selectedColor = c),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle,
                      border: selectedColor == c ? Border.all(color: Colors.black, width: 3) : null,
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    if (ctrl.text.isEmpty) return;
                    ref.read(timetableProvider.notifier).add(TimetableSlot(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      dayIndex: dayIdx, startHour: hour, durationHours: 1,
                      subject: ctrl.text.trim(), color: selectedColor,
                    ));
                    Navigator.pop(ctx);
  },
                  child: const Text('Add to Timetable', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

// ─────────────────────────────────────────────────────────────
// POMODORO TAB
// ─────────────────────────────────────────────────────────────

class _PomodoroTab extends StatefulWidget {
  const _PomodoroTab();

  @override
  State<_PomodoroTab> createState() => _PomodoroTabState();
}

class _PomodoroTabState extends State<_PomodoroTab> {
  static const _workSecs  = 25 * 60;
  static const _breakSecs = 5 * 60;

  bool _isWork    = true;
  bool _running   = false;
  int  _remaining = _workSecs;
  int  _sessions  = 0;
  Timer? _timer;

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      setState(() => _running = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining > 0) {
          setState(() => _remaining--);
        } else {
          _timer?.cancel();
          if (_isWork) {
            setState(() { _sessions++; _isWork = false; _remaining = _breakSecs; _running = false; });
          } else {
            setState(() { _isWork = true; _remaining = _workSecs; _running = false; });
          }
        }
      });
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() { _running = false; _isWork = true; _remaining = _workSecs; });
  }

  String _fmt(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final total  = _isWork ? _workSecs : _breakSecs;
    final pct    = 1.0 - (_remaining / total);
    final color  = _isWork ? const Color(0xFF6366F1) : AppColors.success;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Mode label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _isWork ? '🧠 Focus Time' : '☕ Short Break',
              style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Poppins'),
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 32),

          // Circle timer
          SizedBox(
            width: 220, height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 12,
                    backgroundColor: color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_fmt(_remaining),
                        style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins', color: AppColors.textPrimary)),
                    Text(_isWork ? 'Focus' : 'Break',
                        style: TextStyle(fontSize: 14, color: color, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOut),

          const SizedBox(height: 40),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ctrl(Icons.refresh_rounded, AppColors.textSecondary, _reset, large: false),
              const SizedBox(width: 20),
              _ctrl(_running ? Icons.pause_rounded : Icons.play_arrow_rounded, color, _toggle, large: true),
              const SizedBox(width: 20),
              _ctrl(Icons.skip_next_rounded, AppColors.textSecondary, () {
                _timer?.cancel();
                setState(() {
                  _running = false;
                  _isWork = !_isWork;
                  _remaining = _isWork ? _workSecs : _breakSecs;
                });
              }, large: false),
            ],
          ),

          const SizedBox(height: 40),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox('Sessions\nCompleted', '$_sessions', color),
              _statBox('Time\nFocused', '${(_sessions * 25)}m', AppColors.projects),
              _statBox('Breaks\nTaken', '$_sessions', AppColors.warning),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💡 Pomodoro Tips', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                SizedBox(height: 8),
                Text('• Work for 25 minutes without distractions\n• Take a 5-minute break between sessions\n• After 4 sessions, take a 15–30 minute long break\n• Put your phone face-down during focus time',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins', height: 1.7)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctrl(IconData icon, Color color, VoidCallback onTap, {required bool large}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: large ? 72 : 52, height: large ? 72 : 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: large ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))] : [],
        ),
        child: Icon(icon, color: Colors.white, size: large ? 36 : 24),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color, fontFamily: 'Poppins')),
          Text(label, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}
