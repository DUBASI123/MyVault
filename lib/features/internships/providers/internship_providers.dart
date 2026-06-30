// ============================================================
// providers/internship_providers.dart
// ============================================================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/internship_models.dart';
import '../repositories/internship_repository.dart';

final internshipRepositoryProvider =
    Provider<InternshipRepository>((ref) => InternshipRepository());

final coursesProvider = FutureProvider.family<List<InternshipCourse>, String?>(
  (ref, category) async {
    final repo = ref.watch(internshipRepositoryProvider);
    return repo.fetchCourses(category: category);
  },
);

final courseDetailProvider =
    FutureProvider.family<InternshipCourse, String>((ref, courseId) async {
  final repo = ref.watch(internshipRepositoryProvider);
  return repo.fetchCourseDetail(courseId);
});

final courseProgressProvider =
    FutureProvider.family<StudentCourseProgress?, String>((ref, courseId) async {
  final repo = ref.watch(internshipRepositoryProvider);
  return repo.fetchProgress(courseId);
});

final myEnrolledCoursesProvider =
    FutureProvider<List<StudentCourseProgress>>((ref) async {
  final repo = ref.watch(internshipRepositoryProvider);
  return repo.fetchMyEnrolledCourses();
});

final myCertificatesProvider =
    FutureProvider<List<CourseCertificate>>((ref) async {
  final repo = ref.watch(internshipRepositoryProvider);
  return repo.fetchMyCertificates();
});

final opportunitiesProvider =
    FutureProvider.family<List<InternshipOpportunity>, OpportunityType?>(
  (ref, type) async {
    final repo = ref.watch(internshipRepositoryProvider);
    return repo.fetchOpportunities(type: type);
  },
);

final testQuestionsProvider =
    FutureProvider.family<List<CourseTestQuestion>, String>((ref, courseId) async {
  final repo = ref.watch(internshipRepositoryProvider);
  return repo.fetchTestQuestions(courseId);
});

// Notifier for side effects (mark video, submit assignment, submit test)
class CourseProgressNotifier extends StateNotifier<AsyncValue<void>> {
  CourseProgressNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> markVideoWatched({
    required String courseId,
    required String videoId,
    required int totalVideos,
    required int totalAssignments,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(internshipRepositoryProvider);
      await repo.markVideoCompleted(
        courseId: courseId,
        videoId: videoId,
        totalVideos: totalVideos,
        totalAssignments: totalAssignments,
      );
      ref.invalidate(courseProgressProvider(courseId));
      ref.invalidate(myEnrolledCoursesProvider);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> submitAssignment({
    required String courseId,
    required String assignmentId,
    required String submissionText,
    required List<String> attachmentUrls,
    required int totalVideos,
    required int totalAssignments,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(internshipRepositoryProvider);
      await repo.submitAssignment(
        courseId: courseId,
        assignmentId: assignmentId,
        submissionText: submissionText,
        attachmentUrls: attachmentUrls,
        totalVideos: totalVideos,
        totalAssignments: totalAssignments,
      );
      ref.invalidate(courseProgressProvider(courseId));
      ref.invalidate(myEnrolledCoursesProvider);
      state = const AsyncValue.data(null);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<Map<String, dynamic>?> submitTest({
    required String courseId,
    required List<Map<String, dynamic>> answers,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(internshipRepositoryProvider);
      final result = await repo.submitTest(courseId: courseId, answers: answers);
      ref.invalidate(courseProgressProvider(courseId));
      ref.invalidate(myEnrolledCoursesProvider);
      ref.invalidate(myCertificatesProvider);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, s) {
      state = AsyncValue.error(e, s);
      return null;
    }
  }
}

final courseProgressNotifierProvider =
    StateNotifierProvider<CourseProgressNotifier, AsyncValue<void>>(
  (ref) => CourseProgressNotifier(ref),
);
