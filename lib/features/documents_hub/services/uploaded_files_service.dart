import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/uploaded_file_model.dart';

class UploadedFilesService {
  static const String bucketName = 'website-uploads';
  static final SupabaseClient _client = Supabase.instance.client;

  /// Allowed extensions: PDF, Images (JPG, JPEG, PNG), DOC/DOCX, XLS/XLSX
  static const List<String> allowedExtensions = [
    'pdf',
    'jpg',
    'jpeg',
    'png',
    'doc',
    'docx',
    'xls',
    'xlsx'
  ];

  static const int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB

  /// Fetch all files from files table
  static Future<List<UploadedFileModel>> fetchUploadedFiles() async {
    final response = await _client
        .from('files')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => UploadedFileModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Upload file to bucket 'website-uploads' and insert record into 'files' table
  static Future<UploadedFileModel> uploadFile({
    required File file,
    required String title,
    void Function(double progress)? onProgress,
  }) async {
    final extension = file.path.split('.').last.toLowerCase();

    // 1. Validation
    if (!allowedExtensions.contains(extension)) {
      throw Exception(
          'Unsupported file format (.$extension). Allowed: PDF, JPG, PNG, DOC/DOCX, XLS/XLSX.');
    }

    final fileSize = await file.length();
    if (fileSize > maxFileSizeBytes) {
      throw Exception(
          'File size is ${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB — exceeds the 50MB limit.');
    }

    if (onProgress != null) onProgress(0.1);

    // 2. Storage path & upload
    final cleanName = file.path.split(Platform.pathSeparator).last.replaceAll(RegExp(r'[^a-zA-Z0-9.-]'), '_');
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Please login first");

    final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$cleanName';
    final storagePath = fileName;

    await _client.storage.from(bucketName).upload(
          storagePath,
          file,
          fileOptions: FileOptions(
            contentType: _mimeType(extension),
            upsert: true,
          ),
        );

    if (onProgress != null) onProgress(0.7);

    // 3. Get Public URL
    final publicUrl = _client.storage.from(bucketName).getPublicUrl(storagePath);

    // 4. Save metadata to database
    final inserted = await _client
        .from('files')
        .insert({
          'user_id': user.id,
          'file_name': cleanName,
          'file_url': publicUrl,
        })
        .select()
        .single();

    if (onProgress != null) onProgress(1.0);

    return UploadedFileModel.fromMap(inserted);
  }

  /// Delete file from bucket 'website-uploads' and record from 'files' table
  static Future<void> deleteFile(UploadedFileModel item) async {
    // 1. Remove from Storage
    if (item.storagePath.isNotEmpty) {
      try {
        final user = _client.auth.currentUser;
        if (user != null) {
          final fullPath = item.storagePath.contains('/') ? item.storagePath : '${user.id}/${item.storagePath}';
          await _client.storage.from(bucketName).remove([fullPath]);
        }
      } catch (e) {
        debugPrint('Storage deletion warning: $e');
      }
    }

    // 2. Remove record from database
    await _client.from('files').delete().eq('id', item.id);
  }

  static String _mimeType(String ext) {
    switch (ext) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      default:
        return 'application/octet-stream';
    }
  }
}
