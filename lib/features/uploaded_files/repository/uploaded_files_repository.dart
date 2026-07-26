import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

class UploadedFilesRepository {
  final supabase = SupabaseService.client;

  /// Fetches files visible to the current student: General CMS uploads,
  /// CMS uploads matching their branch/semester, and their own personal uploads.
  Future<List<Map<String, dynamic>>> getFiles() async {
    try {
      final response = await supabase
          .from('files')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  /// Optional explicit client-side filter for branch/semester.
  Future<List<Map<String, dynamic>>> getFilesFiltered({
    String? branch,
    String? semester,
  }) async {
    try {
      var query = supabase.from('files').select('*');
      if (branch != null) {
        query = query.or('branch.eq.$branch,branch.eq.General');
      }
      if (semester != null) {
        query = query.or('semester.eq.$semester,semester.is.null');
      }
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
