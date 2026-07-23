class Notice {
  final String id;
  final String title;
  final String? description;
  final String? link;
  final String? fileUrl;
  final bool active;
  final DateTime createdAt;

  Notice({
    required this.id,
    required this.title,
    this.description,
    this.link,
    this.fileUrl,
    required this.active,
    required this.createdAt,
  });

  factory Notice.fromMap(Map<String, dynamic> map) {
    return Notice(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      link: map['link'] as String?,
      fileUrl: map['file_url'] as String?,
      active: map['active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
