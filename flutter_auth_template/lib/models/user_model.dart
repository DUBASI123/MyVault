class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profilePicUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profilePicUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? json['mobile'] as String?,
      profilePicUrl: json['profilePicUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicUrl': profilePicUrl,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profilePicUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
    );
  }
}
