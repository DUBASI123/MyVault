// ============================================================
// internships_placements_module.dart
// MyVault — Complete Internships + Placements Module
// Single file: Models → Repository → Providers → All Screens
//
// pubspec.yaml deps to add:
//   video_player: ^2.9.1
//   pdf: ^3.11.1
//   printing: ^5.13.1
//   qr_flutter: ^4.1.0
//   file_picker: ^8.0.7
//   cloudinary_flutter: ^1.3.0
//   cloudinary_url_gen: ^1.5.0
//   share_plus: ^9.0.0
//   url_launcher: ^6.3.0
//   intl: ^0.19.0
//   path_provider: ^2.1.4
// ============================================================

library internships_placements_module;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


// ─────────────────────────────────────────────────────────────
// SECTION 1 — CONSTANTS & THEME
// ─────────────────────────────────────────────────────────────

const _bg    = Color(0xFF0A0A0F);
const _surf  = Color(0xFF1A1A2E);
const _surf2 = Color(0xFF26263F);
const _pri   = Color(0xFF6C63FF);
const _green = Color(0xFF4CAF50);
const _amber = Color(0xFFFFA726);
const _red   = Color(0xFFFF5252);
const _gold  = Color(0xFFFFD700);

// ─────────────────────────────────────────────────────────────
// SECTION 2 — MODELS
// ─────────────────────────────────────────────────────────────

enum CourseStatus   { notStarted, inProgress, completed, certified }
enum DifficultyLevel{ beginner, intermediate, advanced }
enum OpportunityType{ internship, job, freelance }
enum JobType        { internship, fullTime, partTime, freelance, contract }
enum WorkMode       { onsite, remote, hybrid }
enum ExperienceLevel{ fresher, junior, mid, senior, lead }

// ── InternshipCourse ─────────────────────────────────────────
class InternshipCourse {
  final String id, title, subtitle, description, thumbnailUrl, category;
  final DifficultyLevel difficulty;
  final int durationMinutes, totalVideos, totalAssignments;
  final String instructorName, instructorAvatar;
  final double rating;
  final int enrolledCount;
  final List<CourseSection> sections;
  final List<String> skillsYouLearn;
  final bool isApproved;
  final DateTime createdAt;

  const InternshipCourse({
    required this.id, required this.title, required this.subtitle,
    required this.description, required this.thumbnailUrl, required this.category,
    required this.difficulty, required this.durationMinutes,
    required this.totalVideos, required this.totalAssignments,
    required this.instructorName, required this.instructorAvatar,
    required this.rating, required this.enrolledCount,
    required this.sections, required this.skillsYouLearn,
    required this.isApproved, required this.createdAt,
  });

  factory InternshipCourse.fromJson(Map<String, dynamic> j) => InternshipCourse(
    id: j['id'], title: j['title'], subtitle: j['subtitle'] ?? '',
    description: j['description'] ?? '', thumbnailUrl: j['thumbnail_url'] ?? '',
    category: j['category'] ?? '',
    difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == j['difficulty'], orElse: () => DifficultyLevel.beginner),
    durationMinutes: j['duration_minutes'] ?? 0,
    totalVideos: j['total_videos'] ?? 0, totalAssignments: j['total_assignments'] ?? 0,
    instructorName: j['instructor_name'] ?? '', instructorAvatar: j['instructor_avatar'] ?? '',
    rating: (j['rating'] ?? 0).toDouble(), enrolledCount: j['enrolled_count'] ?? 0,
    sections: (j['sections'] as List? ?? []).map((s) => CourseSection.fromJson(s)).toList(),
    skillsYouLearn: List<String>.from(j['skills_you_learn'] ?? []),
    isApproved: j['is_approved'] ?? false,
    createdAt: DateTime.parse(j['created_at']),
  );
}

// ── CourseSection ─────────────────────────────────────────────
class CourseSection {
  final String id, courseId, title;
  final int orderIndex;
  final List<CourseVideo> videos;
  final List<CourseAssignment> assignments;

  const CourseSection({
    required this.id, required this.courseId, required this.title,
    required this.orderIndex, required this.videos, required this.assignments,
  });

  factory CourseSection.fromJson(Map<String, dynamic> j) => CourseSection(
    id: j['id'], courseId: j['course_id'] ?? '', title: j['title'],
    orderIndex: j['order_index'] ?? 0,
    videos: (j['videos'] as List? ?? []).map((v) => CourseVideo.fromJson(v)).toList(),
    assignments: (j['assignments'] as List? ?? []).map((a) => CourseAssignment.fromJson(a)).toList(),
  );
}

// ── CourseVideo ───────────────────────────────────────────────
class CourseVideo {
  final String id, sectionId, title, description, videoUrl;
  final String? thumbnailUrl;
  final int durationSeconds, orderIndex;
  final bool isPreview;
  final List<String> resources;

  const CourseVideo({
    required this.id, required this.sectionId, required this.title,
    required this.description, required this.videoUrl, this.thumbnailUrl,
    required this.durationSeconds, required this.orderIndex,
    required this.isPreview, required this.resources,
  });

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  factory CourseVideo.fromJson(Map<String, dynamic> j) => CourseVideo(
    id: j['id'], sectionId: j['section_id'] ?? '', title: j['title'],
    description: j['description'] ?? '', videoUrl: j['video_url'],
    thumbnailUrl: j['thumbnail_url'],
    durationSeconds: j['duration_seconds'] ?? 0, orderIndex: j['order_index'] ?? 0,
    isPreview: j['is_preview'] ?? false,
    resources: List<String>.from(j['resources'] ?? []),
  );
}

// ── CourseAssignment ──────────────────────────────────────────
class CourseAssignment {
  final String id, sectionId, courseId, title, description, instructions;
  final int maxScore, orderIndex;
  final DateTime? dueDate;
  final List<String> attachmentUrls;

  const CourseAssignment({
    required this.id, required this.sectionId, required this.courseId,
    required this.title, required this.description, required this.instructions,
    required this.maxScore, required this.orderIndex,
    this.dueDate, required this.attachmentUrls,
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> j) => CourseAssignment(
    id: j['id'], sectionId: j['section_id'] ?? '', courseId: j['course_id'] ?? '',
    title: j['title'], description: j['description'] ?? '',
    instructions: j['instructions'] ?? '', maxScore: j['max_score'] ?? 100,
    orderIndex: j['order_index'] ?? 0,
    dueDate: j['due_date'] != null ? DateTime.parse(j['due_date']) : null,
    attachmentUrls: List<String>.from(j['attachment_urls'] ?? []),
  );
}

// ── CourseTestQuestion ────────────────────────────────────────
class CourseTestQuestion {
  final String id, courseId, question;
  final List<String> options;
  final int correctOptionIndex, marks;
  final String? explanation;

