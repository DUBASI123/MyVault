enum CourseStatus { notStarted, inProgress, completed, certified }

enum OpportunityType { internship, job, freelance }

enum DifficultyLevel { beginner, intermediate, advanced }

// ─── Internship Course ───────────────────────────────────────
class InternshipCourse {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String thumbnailUrl;
  final String category; // e.g. "Web Dev", "Data Science", "UI/UX"
  final DifficultyLevel difficulty;
  final int durationMinutes;
  final int totalVideos;
  final int totalAssignments;
  final String instructorName;
  final String instructorAvatar;
  final double rating;
  final int enrolledCount;
  final List<CourseSection> sections;
  final List<String> skillsYouLearn;
  final bool isApproved;
  final DateTime createdAt;

  const InternshipCourse({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.thumbnailUrl,
    required this.category,
    required this.difficulty,
    required this.durationMinutes,
    required this.totalVideos,
    required this.totalAssignments,
    required this.instructorName,
    required this.instructorAvatar,
    required this.rating,
    required this.enrolledCount,
    required this.sections,
    required this.skillsYouLearn,
    required this.isApproved,
    required this.createdAt,
  });

  factory InternshipCourse.fromJson(Map<String, dynamic> j) => InternshipCourse(
        id: j['id'],
        title: j['title'],
        subtitle: j['subtitle'] ?? '',
        description: j['description'] ?? '',
        thumbnailUrl: j['thumbnail_url'] ?? '',
        category: j['category'] ?? '',
        difficulty: DifficultyLevel.values.firstWhere(
          (e) => e.name == j['difficulty'],
          orElse: () => DifficultyLevel.beginner,
        ),
        durationMinutes: j['duration_minutes'] ?? 0,
        totalVideos: j['total_videos'] ?? 0,
        totalAssignments: j['total_assignments'] ?? 0,
        instructorName: j['instructor_name'] ?? '',
        instructorAvatar: j['instructor_avatar'] ?? '',
        rating: (j['rating'] ?? 0).toDouble(),
        enrolledCount: j['enrolled_count'] ?? 0,
        sections: (j['sections'] as List? ?? [])
            .map((s) => CourseSection.fromJson(s))
            .toList(),
        skillsYouLearn: List<String>.from(j['skills_you_learn'] ?? []),
        isApproved: j['is_approved'] ?? false,
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'thumbnail_url': thumbnailUrl,
        'category': category,
        'difficulty': difficulty.name,
        'duration_minutes': durationMinutes,
        'total_videos': totalVideos,
        'total_assignments': totalAssignments,
        'instructor_name': instructorName,
        'instructor_avatar': instructorAvatar,
        'rating': rating,
        'enrolled_count': enrolledCount,
        'sections': sections.map((s) => s.toJson()).toList(),
        'skills_you_learn': skillsYouLearn,
        'is_approved': isApproved,
        'created_at': createdAt.toIso8601String(),
      };
}

// ─── Course Section ──────────────────────────────────────────
class CourseSection {
  final String id;
  final String courseId;
  final String title;
  final int orderIndex;
  final List<CourseVideo> videos;
  final List<CourseAssignment> assignments;

  const CourseSection({
    required this.id,
    required this.courseId,
    required this.title,
    required this.orderIndex,
    required this.videos,
    required this.assignments,
  });

  factory CourseSection.fromJson(Map<String, dynamic> j) => CourseSection(
        id: j['id'],
        courseId: j['course_id'] ?? '',
        title: j['title'],
        orderIndex: j['order_index'] ?? 0,
        videos: (j['videos'] as List? ?? [])
            .map((v) => CourseVideo.fromJson(v))
            .toList(),
        assignments: (j['assignments'] as List? ?? [])
            .map((a) => CourseAssignment.fromJson(a))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'title': title,
        'order_index': orderIndex,
        'videos': videos.map((v) => v.toJson()).toList(),
        'assignments': assignments.map((a) => a.toJson()).toList(),
      };
}

// ─── Course Video ────────────────────────────────────────────
class CourseVideo {
  final String id;
  final String sectionId;
  final String title;
  final String description;
  final String videoUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final int orderIndex;
  final bool isPreview; // free preview without enrollment
  final List<String> resources; // downloadable resource URLs

  const CourseVideo({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.orderIndex,
    required this.isPreview,
    required this.resources,
  });

  String get formattedDuration {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }

