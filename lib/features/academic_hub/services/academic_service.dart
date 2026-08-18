import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/subject_model.dart';
import '../models/academic_content_model.dart';
import '../../../core/services/supabase_service.dart';

class AcademicService {
  static const String bucketName = 'academic-files';
  static const String _backendUrl = 'https://myvault-f08x.onrender.com';

  /// Fetches subjects prioritizing Supabase Database & CMS Contents
  static Future<List<SubjectModel>> getSubjects({
    required String branch,
    required int semester,
    String subjectType = 'academic',
  }) async {
    List<SubjectModel> subjects = [];

    // 1. Fetch directly from Supabase Database
    try {
      final response = await SupabaseService.client
          .from('subjects')
          .select()
          .or('branch.ilike.%$branch%,branch.ieq.general')
          .eq('semester', semester)
          .eq('subject_type', subjectType)
          .order('name');
      subjects = (response as List)
          .map((e) => SubjectModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Supabase getSubjects error: $e');
    }

    // 2. Include Supabase CMS website uploads (academic_contents)
    try {
      final cmsRes = await SupabaseService.client
          .from('academic_contents')
          .select()
          .order('created_at', ascending: false);

      final cmsList = (cmsRes as List).map((e) {
        final title = (e['title'] as String? ?? e['subject_name'] as String? ?? 'Custom Study Material').trim();
        final contentId = e['subject_id']?.toString() ?? e['id']?.toString() ?? 'content_${DateTime.now().millisecondsSinceEpoch}';
        return SubjectModel(
          id: contentId,
          name: title,
          code: (e['content_type'] as String? ?? 'NOTES').toUpperCase(),
          branch: branch,
          semester: semester,
          subjectType: subjectType,
        );
      }).toList();

      if (cmsList.isNotEmpty) {
        final existingNames = subjects.map((s) => s.name.toLowerCase()).toSet();
        for (final cmsSub in cmsList) {
          if (!existingNames.contains(cmsSub.name.toLowerCase())) {
            subjects.insert(0, cmsSub);
            existingNames.add(cmsSub.name.toLowerCase());
          }
        }
      }
    } catch (e) {
      debugPrint('Supabase academic_contents CMS merge error: $e');
    }

    // 3. Fallback to NestJS Backend (AWS RDS Database) if Supabase is empty
    if (subjects.isEmpty) {
      try {
        final uri = Uri.parse('$_backendUrl/api/academic/subjects?branch=${Uri.encodeComponent(branch)}&semester=$semester&type=$subjectType');
        final res = await http.get(uri).timeout(const Duration(seconds: 2));
        if (res.statusCode == 200) {
          final list = jsonDecode(res.body) as List;
          subjects = list.map((e) => SubjectModel.fromMap(e as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        debugPrint('NestJS getSubjects error: $e');
      }
    }

    // 4. Return default mock subject list if both databases are empty
    if (subjects.isEmpty) {
      subjects = _getFallbackSubjects(branch: branch, semester: semester, subjectType: subjectType);
    }

    return subjects;
  }

  /// Fetches contents for a subject prioritizing Supabase Storage & DB
  static Future<List<AcademicContentModel>> getContentsBySubject({
    required String subjectId,
    String contentType = 'all',
  }) async {
    // 1. Fetch from Supabase Database
    try {
      final response = await SupabaseService.client
          .from('academic_contents')
          .select()
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((e) => AcademicContentModel.fromMap(e as Map<String, dynamic>))
          .toList();

      if (list.isNotEmpty) {
        final filtered = list.where((c) => c.subjectId == subjectId || c.id == subjectId).toList();
        if (filtered.isNotEmpty) return filtered;
        return list;
      }
    } catch (e) {
      debugPrint('Supabase getContentsBySubject error: $e');
    }

    // 2. Fallback to NestJS Backend (AWS S3 & RDS)
    try {
      final uri = Uri.parse('$_backendUrl/api/academic/subjects/$subjectId/contents?type=$contentType');
      final res = await http.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        return list.map((e) => AcademicContentModel.fromMap(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('NestJS getContentsBySubject error: $e');
    }

    return [];
  }

  /// Uploads file directly to Supabase Storage & Database
  static Future<AcademicContentModel> uploadAcademicFile({
    required File file,
    required String subjectId,
    required String title,
    required String contentType,
    String? description,
    int? unitNumber,
  }) async {
    // 1. Primary: Upload to Supabase Storage Bucket ('academic-files')
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last.split('\\').last}';
      final pathStr = 'study-materials/$fileName';

      await SupabaseService.client.storage.from(bucketName).upload(
        pathStr,
        file,
      );

      final fileUrl = SupabaseService.client.storage.from(bucketName).getPublicUrl(pathStr);

      final dbRecord = {
        'subject_id': subjectId,
        'title': title,
        'content_type': contentType.toUpperCase(),
        'unit_number': unitNumber ?? 1,
        'file_url': fileUrl,
        'storage_path': pathStr,
        'description': description ?? '',
        'created_at': DateTime.now().toIso8601String(),
      };

      final inserted = await SupabaseService.client
          .from('academic_contents')
          .insert(dbRecord)
          .select()
          .single();

      return AcademicContentModel.fromMap(inserted);
    } catch (e) {
      debugPrint('Supabase upload error, attempting NestJS AWS S3: $e');
    }

    // 2. Fallback: Upload to AWS S3 via NestJS Backend
    final fileName = file.path.split('/').last.split('\\').last;
    final presignUri = Uri.parse('$_backendUrl/api/s3/presign-upload?fileName=${Uri.encodeComponent(fileName)}&contentType=${Uri.encodeComponent(_mimeType(fileName.split('.').last.toLowerCase()))}&folder=study-materials');
    final presignRes = await http.get(presignUri).timeout(const Duration(seconds: 10));

    if (presignRes.statusCode == 200) {
      final json = jsonDecode(presignRes.body);
      final String uploadUrl = json['uploadUrl'];
      final String fileUrl   = json['fileUrl'];

      final bytes = await file.readAsBytes();
      await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': _mimeType(fileName.split('.').last.toLowerCase())},
        body: bytes,
      );

      final dbRes = await http.post(
        Uri.parse('$_backendUrl/api/academic/contents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'subjectId': subjectId,
          'title': title,
          'contentType': contentType.toUpperCase(),
          'unitNumber': unitNumber ?? 1,
          'fileUrl': fileUrl,
          'description': description ?? '',
        }),
      );

      if (dbRes.statusCode == 201 || dbRes.statusCode == 200) {
        return AcademicContentModel.fromMap(jsonDecode(dbRes.body));
      }
    }

    throw Exception('Failed to upload file to both Supabase and AWS S3.');
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'pdf':  return 'application/pdf';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      case 'png':  return 'image/png';
      case 'mp4':  return 'video/mp4';
      case 'zip':  return 'application/zip';
      default:     return 'application/octet-stream';
    }
  }

  static List<SubjectModel> _getFallbackSubjects({
    required String branch,
    required int semester,
    required String subjectType,
  }) {
    if (branch.toUpperCase() == 'ECE') {
      if (semester == 1) {
        return [
          SubjectModel(id: 'ece_101', name: 'Linear Algebra & Calculus', code: 'MA101BS', branch: 'ECE', semester: 1),
          SubjectModel(id: 'ece_102', name: 'Applied Physics', code: 'AP102BS', branch: 'ECE', semester: 1),
          SubjectModel(id: 'ece_103', name: 'C Programming for Engineers', code: 'CS103ES', branch: 'ECE', semester: 1),
          SubjectModel(id: 'ece_104', name: 'Basic Electrical Engineering', code: 'EE104ES', branch: 'ECE', semester: 1),
          SubjectModel(id: 'ece_105', name: 'Engineering Graphics', code: 'ME105ES', branch: 'ECE', semester: 1),
        ];
      }
      if (semester == 2) {
        return [
          SubjectModel(id: 'ece_201', name: 'Differential Equations & Vector Calculus', code: 'MA201BS', branch: 'ECE', semester: 2),
          SubjectModel(id: 'ece_202', name: 'Engineering Chemistry', code: 'CH202BS', branch: 'ECE', semester: 2),
          SubjectModel(id: 'ece_203', name: 'Electronic Devices & Circuits', code: 'EC203PC', branch: 'ECE', semester: 2),
          SubjectModel(id: 'ece_204', name: 'Digital Electronics', code: 'EC204PC', branch: 'ECE', semester: 2),
          SubjectModel(id: 'ece_205', name: 'English for Communication', code: 'HS205HS', branch: 'ECE', semester: 2),
        ];
      }
    }
    return [
      SubjectModel(id: '${branch.toLowerCase()}_${semester}01', name: '$branch Core Subject 1', code: '${branch}101', branch: branch, semester: semester),
      SubjectModel(id: '${branch.toLowerCase()}_${semester}02', name: '$branch Core Subject 2', code: '${branch}102', branch: branch, semester: semester),
      SubjectModel(id: '${branch.toLowerCase()}_${semester}03', name: '$branch Lab & Practicals', code: '${branch}103', branch: branch, semester: semester),
    ];
  }
}