  const CourseTestQuestion({
    required this.id, required this.courseId, required this.question,
    required this.options, required this.correctOptionIndex, required this.marks,
    this.explanation,
  });

  factory CourseTestQuestion.fromJson(Map<String, dynamic> j) => CourseTestQuestion(
    id: j['id'], courseId: j['course_id'] ?? '', question: j['question'],
    options: List<String>.from(j['options']),
    correctOptionIndex: j['correct_option_index'] ?? -1,
    marks: j['marks'] ?? 1, explanation: j['explanation'],
  );
}

// ── StudentCourseProgress ─────────────────────────────────────
class StudentCourseProgress {
  final String id, studentId, courseId;
  final Set<String> completedVideoIds, submittedAssignmentIds;
  final CourseStatus status;
  final int? testScore, testMaxScore;
  final bool testPassed;
  final String? certificateId;
  final DateTime enrolledAt;
  final DateTime? completedAt, certifiedAt;

  const StudentCourseProgress({
    required this.id, required this.studentId, required this.courseId,
    required this.completedVideoIds, required this.submittedAssignmentIds,
    required this.status, this.testScore, this.testMaxScore,
    required this.testPassed, this.certificateId,
    required this.enrolledAt, this.completedAt, this.certifiedAt,
  });

  factory StudentCourseProgress.fromJson(Map<String, dynamic> j) =>
      StudentCourseProgress(
    id: j['id'], studentId: j['student_id'], courseId: j['course_id'],
    completedVideoIds: Set<String>.from(j['completed_video_ids'] ?? []),
    submittedAssignmentIds: Set<String>.from(j['submitted_assignment_ids'] ?? []),
    status: CourseStatus.values.firstWhere((e) => e.name == j['status'],
        orElse: () => CourseStatus.notStarted),
    testScore: j['test_score'], testMaxScore: j['test_max_score'],
    testPassed: j['test_passed'] ?? false, certificateId: j['certificate_id'],
    enrolledAt: DateTime.parse(j['enrolled_at']),
    completedAt: j['completed_at'] != null ? DateTime.parse(j['completed_at']) : null,
    certifiedAt: j['certified_at'] != null ? DateTime.parse(j['certified_at']) : null,
  );
}

// ── CourseCertificate ─────────────────────────────────────────
class CourseCertificate {
  final String id, studentId, studentName, hallTicketNo, courseId, courseTitle;
  final String? collegeId;
  final int testScore, testMaxScore;
  final DateTime issuedAt;
  final String verificationCode;
  final String? pdfUrl;

  const CourseCertificate({
    required this.id, required this.studentId, required this.studentName,
    required this.hallTicketNo, required this.courseId, required this.courseTitle,
    this.collegeId, required this.testScore, required this.testMaxScore,
    required this.issuedAt, required this.verificationCode, this.pdfUrl,
  });

  double get scorePercentage => (testScore / testMaxScore) * 100;

  String get grade {
    final p = scorePercentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B+';
    if (p >= 60) return 'B';
    return 'C';
  }

  factory CourseCertificate.fromJson(Map<String, dynamic> j) => CourseCertificate(
    id: j['id'], studentId: j['student_id'], studentName: j['student_name'],
    hallTicketNo: j['hall_ticket_no'], courseId: j['course_id'],
    courseTitle: j['course_title'], collegeId: j['college_id'],
    testScore: j['test_score'], testMaxScore: j['test_max_score'],
    issuedAt: DateTime.parse(j['issued_at']),
    verificationCode: j['verification_code'], pdfUrl: j['pdf_url'],
  );
}

// ── AssignmentSubmission ──────────────────────────────────────
class AssignmentSubmission {
  final String id, studentId, assignmentId, courseId, submissionText;
  final List<String> attachmentUrls;
  final int? score;
  final String? feedback;
  final bool isGraded;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const AssignmentSubmission({
    required this.id, required this.studentId, required this.assignmentId,
    required this.courseId, required this.submissionText,
    required this.attachmentUrls, this.score, this.feedback,
    required this.isGraded, required this.submittedAt, this.gradedAt,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> j) => AssignmentSubmission(
    id: j['id'], studentId: j['student_id'], assignmentId: j['assignment_id'],
    courseId: j['course_id'], submissionText: j['submission_text'] ?? '',
    attachmentUrls: List<String>.from(j['attachment_urls'] ?? []),
    score: j['score'], feedback: j['feedback'], isGraded: j['is_graded'] ?? false,
    submittedAt: DateTime.parse(j['submitted_at']),
    gradedAt: j['graded_at'] != null ? DateTime.parse(j['graded_at']) : null,
  );
}

// ── InternshipOpportunity ─────────────────────────────────────
class InternshipOpportunity {
  final String id, companyName, companyLogoUrl, role, description;
  final OpportunityType type;
  final String location, duration, stipend, applyUrl;
  final bool isRemote, isApproved;
  final List<String> requiredSkills;
  final DateTime postedAt, deadline;

  const InternshipOpportunity({
    required this.id, required this.companyName, required this.companyLogoUrl,
    required this.role, required this.description, required this.type,
    required this.location, required this.duration, required this.stipend,
    required this.applyUrl, required this.isRemote, required this.isApproved,
    required this.requiredSkills, required this.postedAt, required this.deadline,
  });

  bool get isExpired => deadline.isBefore(DateTime.now());

  factory InternshipOpportunity.fromJson(Map<String, dynamic> j) =>
      InternshipOpportunity(
    id: j['id'], companyName: j['company_name'],
    companyLogoUrl: j['company_logo_url'] ?? '', role: j['role'],
    description: j['description'] ?? '',
    type: OpportunityType.values.firstWhere(
        (e) => e.name == j['type'], orElse: () => OpportunityType.internship),
    location: j['location'] ?? '', duration: j['duration'] ?? '',
    stipend: j['stipend'] ?? 'Unpaid', applyUrl: j['apply_url'],
    isRemote: j['is_remote'] ?? false, isApproved: j['is_approved'] ?? false,
    requiredSkills: List<String>.from(j['required_skills'] ?? []),
    postedAt: DateTime.parse(j['posted_at']),
    deadline: DateTime.parse(j['deadline']),
  );
}

// ── PlacementJob ──────────────────────────────────────────────
class PlacementJob {
  final String id, companyName, companyLogoUrl, role, description;
  final JobType jobType;
  final WorkMode workMode;
  final ExperienceLevel experienceLevel;
  final String location;
  final String? salaryRange, qualification, experience, shift, contactInfo, postedBy, department;
  final List<String> skills, tags;
  final String applyUrl;
  final DateTime postedAt;
  final DateTime? deadline;
  final bool isUrgent, isFeatured;

