import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_material.dart';
import '../models/job_listing.dart';
import '../models/notice.dart';

class CmsRepository {
  final SupabaseClient _client;

  CmsRepository(this._client);

  Future<List<StudyMaterial>> getStudyMaterials({
    String? branch,
    String? year,
    String? semester,
    String? sectionTab,
    String? examCategory,
    String? contentType,
  }) async {
    try {
      var query = _client.from('cms_study_materials').select().eq('active', true);

      if (branch != null && branch.isNotEmpty) {
        query = query.eq('branch', branch);
      }
      if (year != null && year.isNotEmpty) {
        query = query.eq('year', year);
      }
      if (semester != null && semester.isNotEmpty) {
        query = query.eq('semester', semester);
      }
      if (sectionTab != null && sectionTab.isNotEmpty) {
        query = query.eq('section_tab', sectionTab);
      }
      if (examCategory != null && examCategory.isNotEmpty) {
        query = query.eq('exam_category', examCategory);
      }
      if (contentType != null && contentType.isNotEmpty) {
        query = query.eq('content_type', contentType);
      }

      final data = await query.order('created_at', ascending: false);
      return (data as List).map((row) => StudyMaterial.fromMap(row)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<JobListing>> getJobListings({
    String? category,
    String? sector,
    bool excludeExpired = true,
  }) async {
    try {
      var query = _client.from('cms_job_listings').select().eq('active', true);

      if (category != null) {
        query = query.eq('category', category);
      }
      if (sector != null) {
        query = query.eq('sector', sector);
      }

      final data = await query.order('created_at', ascending: false);
      var listings = (data as List).map((row) => JobListing.fromMap(row)).toList();

      if (excludeExpired) {
        listings = listings.where((j) => !j.isExpired).toList();
      }
      return listings;
    } catch (_) {
      return [];
    }
  }

  Future<List<Notice>> getNotices({int limit = 20}) async {
    try {
      final data = await _client
          .from('cms_notices')
          .select()
          .eq('active', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List).map((row) => Notice.fromMap(row)).toList();
    } catch (_) {
      return [];
    }
  }
}
