// ============================================================
// certificates_screen.dart
// MyVault — Premium Certificates Hub
// Tabs: Course Certificates | Project Certificates | Academic Certificates
// Features: PDF generation, share, download, beautiful UI
// ============================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';

// ─────────────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────────────

enum CertType { course, project, academic }

class CertItem {
  final String id;
  final String title;
  final String subtitle;    // course name / project title / subject
  final String recipientName;
  final String? issuedBy;
  final DateTime issuedAt;
  final CertType type;
  final String? verificationId;

  const CertItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.recipientName,
    this.issuedBy,
    required this.issuedAt,
    required this.type,
    this.verificationId,
  });
}

// ─────────────────────────────────────────────────────────────
// PROVIDERS
// ─────────────────────────────────────────────────────────────

final _supabase = Supabase.instance.client;

final _certsProvider = FutureProvider.autoDispose<List<CertItem>>((ref) async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return [];

  // Load student name
  final studentRow = await _supabase
      .from('students')
      .select('first_name, last_name, college_id')
      .eq('id', uid)
      .maybeSingle();
  final name = studentRow == null
      ? 'Student'
      : '${studentRow['first_name'] ?? ''} ${studentRow['last_name'] ?? ''}'.trim();

  final List<CertItem> certs = [];

  // 1. Academic Certificates (from `certificates` table)
  try {
    final rows = await _supabase
        .from('certificates')
        .select()
        .eq('student_id', uid)
        .order('issued_at', ascending: false);
    for (final r in rows as List) {
      certs.add(CertItem(
        id: r['id'].toString(),
        title: r['title'] ?? 'Certificate of Achievement',
        subtitle: r['course_name'] ?? r['description'] ?? '',
        recipientName: name,
        issuedBy: r['issued_by'] ?? 'MyVault Academy',
        issuedAt: r['issued_at'] != null
            ? DateTime.tryParse(r['issued_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        type: CertType.academic,
        verificationId: r['id'].toString().substring(0, 8).toUpperCase(),
      ));
    }
  } catch (_) {}

  // 2. Course Certificates (from `course_certificates` table)
  try {
    final rows = await _supabase
        .from('course_certificates')
        .select('*, internship_courses(title)')
        .eq('student_id', uid)
        .order('issued_at', ascending: false);
    for (final r in rows as List) {
      final courseTitle = r['internship_courses']?['title'] ?? r['course_id'] ?? 'Course';
      certs.add(CertItem(
        id: r['id'].toString(),
        title: 'Certificate of Completion',
        subtitle: courseTitle,
        recipientName: name,
        issuedBy: 'MyVault Learning',
        issuedAt: r['issued_at'] != null
            ? DateTime.tryParse(r['issued_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        type: CertType.course,
        verificationId: r['id'].toString().substring(0, 8).toUpperCase(),
      ));
    }
  } catch (_) {}

  // 3. Project Certificates (from `project_submissions` where status = approved)
  try {
    final rows = await _supabase
        .from('project_submissions')
        .select('*, projects(title)')
        .eq('student_id', uid)
        .eq('status', 'approved')
        .order('updated_at', ascending: false);
    for (final r in rows as List) {
      final projectTitle = r['projects']?['title'] ?? 'Project';
      certs.add(CertItem(
        id: r['id'].toString(),
        title: 'Certificate of Project Excellence',
        subtitle: projectTitle,
        recipientName: name,
        issuedBy: 'MyVault Innovation Hub',
        issuedAt: r['updated_at'] != null
            ? DateTime.tryParse(r['updated_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        type: CertType.project,
        verificationId: r['id'].toString().substring(0, 8).toUpperCase(),
      ));
    }
  } catch (_) {}

  // Sort all by date descending
  certs.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
  return certs;
});

// ─────────────────────────────────────────────────────────────
// MAIN SCREEN
// ─────────────────────────────────────────────────────────────

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final certsAsync = ref.watch(_certsProvider);

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () {},
          ),
          _buildStatsHeader(certsAsync),
          _buildTabBar(),
          Expanded(
            child: certsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.certificates)),
              error: (e, _) => _buildEmpty('Unable to load certificates'),
              data: (certs) {
                final course   = certs.where((c) => c.type == CertType.course).toList();
                final project  = certs.where((c) => c.type == CertType.project).toList();
                final academic = certs.where((c) => c.type == CertType.academic).toList();
                return TabBarView(
                  controller: _tab,
                  children: [
                    _CertList(certs: certs,    emptyMsg: 'No certificates yet\nComplete courses & projects to earn them!'),
                    _CertList(certs: course,   emptyMsg: 'No course certificates yet\nComplete internship courses to earn one!'),
                    _CertList(certs: project,  emptyMsg: 'No project certificates yet\nSubmit and get a project approved!'),
                    _CertList(certs: academic, emptyMsg: 'No academic certificates yet'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(AsyncValue<List<CertItem>> certsAsync) {
    final count = certsAsync.valueOrNull?.length ?? 0;
    final courseCount   = certsAsync.valueOrNull?.where((c) => c.type == CertType.course).length ?? 0;
    final projectCount  = certsAsync.valueOrNull?.where((c) => c.type == CertType.project).length ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE67E22), Color(0xFFF39C12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.certificates.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Certificates',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Poppins')),
                const SizedBox(height: 2),
                Text('$count total • $courseCount course • $projectCount project',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tab,
        indicator: BoxDecoration(
          color: AppColors.certificates,
          borderRadius: BorderRadius.circular(11),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 11),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Course'),
          Tab(text: 'Project'),
          Tab(text: 'Academic'),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium_outlined, size: 80, color: AppColors.certificates.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 14)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CERT LIST
// ─────────────────────────────────────────────────────────────

class _CertList extends StatelessWidget {
  final List<CertItem> certs;
  final String emptyMsg;
  const _CertList({required this.certs, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (certs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 72,
                color: AppColors.certificates.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(emptyMsg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 14, height: 1.6)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: certs.length,
      itemBuilder: (ctx, i) =>
          _CertCard(cert: certs[i], index: i),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CERT CARD
// ─────────────────────────────────────────────────────────────

class _CertCard extends StatelessWidget {
  final CertItem cert;
  final int index;
  const _CertCard({required this.cert, required this.index});

  Color get _color {
    switch (cert.type) {
      case CertType.course:   return const Color(0xFF6C63FF);
      case CertType.project:  return const Color(0xFF2ECC71);
      case CertType.academic: return AppColors.certificates;
    }
  }

  IconData get _icon {
    switch (cert.type) {
      case CertType.course:   return Icons.school_rounded;
      case CertType.project:  return Icons.code_rounded;
      case CertType.academic: return Icons.emoji_events_rounded;
    }
  }

  String get _typeLabel {
    switch (cert.type) {
      case CertType.course:   return 'COURSE';
      case CertType.project:  return 'PROJECT';
      case CertType.academic: return 'ACADEMIC';
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return GestureDetector(
      onTap: () => _showCertPreview(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Gold banner top
            Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_color, _color.withValues(alpha: 0.5)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_icon, color: _color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_typeLabel,
                                  style: TextStyle(
                                      color: _color, fontSize: 10, fontWeight: FontWeight.w700,
                                      fontFamily: 'Poppins', letterSpacing: 0.8)),
                            ),
                            const SizedBox(height: 4),
                            Text(cert.title,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary, fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('AWARDED TO',
                                  style: TextStyle(fontSize: 9, color: AppColors.textLight,
                                      fontFamily: 'Poppins', fontWeight: FontWeight.w600, letterSpacing: 1)),
                              const SizedBox(height: 2),
                              Text(cert.recipientName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary, fontFamily: 'Poppins')),
                              const SizedBox(height: 6),
                              Text(cert.subtitle,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary,
                                      fontFamily: 'Poppins'), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('ISSUED ON',
                                style: TextStyle(fontSize: 9, color: AppColors.textLight,
                                    fontFamily: 'Poppins', fontWeight: FontWeight.w600, letterSpacing: 1)),
                            const SizedBox(height: 2),
                            Text(df.format(cert.issuedAt),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary, fontFamily: 'Poppins')),
                            if (cert.verificationId != null) ...[
                              const SizedBox(height: 4),
                              Text('ID: ${cert.verificationId}',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textLight,
                                      fontFamily: 'Poppins')),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.visibility_rounded,
                          label: 'View',
                          color: _color,
                          onTap: () => _showCertPreview(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.download_rounded,
                          label: 'Download',
                          color: AppColors.success,
                          onTap: () => _downloadPdf(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.share_rounded,
                          label: 'Share',
                          color: const Color(0xFF3B82F6),
                          onTap: () => _sharePdf(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 80)).fadeIn(duration: 350.ms).slideY(begin: 0.15, end: 0);
  }

  void _showCertPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: _CertificatePreviewWidget(cert: cert),
      ),
    );
  }

  Future<Uint8List> _buildPdf() async {
    final pdf = pw.Document();
    final certColor = PdfColor.fromHex(_color.value.toRadixString(16).padLeft(8, '0').substring(2));
    final df = DateFormat('MMMM dd, yyyy');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context ctx) {
          return pw.Stack(
            children: [
              // Background
              pw.Container(
                decoration: pw.BoxDecoration(
                  gradient: pw.LinearGradient(
                    colors: [PdfColors.white, PdfColor.fromHex('F8F8FF')],
                    begin: pw.Alignment.topLeft,
                    end: pw.Alignment.bottomRight,
                  ),
                ),
              ),
              // Decorative border
              pw.Positioned.fill(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: certColor, width: 3),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  ),
                ),
              ),
              // Inner border
              pw.Positioned.fill(
                child: pw.Container(
                  margin: const pw.EdgeInsets.all(28),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400, width: 1),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                ),
              ),
              // Content
              pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    // Header
                    pw.Text('MyVault', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: certColor)),
                    pw.SizedBox(height: 4),
                    pw.Text('Certificate of Achievement', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600, letterSpacing: 3)),
                    pw.SizedBox(height: 24),
                    pw.Container(width: 120, height: 2, color: certColor),
                    pw.SizedBox(height: 24),
                    pw.Text('This is to certify that', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    pw.SizedBox(height: 12),
                    pw.Text(cert.recipientName,
                        style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                    pw.SizedBox(height: 12),
                    pw.Text('has successfully completed', style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    pw.SizedBox(height: 8),
                    pw.Text(cert.subtitle,
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: certColor),
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 32),
                    pw.Container(width: 80, height: 1, color: PdfColors.grey400),
                    pw.SizedBox(height: 24),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Column(children: [
                          pw.Text(df.format(cert.issuedAt), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text('Date of Issue', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 11)),
                        ]),
                        pw.SizedBox(width: 60),
                        pw.Column(children: [
                          pw.Text(cert.issuedBy ?? 'MyVault', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          pw.Text('Issued By', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 11)),
                        ]),
                        if (cert.verificationId != null) ...[
                          pw.SizedBox(width: 60),
                          pw.Column(children: [
                            pw.Text(cert.verificationId!, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                            pw.Text('Verification ID', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 11)),
                          ]),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      final bytes = await _buildPdf();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final bytes = await _buildPdf();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/certificate_${cert.id}.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: '${cert.title} — ${cert.subtitle}');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────
// ACTION BUTTON
// ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CERTIFICATE PREVIEW WIDGET (in-app preview)
// ─────────────────────────────────────────────────────────────

class _CertificatePreviewWidget extends StatelessWidget {
  final CertItem cert;
  const _CertificatePreviewWidget({required this.cert});

  Color get _color {
    switch (cert.type) {
      case CertType.course:   return const Color(0xFF6C63FF);
      case CertType.project:  return const Color(0xFF2ECC71);
      case CertType.academic: return AppColors.certificates;
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('MMMM dd, yyyy');
    return Container(
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _color, width: 3),
        boxShadow: [
          BoxShadow(color: _color.withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top gradient banner
          Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_color, _color.withValues(alpha: 0.6)]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Seal
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_color, _color.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [BoxShadow(color: _color.withValues(alpha: 0.4), blurRadius: 16)],
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text('MyVault',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                        color: _color, fontFamily: 'Poppins', letterSpacing: 1)),
                Text('Certificate of Achievement',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary,
                        fontFamily: 'Poppins', letterSpacing: 2)),
                const SizedBox(height: 16),
                Divider(color: _color.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                const Text('This is to certify that',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Text(cert.recipientName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary, fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                const Text('has successfully completed',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Text(cert.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                        color: _color, fontFamily: 'Poppins')),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PreviewStat('Date', df.format(cert.issuedAt)),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _PreviewStat('Issued By', cert.issuedBy ?? 'MyVault'),
                      if (cert.verificationId != null) ...[
                        Container(width: 1, height: 32, color: AppColors.border),
                        _PreviewStat('ID', cert.verificationId!),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Close', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().scale(begin: const Offset(0.85, 0.85), duration: 300.ms, curve: Curves.easeOutBack);
  }
}

class _PreviewStat extends StatelessWidget {
  final String label;
  final String value;
  const _PreviewStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textLight,
            fontFamily: 'Poppins', fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.textPrimary, fontFamily: 'Poppins'), textAlign: TextAlign.center),
      ],
    );
  }
}
