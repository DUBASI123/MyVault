import '../../features/academic_hub/models/academic_content_model.dart';
import '../../features/academic_hub/models/subject_model.dart';
import '../../shared/models/college_model.dart';
import '../../shared/models/student_model.dart';
import '../../shared/models/university_model.dart';

/// Local mock data — replace with API repositories later.
class MockData {
  static final universities = [
    UniversityModel(id: '1', name: 'JNTUH Affiliated', code: 'JNTUH', state: 'Telangana'),
    UniversityModel(id: '2', name: 'Osmania University Affiliated', code: 'OU', state: 'Telangana'),
    UniversityModel(id: '3', name: 'Kakatiya University Affiliated', code: 'KU', state: 'Telangana'),
    UniversityModel(id: '4', name: 'RGUKT Campuses', code: 'RGUKT', state: 'Telangana'),
    UniversityModel(id: '5', name: 'Government Engineering Colleges', code: 'Govt', state: 'Telangana'),
    UniversityModel(id: '6', name: 'National Institutes & Private Universities', code: 'National', state: 'Telangana'),
  ];

  static final colleges = [
    CollegeModel(id: 'c_nitw', universityId: '6', name: 'NIT Warangal', code: 'NITW', district: 'Hanamkonda', type: 'Government'),
    CollegeModel(id: 'c_kitsw', universityId: '3', name: 'KITS Warangal', code: 'KITSW', district: 'Hasanparthy, Hanamkonda', type: 'Private'),
    CollegeModel(id: 'c_vcew', universityId: '3', name: 'Vaagdevi College of Engineering', code: 'VCEW', district: 'Bollikunta, Warangal', type: 'Private'),
    CollegeModel(id: 'c_sru', universityId: '6', name: 'SR University', code: 'SRU', district: 'Ananthasagar, Hasanparthy', type: 'Private'),
    CollegeModel(id: 'c_svs', universityId: '3', name: 'SVS Group of Institutions', code: 'SVS', district: 'Bheemaram, Hanamkonda', type: 'Private'),
    CollegeModel(id: 'c_tpce', universityId: '3', name: 'Talla Padmavathi College of Engineering', code: 'TPCE', district: 'Somidi, Kazipet', type: 'Private'),
    CollegeModel(id: 'c_cits', universityId: '3', name: 'Chaitanya Institute of Technology and Science', code: 'CITS', district: 'Kishanpura, Hanamkonda', type: 'Private'),
    CollegeModel(id: 'c_arti', universityId: '3', name: "Ramappa Engineering College (Aurora's Research and Technological Institute)", code: 'ARTI', district: 'Shyampet, Hanamkonda', type: 'Private'),
    CollegeModel(id: 'c_bits', universityId: '3', name: 'Balaji Institute of Technology & Science (BITS)', code: 'BITS', district: 'Laknepally, Narsampet Road', type: 'Private'),
    CollegeModel(id: 'c_wits', universityId: '3', name: 'Warangal Institute of Technology and Science', code: 'WITS', district: 'Oorugonda, Atmakur', type: 'Private'),
  ];

  static List<CollegeModel> collegesForUniversity(String universityName) {
    final uni = universities.firstWhere(
      (u) => u.code == universityName || u.name == universityName,
      orElse: () => universities.first,
    );
    return colleges.where((c) => c.universityId == uni.id).toList();
  }

  static final demoStudent = StudentModel(
    id: 'demo-1',
    firstName: 'Shivashankar',
    lastName: 'Dubasi',
    fullNameAadhar: 'Dubasi Shivashankar',
    mobile: '9876543210',
    email: 'shiva@example.com',
    hallTicket: 'JNTUH20CS001',
    universityId: '1',
    collegeId: 'c_1',
    universityName: 'JNTUH',
    collegeName: 'JNTU College of Engineering Hyderabad',
    course: 'B.Tech',
    branch: 'CSE',
    semester: 3,
    yearOfStudy: 2,
    passingYear: 2026,
    gender: 'Male',
    state: 'Telangana',
    isMobileVerified: true,
    isEmailVerified: true,
    createdAt: DateTime.now(),
  );

  static const notificationTicker =
      '🔔 TSPSC Notification Released | 🏢 Infosys Internship Open | '
      '📝 JNTUH Mid-2 Exams: Dec 15 | 🎯 GATE 2025 Registration Open';