  const PlacementJob({
    required this.id, required this.companyName, required this.companyLogoUrl,
    required this.role, required this.description, required this.jobType,
    required this.workMode, required this.experienceLevel, required this.location,
    this.salaryRange, this.qualification, this.experience, this.shift,
    this.contactInfo, this.postedBy, this.department,
    required this.skills, required this.tags, required this.applyUrl,
    required this.postedAt, this.deadline,
    required this.isUrgent, required this.isFeatured,
  });

  factory PlacementJob.fromJson(Map<String, dynamic> j) => PlacementJob(
    id: j['id'], companyName: j['company_name'],
    companyLogoUrl: j['company_logo_url'] ?? '', role: j['role'],
    description: j['description'] ?? '',
    jobType: JobType.values.firstWhere(
        (e) => e.name == j['job_type'], orElse: () => JobType.fullTime),
    workMode: WorkMode.values.firstWhere(
        (e) => e.name == j['work_mode'], orElse: () => WorkMode.onsite),
    experienceLevel: ExperienceLevel.values.firstWhere(
        (e) => e.name == j['experience_level'], orElse: () => ExperienceLevel.fresher),
    location: j['location'] ?? '', salaryRange: j['salary_range'],
    qualification: j['qualification'], experience: j['experience'],
    shift: j['shift'], contactInfo: j['contact_info'], postedBy: j['posted_by'],
    department: j['department'],
    skills: List<String>.from(j['skills'] ?? []),
    tags: List<String>.from(j['tags'] ?? []),
    applyUrl: j['apply_url'] ?? '',
    postedAt: DateTime.parse(j['posted_at']),
    deadline: j['deadline'] != null ? DateTime.parse(j['deadline']) : null,
    isUrgent: j['is_urgent'] ?? false, isFeatured: j['is_featured'] ?? false,
  );
}

// ─────────────────────────────────────────────────────────────
// SECTION 3 — REPOSITORY
// ─────────────────────────────────────────────────────────────

class InternshipRepository {
  final _db = Supabase.instance.client;
  String get _uid => _db.auth.currentUser!.id;

  // ── Courses ──────────────────────────────────────────────
  Future<List<InternshipCourse>> fetchCourses({String? category}) async {
    var q = _db.from('internship_courses')
        .select('*, sections:course_sections(*, videos:course_videos(*), assignments:course_assignments(*))')
        .eq('is_approved', true);
    if (category != null) q = q.eq('category', category);
    final data = await q.order('created_at', ascending: false);
    return (data as List).map((j) => InternshipCourse.fromJson(j)).toList();
  }

  Future<InternshipCourse> fetchCourseDetail(String id) async {
    final data = await _db.from('internship_courses')
        .select('*, sections:course_sections(*, videos:course_videos(*), assignments:course_assignments(*))')
        .eq('id', id).single();
    return InternshipCourse.fromJson(data);
  }

  // ── Progress ──────────────────────────────────────────────
  Future<StudentCourseProgress> enrollInCourse(String courseId) async {
    final existing = await _db.from('student_course_progress').select()
        .eq('student_id', _uid).eq('course_id', courseId).maybeSingle();
    if (existing != null) return StudentCourseProgress.fromJson(existing);
    final inserted = await _db.from('student_course_progress')
        .insert({'student_id': _uid, 'course_id': courseId, 'status': 'in_progress'})
        .select().single();
    return StudentCourseProgress.fromJson(inserted);
  }

  Future<StudentCourseProgress?> fetchProgress(String courseId) async {
    final data = await _db.from('student_course_progress').select()
        .eq('student_id', _uid).eq('course_id', courseId).maybeSingle();
    return data != null ? StudentCourseProgress.fromJson(data) : null;
  }

  Future<List<StudentCourseProgress>> fetchMyEnrolled() async {
    final data = await _db.from('student_course_progress').select()
        .eq('student_id', _uid).order('enrolled_at', ascending: false);
    return (data as List).map((j) => StudentCourseProgress.fromJson(j)).toList();
  }

  Future<void> markVideoCompleted({
    required String courseId, required String videoId,
    required int totalVideos, required int totalAssignments,
  }) async {
    final cur = await fetchProgress(courseId) ?? await enrollInCourse(courseId);
    final vids = {...cur.completedVideoIds, videoId};
    final status = (vids.length >= totalVideos &&
            cur.submittedAssignmentIds.length >= totalAssignments)
        ? 'completed'
        : 'in_progress';
    await _db.from('student_course_progress').update(
        {'completed_video_ids': vids.toList(), 'status': status})
        .match({'student_id': _uid, 'course_id': courseId});
  }

  // ── Assignments ───────────────────────────────────────────
  Future<void> submitAssignment({
    required String courseId, required String assignmentId,
    required String text, required List<String> attachments,
    required int totalVideos, required int totalAssignments,
  }) async {
    await _db.from('assignment_submissions').insert({
      'student_id': _uid, 'assignment_id': assignmentId,
      'course_id': courseId, 'submission_text': text, 'attachment_urls': attachments,
    });
    final cur = await fetchProgress(courseId) ?? await enrollInCourse(courseId);
    final asgns = {...cur.submittedAssignmentIds, assignmentId};
    final status = (cur.completedVideoIds.length >= totalVideos &&
            asgns.length >= totalAssignments)
        ? 'completed'
        : 'in_progress';
    await _db.from('student_course_progress').update(
        {'submitted_assignment_ids': asgns.toList(), 'status': status})
        .match({'student_id': _uid, 'course_id': courseId});
  }

  Future<AssignmentSubmission?> fetchMySubmission(String assignmentId) async {
    final data = await _db.from('assignment_submissions').select()
        .eq('student_id', _uid).eq('assignment_id', assignmentId).maybeSingle();
    return data != null ? AssignmentSubmission.fromJson(data) : null;
  }

  // ── Test / Certificate ────────────────────────────────────
  Future<List<CourseTestQuestion>> fetchTestQuestions(String courseId) async {
    final data = await _db.rpc('get_course_test', params: {'p_course_id': courseId});
    return (data as List).map((j) => CourseTestQuestion(
      id: j['id'], courseId: courseId, question: j['question'],
      options: List<String>.from(j['options']),
      correctOptionIndex: -1, marks: j['marks'] ?? 1,
    )).toList();
  }

  Future<Map<String, dynamic>> submitTest({
    required String courseId, required List<Map<String, dynamic>> answers,
  }) async {
    final result = await _db.rpc('submit_course_test',
        params: {'p_course_id': courseId, 'p_answers': answers});
    return Map<String, dynamic>.from(result);
  }

