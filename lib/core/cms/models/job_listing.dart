class JobListing {
  final String id;
  final String category;
  final String? sector;
  final String companyOrDept;
  final String title;
  final String? description;
  final String applyLink;
  final DateTime? deadline;
  final bool active;
  final DateTime createdAt;

  JobListing({
    required this.id,
    required this.category,
    this.sector,
    required this.companyOrDept,
    required this.title,
    this.description,
    required this.applyLink,
    this.deadline,
    required this.active,
    required this.createdAt,
  });

  factory JobListing.fromMap(Map<String, dynamic> map) {
    return JobListing(
      id: map['id'] as String,
      category: map['category'] as String,
      sector: map['sector'] as String?,
      companyOrDept: map['company_or_dept'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      applyLink: map['apply_link'] as String,
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline'] as String) : null,
      active: map['active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isExpired => deadline != null && deadline!.isBefore(DateTime.now());
}
