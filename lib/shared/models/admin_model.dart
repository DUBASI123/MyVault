class AdminModel {
  final String id;
  final String email;
  final String collegeId;

  AdminModel({
    required this.id,
    required this.email,
    required this.collegeId,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      collegeId: json['college_id']?.toString() ?? json['collegeId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'college_id': collegeId,
      };
}
