import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/supabase_service.dart';
import '../models/academic_content_model.dart';
import '../models/subject_model.dart';

final subjectContentsProvider = FutureProvider.family<List<AcademicContentModel>, String>((ref, subjectId) async {
  return AcademicService.getContentsBySubject(subjectId: subjectId);
});

class AcademicService {
  AcademicService._();

  static const String bucketName = 'academic-files';

  static Future<List<SubjectModel>> getSubjects({
    required String branch,
    required int semester,
    String subjectType = 'academic',
  }) async {
    List<SubjectModel> subjects = [];
    try {
      final response = await SupabaseService.client
          .from('subjects')
          .select()
          .ilike('branch', '%$branch%')
          .eq('semester', semester)
          .eq('subject_type', subjectType)
          .order('name');
      subjects = (response as List)
          .map((e) => SubjectModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Supabase getSubjects error: $e');
    }

    // GUARANTEED NATIVE FALLBACK LIST if database query returns empty
    if (subjects.isEmpty) {
      subjects = _getFallbackSubjects(branch: branch, semester: semester, subjectType: subjectType);
    }

    return subjects;
  }

  static List<SubjectModel> _getFallbackSubjects({
    required String branch,
    required int semester,
    required String subjectType,
  }) {
    final b = branch.toUpperCase();
    if (subjectType == 'academic') {
      if (b.contains('ECE')) {
        return [
          SubjectModel(id: 'ece_sem${semester}_1', name: 'Basic Electronics & Circuit Theory', code: 'EC101', branch: branch, semester: semester),
          SubjectModel(id: 'ece_sem${semester}_2', name: 'Engineering Mathematics I (Calculus & Linear Algebra)', code: 'MA101', branch: branch, semester: semester),
          SubjectModel(id: 'ece_sem${semester}_3', name: 'Engineering Physics & Semiconductor Electronics', code: 'PH101', branch: branch, semester: semester),
          SubjectModel(id: 'ece_sem${semester}_4', name: 'Problem Solving & Programming in C', code: 'CS101', branch: branch, semester: semester),
          SubjectModel(id: 'ece_sem${semester}_5', name: 'Signals & Systems Analysis', code: 'EC102', branch: branch, semester: semester),
        ];
      } else if (b.contains('CSE')) {
        return [
          SubjectModel(id: 'cse_sem${semester}_1', name: 'Data Structures & Algorithms in C/C++', code: 'CS101', branch: branch, semester: semester),
          SubjectModel(id: 'cse_sem${semester}_2', name: 'Discrete Mathematics & Graph Theory', code: 'MA102', branch: branch, semester: semester),
          SubjectModel(id: 'cse_sem${semester}_3', name: 'Digital Logic & Computer Architecture', code: 'CS102', branch: branch, semester: semester),
          SubjectModel(id: 'cse_sem${semester}_4', name: 'Object Oriented Programming with Java', code: 'CS103', branch: branch, semester: semester),
          SubjectModel(id: 'cse_sem${semester}_5', name: 'Database Management Systems (DBMS)', code: 'CS104', branch: branch, semester: semester),
        ];
      } else {
        return [
          SubjectModel(id: 'gen_sem${semester}_1', name: '$branch Core Engineering Subject I', code: '${branch}101', branch: branch, semester: semester),
          SubjectModel(id: 'gen_sem${semester}_2', name: 'Engineering Mathematics & Calculus', code: 'MA101', branch: branch, semester: semester),
          SubjectModel(id: 'gen_sem${semester}_3', name: 'Applied Engineering Physics & Chemistry', code: 'PH101', branch: branch, semester: semester),
          SubjectModel(id: 'gen_sem${semester}_4', name: 'Basic Computer Programming & Logic', code: 'CS101', branch: branch, semester: semester),
        ];
      }
    } else if (subjectType == 'tech_skill') {
      return [
        SubjectModel(id: 'tech_1', name: 'Python Programming & Data Analysis', code: 'TECH101', branch: branch, semester: semester, subjectType: 'tech_skill'),
        SubjectModel(id: 'tech_2', name: 'Full-Stack Web Development (React & Node.js)', code: 'TECH102', branch: branch, semester: semester, subjectType: 'tech_skill'),
        SubjectModel(id: 'tech_3', name: 'Flutter & Cross-Platform Mobile App Dev', code: 'TECH103', branch: branch, semester: semester, subjectType: 'tech_skill'),
      ];
    } else if (subjectType == 'exam_prep') {
      return [
        SubjectModel(id: 'exam_1', name: 'GATE ECE / CSE Core Technical Series', code: 'GATE101', branch: branch, semester: semester, subjectType: 'exam_prep'),
        SubjectModel(id: 'exam_2', name: 'Quantitative Aptitude & Logical Reasoning', code: 'APT101', branch: branch, semester: semester, subjectType: 'exam_prep'),
      ];
    } else {
      return [
        SubjectModel(id: 'comm_1', name: 'Corporate & Technical Communication Skills', code: 'COMM101', branch: branch, semester: semester, subjectType: 'comm_skill'),
        SubjectModel(id: 'comm_2', name: 'Interview Preparation & Resume Writing', code: 'COMM102', branch: branch, semester: semester, subjectType: 'comm_skill'),
      ];
    }
  }

  static Future<List<AcademicContentModel>> getContentsBySubject({
    required String subjectId,
    String contentType = 'all',
  }) async {
    try {
      var query = SupabaseService.client
          .from('academic_contents')
          .select()
          .eq('subject_id', subjectId);
      if (contentType != 'all') {
        query = query.eq('content_type', contentType);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((e) => AcademicContentModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Supabase getContentsBySubject error: $e');
      rethrow;
    }
  }

  static Future<AcademicContentModel> uploadAcademicFile({
    required File file,
    required String subjectId,
    required String title,
    required String contentType,
    String? description,
    int? unitNumber,
  }) async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) throw Exception('Login required');

    final extension = file.path.split('.').last.toLowerCase();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final storagePath = '$subjectId/$contentType/$fileName';

    await SupabaseService.client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: _mimeType(extension),
            upsert: false,
          ),
        );

    final publicUrl = SupabaseService.client.storage
        .from(bucketName)
        .getPublicUrl(storagePath);

    final inserted = await SupabaseService.client
        .from('academic_contents')
        .insert({
          'subject_id': subjectId,
          'title': title,
          'content_type': contentType,
          'description': description,
          'unit_number': unitNumber,
          'file_url': publicUrl,
          'storage_path': storagePath,
          'uploaded_by': user.id,
        })
        .select()
        .single();

    return AcademicContentModel.fromMap(inserted);
  }

  static Future<bool> isAdmin() async {
    final user = SupabaseService.client.auth.currentUser;
    if (user == null) return false;
    try {
      final row = await SupabaseService.client
          .from('students')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      return row != null && row['role'] == 'admin';
    } catch (_) {
      return false;
    }
  }

  static Future<void> deleteContent(AcademicContentModel content) async {
    if (content.storagePath != null) {
      try {
        await SupabaseService.client.storage
            .from(bucketName)
            .remove([content.storagePath!]);
      } catch (_) {}
    }
    await SupabaseService.client
        .from('academic_contents')
        .delete()
        .eq('id', content.id);
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }
}
