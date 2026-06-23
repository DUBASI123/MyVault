import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../config/env.dart';

class CloudinaryService {
  static final Dio _dio = Dio();
  static final _picker = ImagePicker();

  /// Upload any [file] to Cloudinary. Returns the secure URL or null on failure.
  static Future<String?> uploadFile(File file) async {
    try {
      const uploadUrl =
          'https://api.cloudinary.com/v1_1/${Env.cloudinaryCloudName}/upload';

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'upload_preset': Env.cloudinaryUploadPreset,
      });

      final response = await _dio.post(uploadUrl, data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['secure_url'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Pick a photo from the gallery and upload it as the student's profile picture.
  /// Saves the URL to the `students` table in Supabase. Returns the new URL or null.
  static Future<String?> uploadProfileImage(String studentId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked == null) return null;

    final url = await uploadFile(File(picked.path));
    if (url == null) return null;

    // Persist to Supabase
    await Supabase.instance.client
        .from('students')
        .update({'profile_pic_url': url}).eq('id', studentId);

    return url;
  }
}
