class CollegeModel {
  final String id;
  final String universityId;
  final String name;
  final String code;
  final String? logoUrl;
  final String? district;
  final String? type;
  final String? state;

  CollegeModel({
    required this.id,
    required this.universityId,
    required this.name,
    required this.code,
    this.logoUrl,
    this.district,
    this.type,
    this.state,
  });

  factory CollegeModel.fromJson(Map<String, dynamic> json) {
    return CollegeModel(
      id: json['id']?.toString() ?? '',
      universityId: json['university_id']?.toString() ?? json['universityId']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      logoUrl: json['logo_url'] ?? json['logoUrl'],
      district: json['district'],
      type: json['type'],
      state: json['state'],
    );
  }
}