  static final internships = [
    {
      'id': 'i1',
      'company': 'Infosys',
      'role': 'Software Engineer Intern',
      'type': 'IT',
      'domain': 'Java / Python',
      'stipend': '₹15,000/month',
      'duration': '6 months',
      'deadline': '2024-12-31',
      'applyLink': 'https://infosys.com',
      'logo': '🏢',
      'status': 'Open',
    },
    {
      'id': 'i2',
      'company': 'TCS',
      'role': 'IT Intern - Digital',
      'type': 'IT',
      'domain': 'Web Development',
      'stipend': '₹12,000/month',
      'duration': '3 months',
      'deadline': '2024-12-15',
      'applyLink': 'https://tcs.com',
      'logo': '🏢',
      'status': 'Open',
    },
    {
      'id': 'i3',
      'company': 'BHEL',
      'role': 'Mechanical Engineering Intern',
      'type': 'core',
      'domain': 'Mechanical',
      'stipend': '₹10,000/month',
      'duration': '2 months',
      'deadline': '2024-11-30',
      'applyLink': 'https://bhel.com',
      'logo': '🏭',
      'status': 'Closing Soon',
    },
    {
      'id': 'i4',
      'company': 'AWS',
      'role': 'Cloud Tools Intern',
      'type': 'tools',
      'domain': 'Cloud Computing',
      'stipend': '₹20,000/month',
      'duration': '6 months',
      'deadline': '2024-12-25',
      'applyLink': 'https://aws.amazon.com',
      'logo': '☁️',
      'status': 'Open',
    },
  ];

  static final results = [
    {
      'subject': 'Mathematics - I',
      'code': 'M101',
      'internal': 28,
      'external': 62,
      'total': 90,
      'max': 100,
      'grade': 'A+',
      'status': 'Pass',
    },
    {
      'subject': 'Data Structures',
      'code': 'CS201',
      'internal': 20,
      'external': 35,
      'total': 55,
      'max': 100,
      'grade': 'C',
      'status': 'Pass',
    },
    {
      'subject': 'DBMS',
      'code': 'CS301',
      'internal': 18,
      'external': 24,
      'total': 42,
      'max': 100,
      'grade': 'F',
      'status': 'Fail',
    },
  ];

  static final notifications = [
    {
      'title': 'TSPSC Group I Notification',
      'message': 'TSPSC Group I notification released. Last date: Dec 31',
      'type': 'govt_job',
    },
    {
      'title': 'JNTUH Mid-2 Exams',
      'message': 'Mid-2 examinations start from December 15, 2024',
      'type': 'exam_timetable',
    },
    {
      'title': 'Infosys Internship',
      'message': 'Infosys InfyTQ internship program is now open',
      'type': 'private_job',
    },
  ];

  static final certifications = [
    {'name': 'Python Fundamentals', 'date': '2024-01-15', 'score': '92%'},
    {'name': 'Web Development Basics', 'date': '2024-02-20', 'score': '88%'},
    {'name': 'Data Structures & Algorithms', 'date': '2024-03-10', 'score': '95%'},
  ];

  static final subjects = [
    SubjectModel(
      id: 'sub-math',
      name: 'Mathematics',
      code: 'MA201',
      branch: 'CSE',
      semester: 3,
    ),
    SubjectModel(
      id: 'sub-phy',
      name: 'Physics',
      code: 'PH201',
      branch: 'CSE',
      semester: 3,
    ),
    SubjectModel(
      id: 'sub-ds',
      name: 'Data Structures',
      code: 'CS201',
      branch: 'CSE',
      semester: 3,
    ),
    SubjectModel(
      id: 'sub-dbms',
      name: 'DBMS',
      code: 'CS301',
      branch: 'CSE',
      semester: 3,
    ),
  ];

  static final academicContents = [
    AcademicContentModel(
      id: 'c_1',
      subjectId: 'sub-ds',
      title: 'DS Unit 1 Notes',
      contentType: 'notes',
      description: 'Introduction to Arrays & Linked Lists',
      unitNumber: 1,
      fileUrl:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      createdAt: DateTime(2024, 8, 1),
    ),
    AcademicContentModel(
      id: 'c_2',
      subjectId: 'sub-ds',
      title: 'DS Syllabus Copy',
      contentType: 'syllabus',
      fileUrl:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      createdAt: DateTime(2024, 7, 15),
    ),
    AcademicContentModel(
      id: 'c_3',
      subjectId: 'sub-ds',
      title: 'Stacks & Queues Lecture',
      contentType: 'video',
      description: 'Recorded classroom session',
      fileUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      createdAt: DateTime(2024, 9, 1),
    ),
    AcademicContentModel(
      id: 'c_4',
      subjectId: 'sub-math',
      title: 'Math Unit 2 Notes',
      contentType: 'notes',
      unitNumber: 2,
      fileUrl:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      createdAt: DateTime(2024, 8, 10),
    ),
  ];
}
