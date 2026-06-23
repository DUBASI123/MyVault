class StudentModel {
  final String id;
  final String firstName;
  final String lastName;
  final String fullNameAadhar;
  final String mobile;
  final String email;
  final String hallTicket;
  final String universityId;
  final String collegeId;
  final String universityName;
  final String collegeName;
  final String? collegeLogoUrl;
  final String course;
  final String branch;
  final int semester;
  final int yearOfStudy;
  final int? passingYear;
  final String gender;
  final String state;
  final String? profilePicUrl;
  final bool isMobileVerified;
  final bool isEmailVerified;
  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullNameAadhar,
    required this.mobile,
    required this.email,
    required this.hallTicket,
    required this.universityId,
    required this.collegeId,
    this.universityName = '',
    this.collegeName = '',
    this.collegeLogoUrl,
    required this.course,
    required this.branch,
    required this.semester,
    required this.yearOfStudy,
    this.passingYear,
    required this.gender,
    required this.state,
    this.profilePicUrl,
    required this.isMobileVerified,
    required this.isEmailVerified,
    required this.createdAt,
  });

  /// Stored as LastName FirstName per business rule
  String get fullName => '$lastName $firstName';
  String get displayName => '$lastName $firstName';

  factory StudentModel.fromMap(Map<String, dynamic> json) => StudentModel.fromJson(json);

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name'] ?? json['firstName'] ?? '',
      lastName: json['last_name'] ?? json['lastName'] ?? '',
      fullNameAadhar: json['full_name_aadhar'] ?? json['fullNameAadhar'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      hallTicket: json['hall_ticket'] ?? json['hallTicket'] ?? '',
      universityId: json['university_id']?.toString() ?? '',
      collegeId: json['college_id']?.toString() ?? '',
      universityName: json['university_name'] ?? json['universityName'] ?? '',
      collegeName: json['college_name'] ?? json['collegeName'] ?? '',
      collegeLogoUrl: json['college_logo_url'] ?? json['collegeLogoUrl'],
      course: json['course'] ?? '',
      branch: json['branch'] ?? '',
      semester: json['semester'] ?? 1,
      yearOfStudy: json['year_of_study'] ?? json['yearOfStudy'] ?? 1,
      passingYear: json['passing_year'] ?? json['passingYear'],
      gender: json['gender'] ?? '',
      state: json['state'] ?? '',
      profilePicUrl: json['profile_pic_url'] ?? json['profilePicUrl'],
      isMobileVerified: json['is_mobile_verified'] ?? false,
      isEmailVerified: json['is_email_verified'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'full_name_aadhar': fullNameAadhar,
        'mobile': mobile,
        'email': email,
        'hall_ticket': hallTicket,
        'university_id': universityId,
        'college_id': collegeId,
        'university_name': universityName,
        'college_name': collegeName,
        'college_logo_url': collegeLogoUrl,
        'course': course,
        'branch': branch,
        'semester': semester,
        'year_of_study': yearOfStudy,
        'passing_year': passingYear,
        'gender': gender,
        'state': state,
        'profile_pic_url': profilePicUrl,
        'is_mobile_verified': isMobileVerified,
        'is_email_verified': isEmailVerified,
      };

  StudentModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullNameAadhar,
    String? mobile,
    String? email,
    String? hallTicket,
    String? universityId,
    String? collegeId,
    String? universityName,
    String? collegeName,
    String? collegeLogoUrl,
    String? course,
    String? branch,
    int? semester,
    int? yearOfStudy,
    int? passingYear,
    String? gender,
    String? state,
    String? profilePicUrl,
    bool? isMobileVerified,
    bool? isEmailVerified,
    DateTime? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullNameAadhar: fullNameAadhar ?? this.fullNameAadhar,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      hallTicket: hallTicket ?? this.hallTicket,
      universityId: universityId ?? this.universityId,
      collegeId: collegeId ?? this.collegeId,
      universityName: universityName ?? this.universityName,
      collegeName: collegeName ?? this.collegeName,
      collegeLogoUrl: collegeLogoUrl ?? this.collegeLogoUrl,
      course: course ?? this.course,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      passingYear: passingYear ?? this.passingYear,
      gender: gender ?? this.gender,
      state: state ?? this.state,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isMobileVerified: isMobileVerified ?? this.isMobileVerified,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
