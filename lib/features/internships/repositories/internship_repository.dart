// ============================================================
// repositories/internship_repository.dart
// ============================================================
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/internship_models.dart';

class InternshipRepository {
  final SupabaseClient _client = Supabase.instance.client;

  // ─── Courses ──────────────────────────────────────────────
  Future<List<InternshipCourse>> fetchCourses({String? category}) async {
    var query = _client
        .from('internship_courses')
        .select(
            '*, sections:course_sections(*, videos:course_videos(*), assignments:course_assignments(*))')
        .eq('is_approved', true);

    if (category != null && category != 'All') {
      query = query.eq('category', category);
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((j) => InternshipCourse.fromJson(j)).toList();
  }

  Future<InternshipCourse> fetchCourseDetail(String courseId) async {
    final data = await _client
        .from('internship_courses')
        .select(
            '*, sections:course_sections(*, videos:course_videos(*), assignments:course_assignments(*))')
        .eq('id', courseId)
        .single();
    return InternshipCourse.fromJson(data);
  }

  // ─── Enrollment & Progress ────────────────────────────────
  Future<StudentCourseProgress> enrollInCourse(String courseId) async {
    final studentId = _client.auth.currentUser!.id;
    final existing = await _client
        .from('student_course_progress')
        .select()
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .maybeSingle();

    if (existing != null) return StudentCourseProgress.fromJson(existing);

    final inserted = await _client
        .from('student_course_progress')
        .insert({
          'student_id': studentId,
          'course_id': courseId,
          'status': 'in_progress',
        })
        .select()
        .single();
    return StudentCourseProgress.fromJson(inserted);
  }

  Future<StudentCourseProgress?> fetchProgress(String courseId) async {
    final studentId = _client.auth.currentUser!.id;
    final data = await _client
        .from('student_course_progress')
        .select()
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .maybeSingle();
    return data != null ? StudentCourseProgress.fromJson(data) : null;
  }

  Future<List<StudentCourseProgress>> fetchMyEnrolledCourses() async {
    final studentId = _client.auth.currentUser!.id;
    final data = await _client
        .from('student_course_progress')
        .select()
        .eq('student_id', studentId)
        .order('enrolled_at', ascending: false);
    return (data as List).map((j) => StudentCourseProgress.fromJson(j)).toList();
  }

  Future<void> markVideoCompleted({
    required String courseId,
    required String videoId,
    required int totalVideos,
    required int totalAssignments,
  }) async {
    final studentId = _client.auth.currentUser!.id;
    final current = await fetchProgress(courseId) ?? await enrollInCourse(courseId);

    final updatedVideos = {...current.completedVideoIds, videoId};
    final newStatus =
        (updatedVideos.length >= totalVideos && current.submittedAssignmentIds.length >= totalAssignments)
            ? 'completed'
            : 'in_progress';

    await _client.from('student_course_progress').update({
      'completed_video_ids': updatedVideos.toList(),
      'status': newStatus,
    }).match({'student_id': studentId, 'course_id': courseId});
  }

  // ─── Assignments ──────────────────────────────────────────
  Future<void> submitAssignment({
    required String courseId,
    required String assignmentId,
    required String submissionText,
    required List<String> attachmentUrls,
    required int totalVideos,
    required int totalAssignments,
  }) async {
    final studentId = _client.auth.currentUser!.id;

    await _client.from('assignment_submissions').insert({
      'student_id': studentId,
      'assignment_id': assignmentId,
      'course_id': courseId,
      'submission_text': submissionText,
      'attachment_urls': attachmentUrls,
    });

    final current = await fetchProgress(courseId) ?? await enrollInCourse(courseId);
    final updatedAssignments = {...current.submittedAssignmentIds, assignmentId};
    final newStatus =
        (current.completedVideoIds.length >= totalVideos && updatedAssignments.length >= totalAssignments)
            ? 'completed'
            : current.status.name;

    await _client.from('student_course_progress').update({
      'submitted_assignment_ids': updatedAssignments.toList(),
      'status': newStatus,
    }).match({'student_id': studentId, 'course_id': courseId});
  }

  Future<AssignmentSubmission?> fetchMySubmission(String assignmentId) async {
    final studentId = _client.auth.currentUser!.id;
    final data = await _client
        .from('assignment_submissions')
        .select()
        .eq('student_id', studentId)
        .eq('assignment_id', assignmentId)
        .maybeSingle();
    return data != null ? AssignmentSubmission.fromJson(data) : null;
  }

  // ─── Test / Certification ─────────────────────────────────
  Future<List<CourseTestQuestion>> fetchTestQuestions(String courseId) async {
    final data = await _client.rpc('get_course_test', params: {'p_course_id': courseId});
    return (data as List)
        .map((j) => CourseTestQuestion(
              id: j['id'],
              courseId: courseId,
              question: j['question'],
              options: List<String>.from(j['options']),
              correctOptionIndex: -1,
              marks: j['marks'] ?? 1,
            ))
        .toList();
  }

  Future<Map<String, dynamic>> submitTest({
    required String courseId,
    required List<Map<String, dynamic>> answers,
  }) async {
    final result = await _client.rpc('submit_course_test', params: {
      'p_course_id': courseId,
      'p_answers': answers,
    });
    return Map<String, dynamic>.from(result);
  }

  Future<CourseCertificate?> fetchCertificate(String courseId) async {
    final studentId = _client.auth.currentUser!.id;
    final data = await _client
        .from('course_certificates')
        .select()
        .eq('student_id', studentId)
        .eq('course_id', courseId)
        .maybeSingle();
    return data != null ? CourseCertificate.fromJson(data) : null;
  }

  Future<List<CourseCertificate>> fetchMyCertificates() async {
    final studentId = _client.auth.currentUser!.id;
    final data = await _client
        .from('course_certificates')
        .select()
        .eq('student_id', studentId)
        .order('issued_at', ascending: false);
    return (data as List).map((j) => CourseCertificate.fromJson(j)).toList();
  }

  // ─── Opportunities ────────────────────────────────────────
  Future<List<InternshipOpportunity>> fetchOpportunities({
    OpportunityType? type,
  }) async {
    var query = _client
        .from('internship_opportunities')
        .select()
        .eq('is_approved', true)
        .gte('deadline', DateTime.now().toIso8601String());

    if (type != null) {
      query = query.eq('type', type.name);
    }

    final data = await query.order('posted_at', ascending: false);
    return (data as List).map((j) => InternshipOpportunity.fromJson(j)).toList();
  }
}
