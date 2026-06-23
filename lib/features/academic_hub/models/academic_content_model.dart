class AcademicContentModel {
  final String id;
  final String subjectId;
  final String title;
  final String contentType;
  final String? description;
  final int? unitNumber;
  final String? fileUrl;
  final String? storagePath;
  final DateTime createdAt;

  AcademicContentModel({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.contentType,
    this.description,
    this.unitNumber,
    this.fileUrl,
    this.storagePath,
    required this.createdAt,
  });

  bool get isVideo => contentType == 'video';

  factory AcademicContentModel.fromMap(Map<String, dynamic> map) {
    return AcademicContentModel(
      id: map['id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString() ?? map['subjectId']?.toString() ?? '',
      title: map['title'] ?? '',
      contentType: map['content_type'] ?? map['contentType'] ?? '',
      description: map['description'],
      unitNumber: map['unit_number'] ?? map['unitNumber'],
      fileUrl: map['file_url'] ?? map['fileUrl'],
      storagePath: map['storage_path'] ?? map['storagePath'],
      createdAt: DateTime.tryParse(
            map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
