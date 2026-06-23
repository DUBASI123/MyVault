class SubjectModel {
  final String id;
  final String name;
  final String? code;
  final String branch;
  final int semester;

  SubjectModel({
    required this.id,
    required this.name,
    this.code,
    required this.branch,
    required this.semester,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      code: map['code'],
      branch: map['branch'] ?? '',
      semester: map['semester'] ?? 1,
    );
  }
}
