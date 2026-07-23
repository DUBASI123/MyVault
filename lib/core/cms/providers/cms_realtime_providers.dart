import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/study_material.dart';
import '../models/job_listing.dart';
import '../models/notice.dart';
import 'cms_providers.dart';

/// Realtime providers — instantly update the mobile app whenever new files,
/// subjects, notes, or notices are uploaded via the CMS website!
final studyMaterialsStreamProvider =
    StreamProvider.family<List<StudyMaterial>, StudyMaterialFilter>((ref, filter) {
  final client = ref.watch(supabaseClientProvider);

  final stream = client.from('cms_study_materials').stream(primaryKey: ['id']);

  return stream.order('created_at', ascending: false).map((rows) {
    var materials = rows
        .where((row) => row['active'] == true || row['active'] == null)
        .map((row) => StudyMaterial.fromMap(row))
        .toList();

    if (filter.branch != null && filter.branch!.isNotEmpty) {
      materials = materials.where((m) => m.branch.toUpperCase() == filter.branch!.toUpperCase()).toList();
    }
    if (filter.year != null && filter.year!.isNotEmpty) {
      materials = materials.where((m) => m.year.toUpperCase() == filter.year!.toUpperCase()).toList();
    }
    if (filter.semester != null && filter.semester!.isNotEmpty) {
      materials = materials.where((m) => m.semester.toUpperCase() == filter.semester!.toUpperCase()).toList();
    }
    if (filter.sectionTab != null && filter.sectionTab!.isNotEmpty) {
      materials = materials.where((m) => m.sectionTab.toLowerCase() == filter.sectionTab!.toLowerCase()).toList();
    }

    return materials;
  });
});

final jobListingsStreamProvider =
    StreamProvider.family<List<JobListing>, JobListingFilter>((ref, filter) {
  final client = ref.watch(supabaseClientProvider);

  final stream = client.from('cms_job_listings').stream(primaryKey: ['id']);

  return stream.order('created_at', ascending: false).map((rows) {
    var jobs = rows.where((row) => row['active'] == true).map((row) => JobListing.fromMap(row)).toList();
    if (filter.category != null) {
      jobs = jobs.where((j) => j.category == filter.category).toList();
    }
    if (filter.sector != null) {
      jobs = jobs.where((j) => j.sector == filter.sector).toList();
    }
    return jobs.where((j) => !j.isExpired).toList();
  });
});

final noticesStreamProvider = StreamProvider<List<Notice>>((ref) {
  final client = ref.watch(supabaseClientProvider);

  return client
      .from('cms_notices')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((rows) => rows
          .where((row) => row['active'] == true)
          .map((row) => Notice.fromMap(row))
          .toList());
});
