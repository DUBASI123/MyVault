// ============================================================
// screens/certificate_view_screen.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/internship_models.dart';
import '../providers/internship_providers.dart';
import '../../../../core/constants/app_colors.dart';

class CertificateViewScreen extends ConsumerWidget {
  final String courseId;
  const CertificateViewScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(internshipRepositoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1D3B),
      appBar: AppBar(
        title: const Text('Certificate', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        backgroundColor: const Color(0xFF1A1D3B),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<CourseCertificate?>(
        future: repo.fetchCertificate(courseId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }
          if (snap.hasError || snap.data == null) {
            return const Center(
              child: Text('Certificate not found', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
            );
          }

          final cert = snap.data!;
          final dateStr = DateFormat('d MMMM yyyy').format(cert.issuedAt);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Certificate card
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFFF8DC), Color(0xFFFFFAE6), Color(0xFFFFF0B3)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700), width: 2.5),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                            const SizedBox(width: 8),
                            Text('CERTIFICATE OF COMPLETION',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Poppins',
                                  color: Colors.brown[700],
                                  letterSpacing: 1.5,
                                )),
                            const SizedBox(width: 8),
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 24),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Divider(color: const Color(0xFFFFD700).withValues(alpha: 0.4), thickness: 1),
                        const SizedBox(height: 20),

                        // "This is to certify that"
                        Text('This is to certify that',
                            style: TextStyle(fontSize: 13, color: Colors.brown[600], fontFamily: 'Poppins', fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),

                        // Student name
                        Text(cert.studentName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                              color: Color(0xFF1A1D3B),
                            ),
                            textAlign: TextAlign.center),
                        if (cert.hallTicketNo.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('(${cert.hallTicketNo})',
                              style: TextStyle(fontSize: 12, color: Colors.brown[600], fontFamily: 'Poppins')),
                        ],
                        const SizedBox(height: 16),

                        Text('has successfully completed',
                            style: TextStyle(fontSize: 13, color: Colors.brown[600], fontFamily: 'Poppins', fontStyle: FontStyle.italic)),
                        const SizedBox(height: 12),

                        // Course title
                        Text(cert.courseTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                              color: AppColors.internships,
                            ),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 24),

                        // Score + Grade
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _certStat('Score', '${cert.testScore}/${cert.testMaxScore}'),
                              Container(width: 1, height: 40, color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                              _certStat('Percentage', '${cert.scorePercentage.round()}%'),
                              Container(width: 1, height: 40, color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                              _certStat('Grade', cert.grade),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Divider(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
                        const SizedBox(height: 16),

                        // Footer: date + verification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Issued on', style: TextStyle(fontSize: 11, color: Colors.brown[500], fontFamily: 'Poppins')),
                                Text(dateStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins', color: Color(0xFF1A1D3B))),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Verification Code', style: TextStyle(fontSize: 11, color: Colors.brown[500], fontFamily: 'Poppins')),
                                Text(cert.verificationCode,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins', color: Color(0xFF1A1D3B), letterSpacing: 2)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),
                // Congrats text
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Keep building your career!',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins', color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This certificate validates your skill in internship-ready competencies. Share it with recruiters to stand out!',
                        style: TextStyle(fontSize: 12, color: Colors.white54, fontFamily: 'Poppins', height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _certStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
            fontFamily: 'Poppins', color: Color(0xFF1A1D3B))),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.brown[600], fontFamily: 'Poppins')),
      ],
    );
  }
}
