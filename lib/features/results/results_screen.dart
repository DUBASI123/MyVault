import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';
import '../../core/router/app_router.dart';

class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _results = [];
  int _selectedSemester = 1;
  final Set<int> _availableSemesters = {};

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => _loading = true);
    try {
      final student = ref.read(currentStudentProvider);
      final response = await Supabase.instance.client
          .from('exam_results')
          .select()
          .eq('branch', student?.branch ?? 'CSE')
          .order('semester', ascending: true);

      final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(response);
      _results = data;

      _availableSemesters.clear();
      for (var row in data) {
        final sem = row['semester'] as int?;
        if (sem != null) {
          _availableSemesters.add(sem);
        }
      }

      if (_availableSemesters.isNotEmpty) {
        if (!_availableSemesters.contains(_selectedSemester)) {
          _selectedSemester = _availableSemesters.first;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading results: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _gradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case 'O':
        return 10;
      case 'A+':
      case 'S':
        return 9;
      case 'A':
        return 8;
      case 'B+':
        return 7;
      case 'B':
        return 6;
      case 'C':
        return 5;
      case 'D':
      case 'E':
        return 4;
      default:
        return 0;
    }
  }

  // Calculate SGPA for a specific semester
  double _calculateSGPA(int semester) {
    final semResults = _results.where((r) => r['semester'] == semester).toList();
    if (semResults.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalCredits = 0;
    for (var r in semResults) {
      // Default to 3 credits if not defined
      final int credits = r['credits'] as int? ?? 3;
      final int gradePoint = _gradeToPoint(r['grade'] as String? ?? 'F');
      totalPoints += gradePoint * credits;
      totalCredits += credits;
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  // Calculate CGPA (Average of all available semester SGPAs)
  double _calculateCGPA() {
    if (_availableSemesters.isEmpty) return 0.0;
    double sumSGPA = 0;
    int count = 0;
    for (var sem in _availableSemesters) {
      final sgpa = _calculateSGPA(sem);
      if (sgpa > 0) {
        sumSGPA += sgpa;
        count++;
      }
    }
    return count > 0 ? sumSGPA / count : 0.0;
  }

  String _getCGPABadge(double cgpa) {
    if (cgpa >= 8.5) return 'Distinction';
    if (cgpa >= 7.0) return 'First Class';
    if (cgpa >= 5.5) return 'Second Class';
    if (cgpa >= 4.0) return 'Pass Class';
    return 'Fail';
  }

  Color _getCGPAColor(double cgpa) {
    if (cgpa >= 8.0) return AppColors.success;
    if (cgpa >= 6.0) return AppColors.warning;
    return AppColors.error;
  }

  // Export Results to PDF
  Future<void> _exportToPDF() async {
    final student = ref.read(currentStudentProvider);
    final pdf = pw.Document();

    final cgpa = _calculateCGPA();
    final badge = _getCGPABadge(cgpa);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(student?.collegeName ?? 'MyVault College',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text('OFFICIAL SEMESTER MEMO',
                    style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Student Name: ${student?.displayName ?? "Student"}'),
                        pw.Text('Branch: ${student?.branch ?? "N/A"}'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Current CGPA: ${cgpa.toStringAsFixed(2)}'),
                        pw.Text('Classification: $badge'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text('Academic Record:',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Subject', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Code', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Sem', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Marks', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Grade', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ..._results.map((r) => pw.TableRow(
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(r['subject']?.toString() ?? '')),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(r['code']?.toString() ?? '')),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(r['semester']?.toString() ?? '')),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text('${r['total']}/${r['max_marks'] ?? r['max'] ?? 100}')),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(r['grade']?.toString() ?? 'F')),
                            pw.Padding(
                                padding: const pw.EdgeInsets.all(6),
                                child: pw.Text(r['status']?.toString() ?? 'Fail')),
                          ],
                        )),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _showHypotheticalCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HypotheticalGPACalculatorSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final cgpa = _calculateCGPA();
    final cgpaColor = _getCGPAColor(cgpa);
    final cgpaBadge = _getCGPABadge(cgpa);

    final backlogs = _results.where((r) => (r['status']?.toString().toLowerCase() == 'fail' || r['grade'] == 'F')).toList();

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'MyVault Academy',
            studentName: student?.displayName ?? 'Student',
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _fetchResults,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Premium Header CGPA Hero Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E1E38), Color(0xFF0F0F23)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Cumulative GPA',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        cgpa > 0 ? cgpa.toStringAsFixed(2) : '0.00',
                                        style: const TextStyle(
                                          color: AppColors.textWhite,
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: cgpaColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: cgpaColor.withValues(alpha: 0.3)),
                                        ),
                                        child: Text(
                                          cgpaBadge,
                                          style: TextStyle(
                                            color: cgpaColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildActionBtn(
                                      icon: Icons.calculate_outlined,
                                      label: 'GPA Calc',
                                      onTap: _showHypotheticalCalculator,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildActionBtn(
                                      icon: Icons.picture_as_pdf_outlined,
                                      label: 'PDF Memo',
                                      onTap: _exportToPDF,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 2. Custom Painted SGPA Trend Chart
                          const Text('SGPA Trend', style: AppTextStyles.heading2),
                          const SizedBox(height: 12),
                          Container(
                            height: 180,
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: CustomPaint(
                              painter: _SGPATrendPainter(
                                sgpaMap: {
                                  for (int i = 1; i <= 8; i++) i: _calculateSGPA(i),
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // 3. Backlog Tracker
                          if (backlogs.isNotEmpty) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Active Backlogs (${backlogs.length})',
                                          style: AppTextStyles.heading3.copyWith(color: AppColors.error),
                                        ),
                                        Text(
                                          'Clear them before placement season starts.',
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => context.push(AppRoutes.academicHub),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: AppColors.textWhite,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    child: const Text('Study Now'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          // 4. Semester Pill Selector & Result Cards
                          const Text('Semester Results', style: AppTextStyles.heading2),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(8, (index) {
                                final sem = index + 1;
                                final hasResults = _availableSemesters.contains(sem);
                                final isSelected = _selectedSemester == sem;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text('Sem $sem'),
                                    selected: isSelected,
                                    selectedColor: AppColors.primary,
                                    backgroundColor: AppColors.surface,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? AppColors.textWhite
                                          : (hasResults ? AppColors.textPrimary : AppColors.textSecondary),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : (hasResults ? AppColors.border : AppColors.border.withValues(alpha: 0.5)),
                                      ),
                                    ),
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedSemester = sem);
                                      }
                                    },
                                  ),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Results for selected semester
                          _buildSemesterResultsList(_selectedSemester),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterResultsList(int sem) {
    final semResults = _results.where((r) => r['semester'] == sem).toList();

    if (semResults.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              'No results published yet for Semester $sem',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final sgpa = _calculateSGPA(sem);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subjects (${semResults.length})',
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'SGPA: ${sgpa.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.primaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...semResults.map((r) {
          final isPass = r['status']?.toString().toLowerCase() == 'pass';
          final color = isPass ? AppColors.success : AppColors.error;
          final maxMarks = r['max_marks'] ?? r['max'] ?? 100;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Grade Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      r['grade']?.toString() ?? 'F',
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Subject Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r['subject']?.toString() ?? 'Unknown Subject',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r['code']?.toString() ?? 'N/A',
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Marks and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${r['total']}/$maxMarks',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPass ? 'PASS' : 'FAIL',
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─── Custom SGPA Chart Painter ───────────────────────────────────────────────
class _SGPATrendPainter extends CustomPainter {
  final Map<int, double> sgpaMap;

  _SGPATrendPainter({required this.sgpaMap});

  @override
  void paint(Canvas canvas, Size size) {
    final double paddingX = 24;
    final double paddingY = 20;
    final double graphWidth = size.width - (paddingX * 2);
    final double graphHeight = size.height - (paddingY * 2);

    final double stepX = graphWidth / 7;

    // Draw horizontal grid lines
    final Paint gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Draw grid lines at GPA 2, 4, 6, 8, 10
    for (int i = 0; i <= 5; i++) {
      final double gpaVal = i * 2.0;
      final double y = paddingY + graphHeight - (gpaVal / 10.0 * graphHeight);
      canvas.drawLine(Offset(paddingX, y), Offset(size.width - paddingX, y), gridPaint);

      // Label
      textPainter.text = TextSpan(
        text: gpaVal.toStringAsFixed(0),
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    // Draw Bars
    for (int i = 1; i <= 8; i++) {
      final double sgpa = sgpaMap[i] ?? 0.0;
      final double x = paddingX + (i - 1) * stepX;

      // Draw bottom label "S1", "S2"...
      textPainter.text = TextSpan(
        text: 'S$i',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), size.height - 14));

      if (sgpa <= 0) continue;

      // Determine color
      Color barColor = AppColors.error;
      if (sgpa >= 8.0) {
        barColor = AppColors.success;
      } else if (sgpa >= 6.0) {
        barColor = AppColors.warning;
      }

      final double barHeight = (sgpa / 10.0) * graphHeight;
      final double topY = paddingY + graphHeight - barHeight;

      final Rect barRect = Rect.fromLTRB(x - 8, topY, x + 8, paddingY + graphHeight);
      final RRect roundedBar = RRect.fromRectAndCorners(
        barRect,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );

      final Paint barPaint = Paint()..color = barColor;
      canvas.drawRRect(roundedBar, barPaint);

      // Draw value on top of bar
      textPainter.text = TextSpan(
        text: sgpa.toStringAsFixed(1),
        style: TextStyle(color: barColor, fontSize: 8, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - (textPainter.width / 2), topY - 12));
    }
  }

  @override
  bool shouldRepaint(covariant _SGPATrendPainter oldDelegate) {
    return oldDelegate.sgpaMap != sgpaMap;
  }
}

// ─── Hypothetical GPA Calculator Bottom Sheet ────────────────────────────────
class _HypotheticalGPACalculatorSheet extends StatefulWidget {
  const _HypotheticalGPACalculatorSheet();

  @override
  State<_HypotheticalGPACalculatorSheet> createState() => _HypotheticalGPACalculatorSheetState();
}

class _HypotheticalGPACalculatorSheetState extends State<_HypotheticalGPACalculatorSheet> {
  final List<_HypotheticalSubject> _subjects = [
    _HypotheticalSubject(name: 'Subject 1', credits: 3, grade: 'A'),
    _HypotheticalSubject(name: 'Subject 2', credits: 3, grade: 'A'),
    _HypotheticalSubject(name: 'Subject 3', credits: 4, grade: 'B+'),
  ];

  double _calculateEstimatedSGPA() {
    double totalPoints = 0;
    int totalCredits = 0;

    for (var s in _subjects) {
      final points = _gradeToPoint(s.grade);
      totalPoints += points * s.credits;
      totalCredits += s.credits;
    }

    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  int _gradeToPoint(String grade) {
    switch (grade.toUpperCase()) {
      case 'O': return 10;
      case 'A+': return 9;
      case 'A': return 8;
      case 'B+': return 7;
      case 'B': return 6;
      case 'C': return 5;
      case 'D': return 4;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estimatedSGPA = _calculateEstimatedSGPA();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hypothetical GPA Calculator', style: AppTextStyles.heading2),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Estimate your SGPA by selecting expected grades and credits.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Total / Estimate Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated SGPA', style: TextStyle(color: AppColors.textWhite, fontSize: 13)),
                    SizedBox(height: 4),
                    Text('Based on input below', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
                Text(
                  estimatedSGPA.toStringAsFixed(2),
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Subject Rows list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _subjects.length,
              itemBuilder: (context, index) {
                final sub = _subjects[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Subject Name',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          controller: TextEditingController(text: sub.name)..selection = TextSelection.collapsed(offset: sub.name.length),
                          onChanged: (val) => sub.name = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Credits Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<int>(
                          value: sub.credits,
                          underline: const SizedBox(),
                          items: [1, 2, 3, 4].map((c) {
                            return DropdownMenuItem<int>(
                              value: c,
                              child: Text('$c L'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => sub.credits = val);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Grade Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: sub.grade,
                          underline: const SizedBox(),
                          items: ['O', 'A+', 'A', 'B+', 'B', 'C', 'D', 'F'].map((g) {
                            return DropdownMenuItem<String>(
                              value: g,
                              child: Text(g),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => sub.grade = val);
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                        onPressed: () {
                          setState(() {
                            _subjects.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _subjects.add(
                      _HypotheticalSubject(
                        name: 'Subject ${_subjects.length + 1}',
                        credits: 3,
                        grade: 'A',
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add, color: AppColors.primaryLight),
                label: const Text('Add Subject', style: TextStyle(color: AppColors.primaryLight)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HypotheticalSubject {
  String name;
  int credits;
  String grade;

  _HypotheticalSubject({
    required this.name,
    required this.credits,
    required this.grade,
  });
}