  Future<CourseCertificate?> fetchCertificate(String courseId) async {
    final data = await _db.from('course_certificates').select()
        .eq('student_id', _uid).eq('course_id', courseId).maybeSingle();
    return data != null ? CourseCertificate.fromJson(data) : null;
  }

  Future<List<CourseCertificate>> fetchMyCertificates() async {
    final data = await _db.from('course_certificates').select()
        .eq('student_id', _uid).order('issued_at', ascending: false);
    return (data as List).map((j) => CourseCertificate.fromJson(j)).toList();
  }

  // ── Opportunities ─────────────────────────────────────────
  Future<List<InternshipOpportunity>> fetchOpportunities() async {
    final data = await _db.from('internship_opportunities').select()
        .eq('is_approved', true)
        .gte('deadline', DateTime.now().toIso8601String())
        .order('posted_at', ascending: false);
    return (data as List).map((j) => InternshipOpportunity.fromJson(j)).toList();
  }

  // ── Placements ────────────────────────────────────────────
  Future<List<PlacementJob>> fetchJobs({
    String? jobType, String? workMode, String? level, String? search,
  }) async {
    var q = _db.from('placement_jobs').select().eq('is_approved', true);
    if (jobType != null) q = q.eq('job_type', jobType);
    if (workMode != null) q = q.eq('work_mode', workMode);
    if (level != null) q = q.eq('experience_level', level);
    if (search != null && search.isNotEmpty) q = q.ilike('role', '%$search%');
    final data = await q
        .order('is_featured', ascending: false)
        .order('is_urgent', ascending: false)
        .order('posted_at', ascending: false);
    return (data as List).map((j) => PlacementJob.fromJson(j)).toList();
  }

  Future<Set<String>> fetchSavedJobIds() async {
    final data = await _db.from('student_saved_jobs').select('job_id')
        .eq('student_id', _uid);
    return (data as List).map<String>((j) => j['job_id'] as String).toSet();
  }

  Future<void> toggleSaveJob(String jobId, bool currentlySaved) async {
    if (currentlySaved) {
      await _db.from('student_saved_jobs').delete()
          .match({'student_id': _uid, 'job_id': jobId});
    } else {
      await _db.from('student_saved_jobs')
          .insert({'student_id': _uid, 'job_id': jobId});
    }
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 4 — PROVIDERS
// ─────────────────────────────────────────────────────────────

final _repo = Provider<InternshipRepository>((ref) => InternshipRepository());

final coursesProvider = FutureProvider.family<List<InternshipCourse>, String?>(
  (ref, cat) => ref.watch(_repo).fetchCourses(category: cat == 'All' ? null : cat),
);

final courseDetailProvider = FutureProvider.family<InternshipCourse, String>(
  (ref, id) => ref.watch(_repo).fetchCourseDetail(id),
);

final progressProvider = FutureProvider.family<StudentCourseProgress?, String>(
  (ref, courseId) => ref.watch(_repo).fetchProgress(courseId),
);

final enrolledProvider = FutureProvider<List<StudentCourseProgress>>(
  (ref) => ref.watch(_repo).fetchMyEnrolled(),
);

final certificatesProvider = FutureProvider<List<CourseCertificate>>(
  (ref) => ref.watch(_repo).fetchMyCertificates(),
);

final opportunitiesProvider = FutureProvider<List<InternshipOpportunity>>(
  (ref) => ref.watch(_repo).fetchOpportunities(),
);

final testQuestionsProvider = FutureProvider.family<List<CourseTestQuestion>, String>(
  (ref, courseId) => ref.watch(_repo).fetchTestQuestions(courseId),
);

final jobFiltersProvider = StateProvider<Map<String, String?>>(
  (ref) => {'type': null, 'mode': null, 'level': null, 'search': null},
);

final jobsProvider = FutureProvider<List<PlacementJob>>((ref) {
  final f = ref.watch(jobFiltersProvider);
  return ref.watch(_repo).fetchJobs(
    jobType: f['type'], workMode: f['mode'],
    level: f['level'], search: f['search'],
  );
});

final savedJobIdsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(_repo).fetchSavedJobIds(),
);

// Course progress actions notifier
class ProgressNotifier extends StateNotifier<AsyncValue<void>> {
  ProgressNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> markVideo({
    required String courseId, required String videoId,
    required int totalVideos, required int totalAssignments,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(_repo).markVideoCompleted(
        courseId: courseId, videoId: videoId,
        totalVideos: totalVideos, totalAssignments: totalAssignments,
      );
      ref.invalidate(progressProvider(courseId));
      ref.invalidate(enrolledProvider);
      state = const AsyncValue.data(null);
    } catch (e, s) { state = AsyncValue.error(e, s); }
  }

  Future<void> submitAssignment({
    required String courseId, required String assignmentId,
    required String text, required List<String> attachments,
    required int totalVideos, required int totalAssignments,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(_repo).submitAssignment(
        courseId: courseId, assignmentId: assignmentId,
        text: text, attachments: attachments,
        totalVideos: totalVideos, totalAssignments: totalAssignments,
      );
      ref.invalidate(progressProvider(courseId));
      ref.invalidate(enrolledProvider);
      state = const AsyncValue.data(null);
    } catch (e, s) { state = AsyncValue.error(e, s); }
  }

  Future<Map<String, dynamic>?> submitTest({
    required String courseId, required List<Map<String, dynamic>> answers,
  }) async {
    state = const AsyncValue.loading();
    try {
      final r = await ref.read(_repo).submitTest(courseId: courseId, answers: answers);
      ref.invalidate(progressProvider(courseId));
      ref.invalidate(enrolledProvider);
      ref.invalidate(certificatesProvider);
      state = const AsyncValue.data(null);
      return r;
    } catch (e, s) { state = AsyncValue.error(e, s); return null; }
  }
}

final progressNotifierProvider =
    StateNotifierProvider<ProgressNotifier, AsyncValue<void>>(
        (ref) => ProgressNotifier(ref));

// ─────────────────────────────────────────────────────────────
// SECTION 5 — SHARED WIDGETS
// ─────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String text;
  final Color? color;
  const _Tag({required this.text, this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: (color ?? _pri).withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text[0].toUpperCase() + text.substring(1),
      style: TextStyle(color: color ?? _pri, fontSize: 10, fontWeight: FontWeight.w600),
    ),
  );
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _MiniChip({required this.icon, required this.text, this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.white12),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: color ?? Colors.white38),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(color: color ?? Colors.white60, fontSize: 10)),
    ]),
  );
}

