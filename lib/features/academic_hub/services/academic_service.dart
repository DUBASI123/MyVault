import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/env_config.dart';
import '../../../core/services/api_client.dart';
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
  }) async {
    if (EnvConfig.isBackendConfigured) {
      final list = await ApiClient.getList('/academic/subjects', query: {
        'branch': branch,
        'semester': semester,
      });
      return list
          .map((e) => SubjectModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    if (SupabaseService.isAvailable) {
      final response = await SupabaseService.client
          .from('subjects')
          .select()
          .eq('branch', branch)
          .eq('semester', semester)
          .order('name');
      return (response as List)
          .map((e) => SubjectModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Academic data requires backend or Supabase. Set API_BASE_URL.');
  }

  static Future<List<AcademicContentModel>> getContentsBySubject({
    required String subjectId,
    String contentType = 'all',
  }) async {
    if (EnvConfig.isBackendConfigured) {
      final list = await ApiClient.getList('/academic/contents/$subjectId', query: {
        if (contentType != 'all') 'contentType': contentType,
      });
      return list
          .map((e) => AcademicContentModel.fromMap(e as Map<String, dynamic>))
          .toList();
    }

    if (SupabaseService.isAvailable) {
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
    }

    throw Exception('Academic content requires backend or Supabase.');
  }

  static Future<AcademicContentModel> uploadAcademicFile({
    required File file,
    required String subjectId,
    required String title,
    required String contentType,
    String? description,
    int? unitNumber,
  }) async {
    if (SupabaseService.isAvailable) {
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

    if (EnvConfig.isBackendConfigured) {
      final extension = file.path.split('.').last.toLowerCase();
      final inserted = await ApiClient.post('/academic/contents', data: {
        'subjectId': subjectId,
        'title': title,
        'contentType': contentType,
        'description': description,
        'unitNumber': unitNumber,
        'fileUrl': file.path,
        'storagePath': '$subjectId/$contentType/${DateTime.now().millisecondsSinceEpoch}.$extension',
      });
      return AcademicContentModel.fromMap(inserted);
    }

    throw Exception('Upload requires backend or Supabase.');
  }

  static Future<bool> isAdmin() async {
    if (SupabaseService.isAvailable) {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return false;
      final row = await SupabaseService.client
          .from('students')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();
      return row != null && row['role'] == 'admin';
    }
    return false;
  }

  static Future<void> deleteContent(AcademicContentModel content) async {
    if (SupabaseService.isAvailable) {
      if (content.storagePath != null) {
        await SupabaseService.client.storage
            .from(bucketName)
            .remove([content.storagePath!]);
      }
      await SupabaseService.client
          .from('academic_contents')
          .delete()
          .eq('id', content.id);
    }
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
