class SubjectModel {
  final String id;
  final String name;
  final String? code;
  final String branch;
  final int semester;
  final String subjectType;

  SubjectModel({
    required this.id,
    required this.name,
    this.code,
    required this.branch,
    required this.semester,
    this.subjectType = 'academic',
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      code: map['code'],
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? 1,
      subjectType: map['subject_type'] ?? 'academic',
    );
  }
}
