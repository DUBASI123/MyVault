import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/resume_model.dart';

class ResumePdfService {
  static Future<Uint8List> generatePdf(ResumeModel resume) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                resume.fullName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.indigo900,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                '${resume.email}  |  ${resume.phone}  |  ${resume.location}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Text(
                'GitHub: ${resume.github}  |  LinkedIn: ${resume.linkedin}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              pw.Divider(thickness: 1, color: PdfColors.indigo900),
              pw.SizedBox(height: 8),

              // Summary
              pw.Text('PROFESSIONAL SUMMARY',
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900)),
              pw.SizedBox(height: 4),
              pw.Text(resume.summary,
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
              pw.SizedBox(height: 12),

              // Education
              pw.Text('EDUCATION',
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900)),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('${resume.degree} in ${resume.branch}',
                      style: pw.TextStyle(
                          fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Graduation: ${resume.yearOfGraduation}',
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
              pw.Text('${resume.college} — CGPA: ${resume.cgpa}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
              pw.SizedBox(height: 12),

              // Skills
              pw.Text('TECHNICAL SKILLS',
                  style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.indigo900)),
              pw.SizedBox(height: 4),
              pw.Text(resume.skills.join('  •  '),
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.black)),
              pw.SizedBox(height: 12),

              // Projects
              if (resume.projects.isNotEmpty) ...[
                pw.Text('PROJECTS',
                    style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900)),
                pw.SizedBox(height: 4),
                ...resume.projects.map(
                  (p) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(p.title,
                            style: pw.TextStyle(
                                fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.Text(p.description,
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Technologies: ${p.technologies}',
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
              ],

              // Experience
              if (resume.experiences.isNotEmpty) ...[
                pw.Text('EXPERIENCE',
                    style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo900)),
                pw.SizedBox(height: 4),
                ...resume.experiences.map(
                  (e) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('${e.role} — ${e.company}',
                                style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text(e.duration,
                                style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        pw.Text(e.highlights,
                            style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printOrExport(ResumeModel resume) async {
    final pdfBytes = await generatePdf(resume);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${resume.fullName.replaceAll(' ', '_')}_Resume.pdf',
    );
  }
}