class _CompanyAvatar extends StatelessWidget {
  final String name, url;
  final double radius;
  const _CompanyAvatar({required this.name, required this.url, this.radius = 24});
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: _surf2,
    backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
    child: url.isEmpty
        ? Text(name[0].toUpperCase(),
            style: const TextStyle(color: _pri, fontWeight: FontWeight.bold, fontSize: 18))
        : null,
  );
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _StatBox({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: _surf, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(children: [
      Icon(icon, color: _pri, size: 20),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────
// SECTION 6 — INTERNSHIPS HUB SCREEN
// ─────────────────────────────────────────────────────────────

class InternshipsHubScreen extends ConsumerStatefulWidget {
  const InternshipsHubScreen({super.key});
  @override
  ConsumerState<InternshipsHubScreen> createState() => _InternshipsHubState();
}

class _InternshipsHubState extends ConsumerState<InternshipsHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _cat = 'All';
  static const _cats = ['All','Web Development','Data Science','UI/UX Design','Mobile Development'];

  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    appBar: AppBar(
      backgroundColor: _bg, elevation: 0,
      title: const Text('Internships', style: TextStyle(fontWeight: FontWeight.bold)),
      bottom: TabBar(
        controller: _tab,
        indicatorColor: _pri, labelColor: _pri, unselectedLabelColor: Colors.white60,
        tabs: const [Tab(text: 'Learn'), Tab(text: 'Opportunities'), Tab(text: 'Certificates')],
      ),
    ),
    body: TabBarView(controller: _tab, children: [
      _buildLearnTab(),
      _buildOppsTab(),
      _CertificatesTab(),
    ]),
  );

  Widget _buildLearnTab() {
    final async = ref.watch(coursesProvider(_cat));
    return Column(children: [
      SizedBox(height: 44,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemCount: _cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = _cats[i]; final sel = c == _cat;
            return ChoiceChip(
              label: Text(c), selected: sel,
              onSelected: (_) => setState(() => _cat = c),
              selectedColor: _pri, backgroundColor: _surf,
              labelStyle: TextStyle(
                  color: sel ? Colors.white : Colors.white70, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: sel ? _pri : Colors.white12)),
            );
          },
        ),
      ),
      Expanded(child: async.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white60))),
        data: (courses) => RefreshIndicator(
          color: _pri,
          onRefresh: () async => ref.refresh(coursesProvider(_cat)),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (_, i) => _CourseCard(course: courses[i]),
          ),
        ),
      )),
    ]);
  }

  Widget _buildOppsTab() {
    final async = ref.watch(opportunitiesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
      error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white60))),
      data: (opps) => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: opps.length,
        itemBuilder: (_, i) => _OppCard(opp: opps[i]),
      ),
    );
  }
}

// ─── Course Card ──────────────────────────────────────────────
class _CourseCard extends ConsumerWidget {
  final InternshipCourse course;
  const _CourseCard({required this.course});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prog = ref.watch(progressProvider(course.id));
    return Card(
      color: _surf, margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: course.id))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(aspectRatio: 16/9,
            child: Container(color: _surf2,
              child: course.thumbnailUrl.isNotEmpty
                  ? Image.network(course.thumbnailUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.school_outlined, color: Colors.white24, size: 48))
                  : const Icon(Icons.school_outlined, color: Colors.white24, size: 48))),
          Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_Tag(text: course.category), const SizedBox(width: 6), _Tag(text: course.difficulty.name)]),
            const SizedBox(height: 8),
            Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(course.subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.play_circle_outline, size: 15, color: Colors.white38),
              const SizedBox(width: 4),
              Text('${course.totalVideos} videos', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(width: 14),
              const Icon(Icons.assignment_outlined, size: 15, color: Colors.white38),
              const SizedBox(width: 4),
              Text('${course.totalAssignments} assignments', style: const TextStyle(color: Colors.white38, fontSize: 12)),
              const Spacer(),
              const Icon(Icons.star, size: 15, color: Color(0xFFFFC107)),
              const SizedBox(width: 2),
              Text(course.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            prog.maybeWhen(data: (p) {
              if (p == null) return const SizedBox.shrink();
              final pct = course.totalVideos == 0 ? 0.0 : p.completedVideoIds.length / course.totalVideos;
              return Padding(padding: const EdgeInsets.only(top: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: pct.clamp(0,1), minHeight: 6, backgroundColor: Colors.white12,
                    color: p.status == CourseStatus.certified ? _green : _pri)),
                const SizedBox(height: 4),
                Text(p.status == CourseStatus.certified ? 'Certified ✓' : '${(pct*100).round()}% complete',
                  style: TextStyle(color: p.status == CourseStatus.certified ? _green : Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
              ]));
            }, orElse: () => const SizedBox.shrink()),
          ])),
        ]),
      ),
    );
  }
}

// ─── Opportunity Card ─────────────────────────────────────────
class _OppCard extends StatelessWidget {
  final InternshipOpportunity opp;
  const _OppCard({required this.opp});
  @override
  Widget build(BuildContext context) {
    final days = opp.deadline.difference(DateTime.now()).inDays;
    return Card(
      color: _surf, margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _CompanyAvatar(name: opp.companyName, url: opp.companyLogoUrl),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(opp.role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            Text(opp.companyName, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ])),
          if (days <= 7) Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _red.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Text('$days d left', style: const TextStyle(color: _red, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(opp.description, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _MiniChip(icon: Icons.location_on_outlined, text: opp.isRemote ? 'Remote' : opp.location),
          _MiniChip(icon: Icons.timelapse, text: opp.duration),
          _MiniChip(icon: Icons.payments_outlined, text: opp.stipend, color: _green),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final url = Uri.parse(opp.applyUrl);
              if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.inAppWebView);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _pri, padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
      ])),
    );
  }
}

