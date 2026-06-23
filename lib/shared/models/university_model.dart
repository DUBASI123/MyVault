class UniversityModel {
  final String id;
  final String name;
  final String code;
  final String? state;

  UniversityModel({
    required this.id,
    required this.name,
    required this.code,
    this.state,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      state: json['state'],
    );
  }
}
