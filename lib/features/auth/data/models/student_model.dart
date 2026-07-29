// lib/features/auth/data/models/student_model.dart
//
// Student profile model. Mirrors the fields collected on the registration
// screen and returned by the NestJS backend's /auth/login and /auth/register
// responses.

enum CourseType { btech, degree }

CourseType courseTypeFromString(String value) =>
    value == 'degree' ? CourseType.degree : CourseType.btech;

class Student {
  const Student({
    required this.id,
    required this.fullName,
    required this.hallTicketNumber,
    required this.university,
    required this.courseType,
    required this.semester,
    required this.email,
    required this.phone,
    this.branch,
    this.degreeCourse,
    this.group,
  });

  final String id;

  /// Stored as "Lastname Firstname" per MyVault convention.
  final String fullName;

  final String hallTicketNumber;
  final String university;
  final CourseType courseType;

  /// e.g. "CSE" — only set when courseType == btech.
  final String? branch;

  /// e.g. "B.Sc" — only set when courseType == degree.
  final String? degreeCourse;

  /// e.g. "MPC" — optional, degree only.
  final String? group;

  /// Formatted as "Xyr-Ysem", e.g. "2yr-1sem".
  final String semester;

  final String email;
  final String phone;

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        hallTicketNumber: json['hallTicketNumber'] as String,
        university: json['university'] as String,
        courseType: courseTypeFromString(json['courseType'] as String? ?? 'btech'),
        branch: json['branch'] as String?,
        degreeCourse: json['degreeCourse'] as String?,
        group: json['group'] as String?,
        semester: json['semester'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'hallTicketNumber': hallTicketNumber,
        'university': university,
        'courseType': courseType.name,
        'branch': branch,
        'degreeCourse': degreeCourse,
        'group': group,
        'semester': semester,
        'email': email,
        'phone': phone,
      };
}

class AuthResult {
  const AuthResult({required this.token, required this.student});
  final String token;
  final Student student;

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        token: json['token'] as String,
        student: Student.fromJson(json['student'] as Map<String, dynamic>),
      );
}
