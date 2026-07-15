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
    try {
      final response = await SupabaseService.client
          .from('subjects')
          .select()
          .eq('branch', branch)
          .eq('semester', semester)
          .eq('subject_type', subjectType)
          .order('name');
      return (response as List)
          .map((e) => SubjectModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Supabase getSubjects error: $e');
      rethrow;
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