// ─── Certificates Tab ─────────────────────────────────────────
class _CertificatesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(certificatesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
      error: (_, __) => const Center(child: Text('Error', style: TextStyle(color: Colors.white60))),
      data: (certs) {
        if (certs.isEmpty) return const Center(
          child: Padding(padding: EdgeInsets.all(24),
            child: Text('Complete a course to earn your first certificate here.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.white60))));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: certs.length,
          itemBuilder: (_, i) {
            final c = certs[i];
            return Card(
              color: _surf, margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => CertificateScreen(certificate: c))),
                leading: Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: _pri.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.workspace_premium, color: _pri)),
                title: Text(c.courseTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text('Grade ${c.grade} • ${c.scorePercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white60)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white38),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 7 — COURSE DETAIL SCREEN
// ─────────────────────────────────────────────────────────────

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseDetailProvider(courseId));
    final progAsync  = ref.watch(progressProvider(courseId));
    return Scaffold(
      backgroundColor: _bg,
      body: courseAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
        error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: Colors.white60))),
        data: (course) => progAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
          error: (_, __) => _buildBody(context, ref, course, null),
          data: (prog) => _buildBody(context, ref, course, prog),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, InternshipCourse course, StudentCourseProgress? prog) {
    final allVideos = prog != null && prog.completedVideoIds.length >= course.totalVideos && course.totalVideos > 0;
    final allAsgns  = prog != null && prog.submittedAssignmentIds.length >= course.totalAssignments;
    final readyTest = allVideos && allAsgns;
    final certified = prog?.status == CourseStatus.certified;

    return CustomScrollView(slivers: [
      SliverAppBar(
        backgroundColor: _bg, expandedHeight: 200, pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(fit: StackFit.expand, children: [
            course.thumbnailUrl.isNotEmpty
                ? Image.network(course.thumbnailUrl, fit: BoxFit.cover)
                : Container(color: _surf),
            Container(decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _bg]))),
          ]),
        ),
      ),
      SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(course.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(course.subtitle, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        const SizedBox(height: 14),
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: _surf2,
            backgroundImage: course.instructorAvatar.isNotEmpty ? NetworkImage(course.instructorAvatar) : null),
          const SizedBox(width: 8),
          Text(course.instructorName, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          const Icon(Icons.star, size: 16, color: Color(0xFFFFC107)),
          const SizedBox(width: 2),
          Text('${course.rating} (${course.enrolledCount})',
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ]),
        const SizedBox(height: 18),
        if (prog == null)
          SizedBox(width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(_repo).enrollInCourse(course.id);
                ref.invalidate(progressProvider(course.id));
              },
              style: ElevatedButton.styleFrom(backgroundColor: _pri,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Enroll for Free', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ))
        else
          _ProgressBanner(course: course, prog: prog, readyTest: readyTest, certified: certified),
        const SizedBox(height: 22),
        const Text("What you'll learn", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (course.skillsYouLearn.isEmpty)
          const Text("No skills listed.", style: TextStyle(color: Colors.white38, fontSize: 13))
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: course.skillsYouLearn.map((s) => _Tag(text: s, color: _pri)).toList(),
          ),
        const SizedBox(height: 24),
        const Text("Course Syllabus", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (course.sections.isEmpty)
          const Text("No sections available.", style: TextStyle(color: Colors.white54, fontSize: 13))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: course.sections.length,
            itemBuilder: (_, sIdx) {
              final section = course.sections[sIdx];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _surf,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: ExpansionTile(
                  key: PageStorageKey(section.id),
                  title: Text(section.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text("${section.videos.length} videos • ${section.assignments.length} assignments", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  iconColor: _pri,
                  collapsedIconColor: Colors.white54,
                  children: [
                    const Divider(color: Colors.white10, height: 1),
                    ...section.videos.map((vid) {
                      final completed = prog?.completedVideoIds.contains(vid.id) ?? false;
                      final accessible = prog != null || vid.isPreview;
                      return ListTile(
                        leading: Icon(
                          completed ? Icons.check_circle : Icons.play_circle_outline,
                          color: completed ? _green : (accessible ? _pri : Colors.white24),
                          size: 20,
                        ),
                        title: Text(vid.title, style: TextStyle(color: accessible ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text(vid.formattedDuration, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        trailing: accessible
                            ? const Icon(Icons.chevron_right, size: 16, color: Colors.white38)
                            : const Icon(Icons.lock_outline, size: 16, color: Colors.white24),
                        onTap: () {
                          if (accessible) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(
                              video: vid,
                              courseId: course.id,
                              totalVideos: course.totalVideos,
                              totalAssignments: course.totalAssignments,
                            )));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enroll in the course to unlock this video!")),
                            );
                          }
                        },
                      );
                    }),
                    ...section.assignments.map((asgn) {
                      final submitted = prog?.submittedAssignmentIds.contains(asgn.id) ?? false;
                      final accessible = prog != null;
                      return ListTile(
                        leading: Icon(
                          submitted ? Icons.task_alt : Icons.assignment_outlined,
                          color: submitted ? _green : (accessible ? _amber : Colors.white24),
                          size: 20,
                        ),
                        title: Text(asgn.title, style: TextStyle(color: accessible ? Colors.white : Colors.white38, fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text("Max score: ${asgn.maxScore}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        trailing: accessible
                            ? const Icon(Icons.chevron_right, size: 16, color: Colors.white38)
                            : const Icon(Icons.lock_outline, size: 16, color: Colors.white24),
                        onTap: () {
                          if (accessible) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AssignmentSubmissionScreen(
                              assignment: asgn,
                              courseId: course.id,
                              totalVideos: course.totalVideos,
                              totalAssignments: course.totalAssignments,
                            )));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Enroll in the course to unlock assignments!")),
                            );
                          }
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
      ]))),
    ]);
  }
}

// ─── Progress Banner Widget ──────────────────────────────────
class _ProgressBanner extends StatelessWidget {
  final InternshipCourse course;
  final StudentCourseProgress prog;
  final bool readyTest;
  final bool certified;

  const _ProgressBanner({
    required this.course,
    required this.prog,
    required this.readyTest,
    required this.certified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surf,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pri.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: _pri, size: 20),
              const SizedBox(width: 8),
              const Text("Your Progress", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const Spacer(),
              _Tag(
                text: prog.status.name,
                color: certified ? _green : (prog.status == CourseStatus.completed ? _amber : _pri),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Videos: ${prog.completedVideoIds.length}/${course.totalVideos}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("Assignments: ${prog.submittedAssignmentIds.length}/${course.totalAssignments}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          if (certified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final cert = await ProviderScope.containerOf(context).read(_repo).fetchCertificate(course.id);
                  if (cert != null && context.mounted) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CertificateScreen(certificate: cert)));
                  }
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text("View Certificate", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          else if (readyTest)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CourseTestScreen(courseId: course.id)));
                },
                icon: const Icon(Icons.assignment_turned_in),
                label: const Text("Take Certification Test", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _amber,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            )
          else
            const Text(
              "Complete all videos and assignments to unlock the final certification test.",
              style: TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 8 — VIDEO PLAYER SCREEN
// ─────────────────────────────────────────────────────────────

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final CourseVideo video;
  final String courseId;
  final int totalVideos;
  final int totalAssignments;

  const VideoPlayerScreen({
    super.key,
    required this.video,
    required this.courseId,
    required this.totalVideos,
    required this.totalAssignments,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _markedCompleted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeVideo() async {
    if (_markedCompleted) return;
    setState(() => _markedCompleted = true);
    await ref.read(progressNotifierProvider.notifier).markVideo(
      courseId: widget.courseId,
      videoId: widget.video.id,
      totalVideos: widget.totalVideos,
      totalAssignments: widget.totalAssignments,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video marked as completed!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Text(widget.video.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: _initialized
                    ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          _ControlsOverlay(controller: _controller),
                          VideoProgressIndicator(_controller, allowScrubbing: true),
                        ],
                      )
                    : const Center(child: CircularProgressIndicator(color: _pri)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.video.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.video.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _completeVideo,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Mark Video Completed", style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _markedCompleted ? _green : _pri,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({required this.controller});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 9 — ASSIGNMENT SUBMISSION SCREEN
// ─────────────────────────────────────────────────────────────

class AssignmentSubmissionScreen extends ConsumerStatefulWidget {
  final CourseAssignment assignment;
  final String courseId;
  final int totalVideos;
  final int totalAssignments;

  const AssignmentSubmissionScreen({
    super.key,
    required this.assignment,
    required this.courseId,
    required this.totalVideos,
    required this.totalAssignments,
  });

  @override
  ConsumerState<AssignmentSubmissionScreen> createState() => _AssignmentSubmissionScreenState();
}

class _AssignmentSubmissionScreenState extends ConsumerState<AssignmentSubmissionScreen> {
  final _textController = TextEditingController();
  final List<String> _attachments = [];
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachments.add(result.files.single.path!);
      });
    }
  }

  Future<void> _submit() async {
    if (_textController.text.trim().isEmpty && _attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write a text response or attach a file.")),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(progressNotifierProvider.notifier).submitAssignment(
        courseId: widget.courseId,
        assignmentId: widget.assignment.id,
        text: _textController.text.trim(),
        attachments: _attachments,
        totalVideos: widget.totalVideos,
        totalAssignments: widget.totalAssignments,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Assignment submitted successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subAsync = ref.watch(FutureProvider.autoDispose((ref) => ref.read(_repo).fetchMySubmission(widget.assignment.id)));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text("Assignment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
        error: (e, _) => Center(child: Text("$e", style: const TextStyle(color: Colors.white60))),
        data: (submission) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.assignment.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(widget.assignment.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
              const Divider(color: Colors.white10, height: 24),
              const Text("Instructions", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(widget.assignment.instructions, style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.4)),
              const SizedBox(height: 24),
              if (submission != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surf,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: submission.isGraded ? _green : _pri),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(submission.isGraded ? Icons.check_circle : Icons.hourglass_empty, color: submission.isGraded ? _green : _pri, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            submission.isGraded ? "Graded: ${submission.score}/${widget.assignment.maxScore}" : "Submitted & Awaiting Grading",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      if (submission.feedback != null) ...[
                        const SizedBox(height: 10),
                        Text("Feedback: ${submission.feedback}", style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                      const SizedBox(height: 10),
                      Text("Your submission: ${submission.submissionText}", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
              ] else ...[
                const Text("Your Submission", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Enter your solution text here...",
                    hintStyle: const TextStyle(color: Colors.white24),
                    fillColor: _surf,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Attachments", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._attachments.map((path) => Chip(
                          label: Text(path.split('/').last, style: const TextStyle(fontSize: 11)),
                          backgroundColor: _surf2,
                          labelStyle: const TextStyle(color: Colors.white),
                          deleteIconColor: _red,
                          onDeleted: () => setState(() => _attachments.remove(path)),
                        )),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 14, color: Colors.white),
                      label: const Text("Add File", style: TextStyle(fontSize: 11, color: Colors.white)),
                      backgroundColor: _pri,
                      onPressed: _pickAttachment,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pri,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _submitting
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Submit Assignment", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 10 — COURSE TEST SCREEN
// ─────────────────────────────────────────────────────────────

class CourseTestScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseTestScreen({super.key, required this.courseId});

  @override
  ConsumerState<CourseTestScreen> createState() => _CourseTestScreenState();
}



class _CourseTestScreenState extends ConsumerState<CourseTestScreen> {
  final Map<int, int> _answers = {};
  int _currentIdx = 0;
  bool _submitting = false;

  Future<void> _submitTest(List<CourseTestQuestion> questions) async {
    if (_answers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please answer all questions before submitting.")),
      );
      return;
    }

    setState(() => _submitting = true);
    final payload = _answers.entries.map((e) => {
          'question_id': questions[e.key].id,
          'selected_index': e.value,
        }).toList();

    final result = await ref.read(progressNotifierProvider.notifier).submitTest(
          courseId: widget.courseId,
          answers: payload,
        );

    if (mounted && result != null) {
      final passed = result['passed'] as bool? ?? false;
      final score = result['score'] as int? ?? 0;
      final maxScore = result['max_score'] as int? ?? 1;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: _surf,
          title: Text(passed ? "🎉 Congratulations!" : "❌ Test Failed"),
          content: Text(
            passed
                ? "You passed the test with a score of $score/$maxScore! Your certificate has been issued."
                : "You scored $score/$maxScore. You need at least 60% to pass. Try again!",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // dialog
                Navigator.pop(context); // test screen
              },
              child: const Text("OK", style: TextStyle(color: _pri)),
            )
          ],
        ),
      );
    } else {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to submit test. Try again.")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(testQuestionsProvider(widget.courseId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text("Final Test", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: questionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
        error: (e, _) => Center(child: Text("$e", style: const TextStyle(color: Colors.white60))),
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(child: Text("No test questions available for this course.", style: TextStyle(color: Colors.white54)));
          }

          final q = questions[_currentIdx];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (_currentIdx + 1) / questions.length,
                  backgroundColor: Colors.white10,
                  color: _pri,
                ),
                const SizedBox(height: 24),
                Text(
                  "Question ${_currentIdx + 1} of ${questions.length}",
                  style: const TextStyle(color: _pri, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Text(
                  q.question,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: q.options.length,
                    itemBuilder: (_, oIdx) {
                      final selected = _answers[_currentIdx] == oIdx;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: selected ? _pri.withOpacity(0.15) : _surf,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: selected ? _pri : Colors.white10),
                        ),
                        child: RadioListTile<int>(
                          value: oIdx,
                          groupValue: _answers[_currentIdx],
                          title: Text(q.options[oIdx], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          activeColor: _pri,
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _answers[_currentIdx] = val);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentIdx > 0)
                      TextButton(
                        onPressed: () => setState(() => _currentIdx--),
                        child: const Text("Previous", style: TextStyle(color: Colors.white70)),
                      )
                    else
                      const SizedBox.shrink(),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentIdx < questions.length - 1) {
                          setState(() => _currentIdx++);
                        } else {
                          _submitTest(questions);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pri,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _submitting
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(_currentIdx == questions.length - 1 ? "Submit Test" : "Next"),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 11 — CERTIFICATE SCREEN
// ─────────────────────────────────────────────────────────────

class CertificateScreen extends StatefulWidget {
  final CourseCertificate certificate;
  const CertificateScreen({super.key, required this.certificate});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  bool _generatingPdf = false;

  Future<void> _generatePdf() async {
    setState(() => _generatingPdf = true);
    try {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(32),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.amber, width: 8),
              ),
              child: pw.Center(
                child: pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Text("CERTIFICATE OF COMPLETION", style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                    pw.SizedBox(height: 20),
                    pw.Text("This is proudly presented to", style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 10),
                    pw.Text(widget.certificate.studentName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text("for successfully completing the course", style: const pw.TextStyle(fontSize: 16)),
                    pw.SizedBox(height: 10),
                    pw.Text(widget.certificate.courseTitle, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                    pw.SizedBox(height: 24),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text("Grade: ${widget.certificate.grade}", style: const pw.TextStyle(fontSize: 14)),
                            pw.Text("Issued: ${DateFormat('yyyy-MM-dd').format(widget.certificate.issuedAt)}", style: const pw.TextStyle(fontSize: 14)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text("Verification Code: ${widget.certificate.verificationCode}", style: const pw.TextStyle(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to generate PDF: $e")));
    } finally {
      setState(() => _generatingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text("Certificate", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _surf,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _gold.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(color: _gold.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.workspace_premium, color: _gold, size: 64),
                  const SizedBox(height: 16),
                  const Text("CERTIFICATE OF COMPLETION", style: TextStyle(color: _gold, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 24),
                  const Text("This is proudly presented to", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(widget.certificate.studentName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  if (widget.certificate.hallTicketNo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text("HT No: ${widget.certificate.hallTicketNo}", style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                  const SizedBox(height: 20),
                  const Text("for successfully completing the course", style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(
                    widget.certificate.courseTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _pri, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white10, height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("GRADE", style: TextStyle(color: Colors.white38, fontSize: 9)),
                          Text(widget.certificate.grade, style: const TextStyle(color: _green, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("SCORE", style: TextStyle(color: Colors.white38, fontSize: 9)),
                          Text("${widget.certificate.scorePercentage.toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("DATE OF ISSUE", style: TextStyle(color: Colors.white38, fontSize: 9)),
                          Text(DateFormat('yyyy-MM-dd').format(widget.certificate.issuedAt), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  QrImageView(
                    data: widget.certificate.verificationCode,
                    version: QrVersions.auto,
                    size: 90.0,
                    gapless: false,
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text("Verification Code: ${widget.certificate.verificationCode}", style: const TextStyle(color: Colors.white38, fontSize: 9, letterSpacing: 1.1)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generatingPdf ? null : _generatePdf,
                icon: const Icon(Icons.print),
                label: const Text("Print / Save PDF", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pri,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// SECTION 12 — PLACEMENTS TAB
// ─────────────────────────────────────────────────────────────

class PlacementsTab extends ConsumerStatefulWidget {
  const PlacementsTab({super.key});

  @override
  ConsumerState<PlacementsTab> createState() => _PlacementsTabState();
}

class _PlacementsTabState extends ConsumerState<PlacementsTab> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(String key, String? val) {
    final filters = ref.read(jobFiltersProvider);
    ref.read(jobFiltersProvider.notifier).state = {
      ...filters,
      key: val,
    };
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);
    final savedIdsAsync = ref.watch(savedJobIdsProvider);
    final filters = ref.watch(jobFiltersProvider);

    return Column(
      children: [
        // Search & Filter header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "Search placement roles...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  fillColor: _surf,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) => _updateFilter('search', val.trim().isEmpty ? null : val.trim()),
              ),
              const SizedBox(height: 12),
              // Quick Filter Chips
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                      label: "Onsite",
                      selected: filters['mode'] == 'onsite',
                      onSelected: (sel) => _updateFilter('mode', sel ? 'onsite' : null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Remote",
                      selected: filters['mode'] == 'remote',
                      onSelected: (sel) => _updateFilter('mode', sel ? 'remote' : null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Hybrid",
                      selected: filters['mode'] == 'hybrid',
                      onSelected: (sel) => _updateFilter('mode', sel ? 'hybrid' : null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Full Time",
                      selected: filters['type'] == 'fullTime',
                      onSelected: (sel) => _updateFilter('type', sel ? 'fullTime' : null),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Internship",
                      selected: filters['type'] == 'internship',
                      onSelected: (sel) => _updateFilter('type', sel ? 'internship' : null),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Jobs list
        Expanded(
          child: jobsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: _pri)),
            error: (e, _) => Center(child: Text("$e", style: const TextStyle(color: Colors.white60))),
            data: (jobs) {
              if (jobs.isEmpty) {
                return const Center(child: Text("No placement drives match your criteria.", style: TextStyle(color: Colors.white38)));
              }

              final savedIds = savedIdsAsync.value ?? {};

              return RefreshIndicator(
                color: _pri,
                onRefresh: () async {
                  ref.invalidate(jobsProvider);
                  ref.invalidate(savedJobIdsProvider);
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: jobs.length,
                  itemBuilder: (_, i) {
                    final job = jobs[i];
                    final isSaved = savedIds.contains(job.id);
                    return _JobCard(
                      job: job,
                      isSaved: isSaved,
                      onSaveToggle: () async {
                        await ref.read(_repo).toggleSaveJob(job.id, isSaved);
                        ref.invalidate(savedJobIdsProvider);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
      selected: selected,
      onSelected: onSelected,
      selectedColor: _pri,
      backgroundColor: _surf,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? _pri : Colors.white12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

class _JobCard extends StatelessWidget {
  final PlacementJob job;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _surf,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CompanyAvatar(name: job.companyName, url: job.companyLogoUrl),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.role, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(job.companyName, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border, color: isSaved ? _gold : Colors.white38),
                  onPressed: onSaveToggle,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (job.description != null && job.description!.isNotEmpty) ...[
              Text(job.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.3)),
              const SizedBox(height: 10),
            ],
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _MiniChip(icon: Icons.work_outline, text: job.jobType.name),
                _MiniChip(icon: Icons.location_on_outlined, text: job.workMode.name),
                _MiniChip(icon: Icons.school_outlined, text: job.experienceLevel.name),
                if (job.salaryRange != null) _MiniChip(icon: Icons.payments_outlined, text: job.salaryRange!, color: _green),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (job.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: _red.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: const Text("URGENT", style: TextStyle(color: _red, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    final url = Uri.parse(job.applyUrl);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.inAppWebView);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pri,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Apply", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
