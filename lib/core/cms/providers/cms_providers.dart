import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/study_material.dart';
import '../models/job_listing.dart';
import '../models/notice.dart';
import '../repositories/cms_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final cmsRepositoryProvider = Provider<CmsRepository>((ref) {
  return CmsRepository(ref.watch(supabaseClientProvider));
});

class StudyMaterialFilter {
  final String? branch;
  final String? year;
  final String? semester;
  final String? sectionTab;
  final String? examCategory;
  final String? contentType;

  const StudyMaterialFilter({
    this.branch,
    this.year,
    this.semester,
    this.sectionTab,
    this.examCategory,
    this.contentType,
  });

  @override
  bool operator ==(Object other) =>
      other is StudyMaterialFilter &&
      other.branch == branch &&
      other.year == year &&
      other.semester == semester &&
      other.sectionTab == sectionTab &&
      other.examCategory == examCategory &&
      other.contentType == contentType;

  @override
  int get hashCode => Object.hash(branch, year, semester, sectionTab, examCategory, contentType);
}

final studyMaterialsProvider =
    FutureProvider.family<List<StudyMaterial>, StudyMaterialFilter>((ref, filter) {
  return ref.watch(cmsRepositoryProvider).getStudyMaterials(
        branch: filter.branch,
        year: filter.year,
        semester: filter.semester,
        sectionTab: filter.sectionTab,
        examCategory: filter.examCategory,
        contentType: filter.contentType,
      );
});

class JobListingFilter {
  final String? category;
  final String? sector;

  const JobListingFilter({this.category, this.sector});

  @override
  bool operator ==(Object other) =>
      other is JobListingFilter && other.category == category && other.sector == sector;

  @override
  int get hashCode => Object.hash(category, sector);
}

final jobListingsProvider =
    FutureProvider.family<List<JobListing>, JobListingFilter>((ref, filter) {
  return ref.watch(cmsRepositoryProvider).getJobListings(
        category: filter.category,
        sector: filter.sector,
      );
});

final noticesProvider = FutureProvider<List<Notice>>((ref) {
  return ref.watch(cmsRepositoryProvider).getNotices();
});