  factory CourseVideo.fromJson(Map<String, dynamic> j) => CourseVideo(
        id: j['id'],
        sectionId: j['section_id'] ?? '',
        title: j['title'],
        description: j['description'] ?? '',
        videoUrl: j['video_url'],
        thumbnailUrl: j['thumbnail_url'],
        durationSeconds: j['duration_seconds'] ?? 0,
        orderIndex: j['order_index'] ?? 0,
        isPreview: j['is_preview'] ?? false,
        resources: List<String>.from(j['resources'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_id': sectionId,
        'title': title,
        'description': description,
        'video_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'duration_seconds': durationSeconds,
        'order_index': orderIndex,
        'is_preview': isPreview,
        'resources': resources,
      };
}

// ─── Course Assignment ────────────────────────────────────────
class CourseAssignment {
  final String id;
  final String sectionId;
  final String courseId;
  final String title;
  final String description;
  final String instructions;
  final int maxScore;
  final int orderIndex;
  final DateTime? dueDate;
  final List<String> attachmentUrls;

  const CourseAssignment({
    required this.id,
    required this.sectionId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.maxScore,
    required this.orderIndex,
    this.dueDate,
    required this.attachmentUrls,
  });

  factory CourseAssignment.fromJson(Map<String, dynamic> j) => CourseAssignment(
        id: j['id'],
        sectionId: j['section_id'] ?? '',
        courseId: j['course_id'] ?? '',
        title: j['title'],
        description: j['description'] ?? '',
        instructions: j['instructions'] ?? '',
        maxScore: j['max_score'] ?? 100,
        orderIndex: j['order_index'] ?? 0,
        dueDate: j['due_date'] != null ? DateTime.parse(j['due_date']) : null,
        attachmentUrls: List<String>.from(j['attachment_urls'] ?? []),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'section_id': sectionId,
        'course_id': courseId,
        'title': title,
        'description': description,
        'instructions': instructions,
        'max_score': maxScore,
        'order_index': orderIndex,
        'due_date': dueDate?.toIso8601String(),
        'attachment_urls': attachmentUrls,
      };
}

// ─── Course Test Question ─────────────────────────────────────
class CourseTestQuestion {
  final String id;
  final String courseId;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String? explanation;
  final int marks;

  const CourseTestQuestion({
    required this.id,
    required this.courseId,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    required this.marks,
  });

  factory CourseTestQuestion.fromJson(Map<String, dynamic> j) =>
      CourseTestQuestion(
        id: j['id'],
        courseId: j['course_id'],
        question: j['question'],
        options: List<String>.from(j['options']),
        correctOptionIndex: j['correct_option_index'],
        explanation: j['explanation'],
        marks: j['marks'] ?? 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'course_id': courseId,
        'question': question,
        'options': options,
        'correct_option_index': correctOptionIndex,
        'explanation': explanation,
        'marks': marks,
      };
}

// ─── Student Course Progress ──────────────────────────────────
class StudentCourseProgress {
  final String id;
  final String studentId;
  final String courseId;
  final Set<String> completedVideoIds;
  final Set<String> submittedAssignmentIds;
  final CourseStatus status;
  final int? testScore;
  final int? testMaxScore;
  final bool testPassed;
  final String? certificateId;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final DateTime? certifiedAt;

  const StudentCourseProgress({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.completedVideoIds,
    required this.submittedAssignmentIds,
    required this.status,
    this.testScore,
    this.testMaxScore,
    required this.testPassed,
    this.certificateId,
    required this.enrolledAt,
    this.completedAt,
    this.certifiedAt,
  });

  double get videoProgress =>
      completedVideoIds.isEmpty ? 0 : completedVideoIds.length.toDouble();

  factory StudentCourseProgress.fromJson(Map<String, dynamic> j) =>
      StudentCourseProgress(
        id: j['id'],
        studentId: j['student_id'],
        courseId: j['course_id'],
        completedVideoIds: Set<String>.from(j['completed_video_ids'] ?? []),
        submittedAssignmentIds:
            Set<String>.from(j['submitted_assignment_ids'] ?? []),
        status: CourseStatus.values.firstWhere(
          (e) => e.name == j['status'],
          orElse: () => CourseStatus.notStarted,
        ),
        testScore: j['test_score'],
        testMaxScore: j['test_max_score'],
        testPassed: j['test_passed'] ?? false,
        certificateId: j['certificate_id'],
        enrolledAt: DateTime.parse(j['enrolled_at']),
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'])
            : null,
        certifiedAt: j['certified_at'] != null
            ? DateTime.parse(j['certified_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'course_id': courseId,
        'completed_video_ids': completedVideoIds.toList(),
        'submitted_assignment_ids': submittedAssignmentIds.toList(),
        'status': status.name,
        'test_score': testScore,
        'test_max_score': testMaxScore,
        'test_passed': testPassed,
        'certificate_id': certificateId,
        'enrolled_at': enrolledAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'certified_at': certifiedAt?.toIso8601String(),
      };
}

// ─── Certificate ──────────────────────────────────────────────
class CourseCertificate {
  final String id;
  final String studentId;
  final String studentName;
  final String hallTicketNo;
  final String courseId;
  final String courseTitle;
  final String collegeId;
  final int testScore;
  final int testMaxScore;
  final DateTime issuedAt;
  final String verificationCode;
  final String? pdfUrl;

  const CourseCertificate({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.hallTicketNo,
    required this.courseId,
    required this.courseTitle,
    required this.collegeId,
    required this.testScore,
    required this.testMaxScore,
    required this.issuedAt,
    required this.verificationCode,
    this.pdfUrl,
  });

  double get scorePercentage => (testScore / testMaxScore) * 100;

  String get grade {
    final pct = scorePercentage;
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B+';
    if (pct >= 60) return 'B';
    return 'C';
  }

  factory CourseCertificate.fromJson(Map<String, dynamic> j) =>
      CourseCertificate(
        id: j['id'],
        studentId: j['student_id'],
        studentName: j['student_name'],
        hallTicketNo: j['hall_ticket_no'],
        courseId: j['course_id'],
        courseTitle: j['course_title'],
        collegeId: j['college_id'],
        testScore: j['test_score'],
        testMaxScore: j['test_max_score'],
        issuedAt: DateTime.parse(j['issued_at']),
        verificationCode: j['verification_code'],
        pdfUrl: j['pdf_url'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'student_name': studentName,
        'hall_ticket_no': hallTicketNo,
        'course_id': courseId,
        'course_title': courseTitle,
        'college_id': collegeId,
        'test_score': testScore,
        'test_max_score': testMaxScore,
        'issued_at': issuedAt.toIso8601String(),
        'verification_code': verificationCode,
        'pdf_url': pdfUrl,
      };
}

// ─── Internship Opportunity ───────────────────────────────────
class InternshipOpportunity {
  final String id;
  final String companyName;
  final String companyLogoUrl;
  final String role;
  final String description;
  final OpportunityType type;
  final String location;
  final bool isRemote;
  final String duration; // e.g. "2 months", "6 months"
  final String stipend; // e.g. "₹10,000/month" or "Unpaid"
  final List<String> requiredSkills;
  final List<String> preferredCourseIds; // courses from our platform
  final DateTime postedAt;
  final DateTime deadline;
  final String applyUrl; // external URL
  final bool isApproved;
  final String? relatedCourseId; // if completing a course unlocks apply

  const InternshipOpportunity({
    required this.id,
    required this.companyName,
    required this.companyLogoUrl,
    required this.role,
    required this.description,
    required this.type,
    required this.location,
    required this.isRemote,
    required this.duration,
    required this.stipend,
    required this.requiredSkills,
    required this.preferredCourseIds,
    required this.postedAt,
    required this.deadline,
    required this.applyUrl,
    required this.isApproved,
    this.relatedCourseId,
  });

  bool get isExpired => deadline.isBefore(DateTime.now());

  factory InternshipOpportunity.fromJson(Map<String, dynamic> j) =>
      InternshipOpportunity(
        id: j['id'],
        companyName: j['company_name'],
        companyLogoUrl: j['company_logo_url'] ?? '',
        role: j['role'],
        description: j['description'] ?? '',
        type: OpportunityType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => OpportunityType.internship,
        ),
        location: j['location'] ?? '',
        isRemote: j['is_remote'] ?? false,
        duration: j['duration'] ?? '',
        stipend: j['stipend'] ?? 'Unpaid',
        requiredSkills: List<String>.from(j['required_skills'] ?? []),
        preferredCourseIds: List<String>.from(j['preferred_course_ids'] ?? []),
        postedAt: DateTime.parse(j['posted_at']),
        deadline: DateTime.parse(j['deadline']),
        applyUrl: j['apply_url'],
        isApproved: j['is_approved'] ?? false,
        relatedCourseId: j['related_course_id'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_name': companyName,
        'company_logo_url': companyLogoUrl,
        'role': role,
        'description': description,
        'type': type.name,
        'location': location,
        'is_remote': isRemote,
        'duration': duration,
        'stipend': stipend,
        'required_skills': requiredSkills,
        'preferred_course_ids': preferredCourseIds,
        'posted_at': postedAt.toIso8601String(),
        'deadline': deadline.toIso8601String(),
        'apply_url': applyUrl,
        'is_approved': isApproved,
        'related_course_id': relatedCourseId,
      };
}

// ─── Assignment Submission ────────────────────────────────────
class AssignmentSubmission {
  final String id;
  final String studentId;
  final String assignmentId;
  final String courseId;
  final String submissionText;
  final List<String> attachmentUrls;
  final int? score;
  final String? feedback;
  final bool isGraded;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  const AssignmentSubmission({
    required this.id,
    required this.studentId,
    required this.assignmentId,
    required this.courseId,
    required this.submissionText,
    required this.attachmentUrls,
    this.score,
    this.feedback,
    required this.isGraded,
    required this.submittedAt,
    this.gradedAt,
  });

  factory AssignmentSubmission.fromJson(Map<String, dynamic> j) =>
      AssignmentSubmission(
        id: j['id'],
        studentId: j['student_id'],
        assignmentId: j['assignment_id'],
        courseId: j['course_id'],
        submissionText: j['submission_text'] ?? '',
        attachmentUrls: List<String>.from(j['attachment_urls'] ?? []),
        score: j['score'],
        feedback: j['feedback'],
        isGraded: j['is_graded'] ?? false,
        submittedAt: DateTime.parse(j['submitted_at']),
        gradedAt:
            j['graded_at'] != null ? DateTime.parse(j['graded_at']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'student_id': studentId,
        'assignment_id': assignmentId,
        'course_id': courseId,
        'submission_text': submissionText,
        'attachment_urls': attachmentUrls,
        'score': score,
        'feedback': feedback,
        'is_graded': isGraded,
        'submitted_at': submittedAt.toIso8601String(),
        'graded_at': gradedAt?.toIso8601String(),
      };
}
