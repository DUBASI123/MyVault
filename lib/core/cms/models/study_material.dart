class StudyMaterial {
  final String id;
  final String examCategory;
  final String contentType;
  final String title;
  final String branch;
  final String year;
  final String semester;
  final String sectionTab;
  final String? description;
  final String? externalLink;
  final String? fileUrl;
  final bool active;
  final DateTime createdAt;

  StudyMaterial({
    required this.id,
    required this.examCategory,
    required this.contentType,
    required this.title,
    this.branch = 'ECE',
    this.year = 'Y1',
    this.semester = 'S1',
    this.sectionTab = 'Subjects',
    this.description,
    this.externalLink,
    this.fileUrl,
    required this.active,
    required this.createdAt,
  });

  factory StudyMaterial.fromMap(Map<String, dynamic> map) {
    return StudyMaterial(
      id: map['id'] as String? ?? 'id_${DateTime.now().millisecondsSinceEpoch}',
      examCategory: map['exam_category'] as String? ?? 'Academic Notes',
      contentType: map['content_type'] as String? ?? 'Academic File (PDF)',
      title: map['title'] as String? ?? 'ECE Semester 1 Core Subject Notes',
      branch: (map['branch'] as String?)?.isNotEmpty == true ? map['branch'] as String : 'ECE',
      year: (map['year'] as String?)?.isNotEmpty == true ? map['year'] as String : 'Y1',
      semester: (map['semester'] as String?)?.isNotEmpty == true ? map['semester'] as String : 'S1',
      sectionTab: (map['section_tab'] as String?)?.isNotEmpty == true ? map['section_tab'] as String : 'Subjects',
      description: map['description'] as String? ?? 'Syllabus, lecture notes & practice problems.',
      externalLink: map['external_link'] as String?,
      fileUrl: map['file_url'] as String?,
      active: map['active'] as bool? ?? true,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_category': examCategory,
      'content_type': contentType,
      'title': title,
      'branch': branch,
      'year': year,
      'semester': semester,
      'section_tab': sectionTab,
      'description': description,
      'external_link': externalLink,
      'file_url': fileUrl,
      'active': active,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get hasResource => (externalLink?.isNotEmpty ?? false) || (fileUrl?.isNotEmpty ?? false);
  String? get resourceUrl => fileUrl?.isNotEmpty == true ? fileUrl : externalLink;
}
