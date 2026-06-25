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
    // JNTUH
    CollegeModel(id: 'c_1', universityId: '1', name: 'A.M.R Institute of Technology', code: 'AIOT', district: 'Adilabad', type: 'Private'),
    CollegeModel(id: 'c_2', universityId: '1', name: 'Abdul Kalam Institute of Technological Sciences', code: 'AKIOT', district: 'Karimnagar', type: 'Private'),
    CollegeModel(id: 'c_3', universityId: '1', name: 'ACE Engineering College', code: 'AEC', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_4', universityId: '1', name: 'Adams Engineering College', code: 'AEC', district: 'Khammam', type: 'Private'),
    CollegeModel(id: 'c_5', universityId: '1', name: 'Adusumalli Vijaya College of Engineering and Research Centre', code: 'AVCOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_6', universityId: '1', name: 'Adusumalli Vijaya Institute of Technology', code: 'AVIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_7', universityId: '1', name: 'Aizza College of Engineering and Technology', code: 'ACOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_8', universityId: '1', name: 'Al-Habeeb College of Engineering and Technology', code: 'ACOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_9', universityId: '1', name: 'Amina Institute of Technology', code: 'AIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_10', universityId: '1', name: 'Anasuya Devi Institute of Technology and Sciences', code: 'ADIOT', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_11', universityId: '1', name: 'Anjamma Agi Reddy Engineering College for Women', code: 'AAREC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_12', universityId: '1', name: 'Annamacharya Institute of Technology and Sciences', code: 'AIOTA', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_13', universityId: '1', name: 'Anu Bose Institute of Technology', code: 'ABIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_14', universityId: '1', name: 'Anurag College of Engineering', code: 'ACOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_15', universityId: '1', name: 'Anurag Engineering College', code: 'AEC', district: 'Nalgonda', type: 'Private'),
    CollegeModel(id: 'c_16', universityId: '1', name: 'Aurora Group of Institutions', code: 'AGOI', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_17', universityId: '1', name: 'Aurora Scientific Technological Institute', code: 'ASTI', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_18', universityId: '1', name: 'Balaji Institute of Technology and Science', code: 'BIOTA', district: 'Nalgonda', type: 'Private'),
    CollegeModel(id: 'c_19', universityId: '1', name: 'Bharat Institute of Engineering and Technology', code: 'BIOEA', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_20', universityId: '1', name: 'Bhoj Reddy Engineering College for Women', code: 'BRECF', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_21', universityId: '1', name: 'BVRIT Hyderabad College of Engineering for Women', code: 'BHCOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_22', universityId: '1', name: 'BV Raju Institute of Technology', code: 'BRIOT', district: 'Medak', type: 'Private'),
    CollegeModel(id: 'c_23', universityId: '1', name: 'CMR College of Engineering and Technology', code: 'CCOEA', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_24', universityId: '1', name: 'CMR Engineering College', code: 'CEC', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_25', universityId: '1', name: 'CVR College of Engineering', code: 'CCOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_26', universityId: '1', name: 'Ellenki College of Engineering and Technology', code: 'ECOEA', district: 'Sangareddy', type: 'Private'),
    CollegeModel(id: 'c_27', universityId: '1', name: 'Geethanjali College of Engineering and Technology', code: 'GCOEA', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_28', universityId: '1', name: 'Gokaraju Rangaraju Institute of Engineering and Technology', code: 'GRIOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_29', universityId: '1', name: 'Guru Nanak Institutions Technical Campus', code: 'GNITC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_30', universityId: '1', name: 'Holy Mary Institute of Technology and Science', code: 'HMIOT', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_31', universityId: '1', name: 'J.B. Institute of Engineering and Technology', code: 'JIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_32', universityId: '1', name: 'Joginpally B.R Engineering College', code: 'JBEC', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_33', universityId: '1', name: 'Kakatiya Institute of Technology and Science', code: 'KIOTA', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_34', universityId: '1', name: 'Keshav Memorial Institute of Technology', code: 'KMIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_35', universityId: '1', name: 'Kommuri Pratap Reddy Institute of Technology', code: 'KPRIO', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_36', universityId: '1', name: 'Mahatma Gandhi Institute of Technology', code: 'MGIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_37', universityId: '1', name: 'Malla Reddy College of Engineering', code: 'MRCOE', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_38', universityId: '1', name: 'Malla Reddy Engineering College', code: 'MREC', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_39', universityId: '1', name: 'Malla Reddy Institute of Technology', code: 'MRIOT', district: 'Medchal', type: 'Private'),
    CollegeModel(id: 'c_40', universityId: '1', name: 'Maturi Venkata Subba Rao Engineering College', code: 'MVSRE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_41', universityId: '1', name: 'MLR Institute of Technology', code: 'MIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_42', universityId: '1', name: 'Nalla Malla Reddy Engineering College', code: 'NMREC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_43', universityId: '1', name: 'Narsimha Reddy Engineering College', code: 'NREC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_44', universityId: '1', name: 'Princeton Institute of Engineering and Technology', code: 'PIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_45', universityId: '1', name: 'Sreyas Institute of Engineering and Technology', code: 'SIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_46', universityId: '1', name: 'Sreenidhi Institute of Science and Technology', code: 'SIOSA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_47', universityId: '1', name: 'Sri Indu College of Engineering and Technology', code: 'SICOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_48', universityId: '1', name: 'St Martins Engineering College', code: 'SMEC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_49', universityId: '1', name: 'TKR College of Engineering and Technology', code: 'TCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_50', universityId: '1', name: 'Vardhaman College of Engineering', code: 'VCOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: 'c_51', universityId: '1', name: 'Vidya Jyothi Institute of Technology', code: 'VJIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_52', universityId: '1', name: 'Vignan Institute of Technology and Science', code: 'VIOTA', district: 'Nalgonda', type: 'Private'),
    CollegeModel(id: 'c_53', universityId: '1', name: 'Vignana Bharathi Institute of Technology', code: 'VBIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_54', universityId: '1', name: 'VNR Vignana Jyothi Institute of Engineering and Technology', code: 'VVJIO', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_55', universityId: '1', name: 'Vaageshwari College of Engineering', code: 'VCOE', district: 'Karimnagar', type: 'Private'),
    CollegeModel(id: 'c_56', universityId: '1', name: 'Vaagdevi Engineering College', code: 'VEC', district: 'Hanamkonda', type: 'Private'),
    // OU
    CollegeModel(id: 'c_57', universityId: '2', name: 'Chaitanya Bharathi Institute of Technology', code: 'CBIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_58', universityId: '2', name: 'University College of Engineering Osmania University', code: 'UCOEO', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: 'c_59', universityId: '2', name: 'Vasavi College of Engineering', code: 'VCOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_60', universityId: '2', name: 'Muffakham Jah College of Engineering and Technology', code: 'MJCOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_61', universityId: '2', name: 'Deccan College of Engineering and Technology', code: 'DCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_62', universityId: '2', name: 'ISL Engineering College', code: 'IEC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_63', universityId: '2', name: 'Lords Institute of Engineering and Technology', code: 'LIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_64', universityId: '2', name: 'Methodist College of Engineering and Technology', code: 'MCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_65', universityId: '2', name: 'Nawab Shah Alam Khan College of Engineering and Technology', code: 'NSAKC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_66', universityId: '2', name: 'Stanley College of Engineering and Technology for Women', code: 'SCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_67', universityId: '2', name: 'Anwar Ul Uloom College of Engineering and Technology', code: 'AUUCO', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_68', universityId: '2', name: 'Mahaveer Institute of Science and Technology', code: 'MIOSA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_69', universityId: '2', name: 'Matrusri Engineering College', code: 'MEC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_70', universityId: '2', name: 'Shadan College of Engineering and Technology', code: 'SCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_71', universityId: '2', name: 'Islamia College of Engineering and Technology', code: 'ICOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: 'c_72', universityId: '2', name: 'Khaja Banda Nawaz College of Engineering', code: 'KBNCO', district: 'Kalaburagi', type: 'Private'),
    // KU
    CollegeModel(id: 'c_73', universityId: '3', name: 'KITS Warangal', code: 'KW', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_74', universityId: '3', name: 'KU College of Engineering and Technology', code: 'KCOEA', district: 'Warangal', type: 'Government'),
    CollegeModel(id: 'c_75', universityId: '3', name: 'KU College of Engineering Kothagudem', code: 'KCOEK', district: 'Bhadradri Kothagudem', type: 'Government'),
    CollegeModel(id: 'c_76', universityId: '3', name: 'Vaagdevi Engineering College', code: 'VEC', district: 'Hanamkonda', type: 'Private'),
    CollegeModel(id: 'c_77', universityId: '3', name: 'SR Engineering College', code: 'SEC', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_78', universityId: '3', name: 'Christu Jyothi Institute of Technology and Science', code: 'CJIOT', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_79', universityId: '3', name: 'Warangal Institute of Technology and Science', code: 'WIOTA', district: 'Hanamkonda', type: 'Private'),
    CollegeModel(id: 'c_80', universityId: '3', name: 'Jayamukhi Institute of Technological Sciences', code: 'JIOTS', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_81', universityId: '3', name: 'Ganapathy Engineering College', code: 'GEC', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_82', universityId: '3', name: 'Mother Teresa Institute of Science and Technology', code: 'MTIOS', district: 'Khammam', type: 'Private'),
    CollegeModel(id: 'c_83', universityId: '3', name: 'Aurum Institute of Technology', code: 'AIOT', district: 'Warangal', type: 'Private'),
    CollegeModel(id: 'c_84', universityId: '3', name: 'Vaageshwari Engineering College', code: 'VEC', district: 'Karimnagar', type: 'Private'),
    // RGUKT
    CollegeModel(id: 'c_85', universityId: '4', name: 'RGUKT Basar', code: 'RB', district: 'Nirmal', type: 'Government'),
    CollegeModel(id: 'c_86', universityId: '4', name: 'RGUKT Nuzvid', code: 'RN', district: 'Krishna', type: 'Government'),
    CollegeModel(id: 'c_87', universityId: '4', name: 'RGUKT RK Valley', code: 'RRV', district: 'Kadapa', type: 'Government'),
    // Govt
    CollegeModel(id: 'c_88', universityId: '5', name: 'JNTUH College of Engineering Hyderabad', code: 'JCOEH', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: 'c_89', universityId: '5', name: 'JNTUH College of Engineering Sultanpur', code: 'JCOES', district: 'Medak', type: 'Government'),
    CollegeModel(id: 'c_90', universityId: '5', name: 'JNTUH College of Engineering Jagtial', code: 'JCOEJ', district: 'Jagitial', type: 'Government'),
    CollegeModel(id: 'c_91', universityId: '5', name: 'JNTUH College of Engineering Manthani', code: 'JCOEM', district: 'Peddapalli', type: 'Government'),
    CollegeModel(id: 'c_92', universityId: '5', name: 'JNTUH College of Engineering Rajanna Sircilla', code: 'JCOER', district: 'Rajanna Sircilla', type: 'Government'),
    CollegeModel(id: 'c_93', universityId: '5', name: 'JNTUH College of Engineering Wanaparthy', code: 'JCOEW', district: 'Wanaparthy', type: 'Government'),
    CollegeModel(id: 'c_94', universityId: '5', name: 'JNTUH College of Engineering Mahabubabad', code: 'JCOEM', district: 'Mahabubabad', type: 'Government'),
    CollegeModel(id: 'c_95', universityId: '5', name: 'JNTUH College of Engineering Palair', code: 'JCOEP', district: 'Khammam', type: 'Government'),
    CollegeModel(id: 'c_96', universityId: '5', name: 'Osmania University College of Engineering', code: 'OUCOE', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: 'c_97', universityId: '5', name: 'Osmania University College of Technology', code: 'OUCOT', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: 'c_98', universityId: '5', name: 'KU College of Engineering and Technology', code: 'KCOEA', district: 'Warangal', type: 'Government'),
    CollegeModel(id: 'c_99', universityId: '5', name: 'Government Engineering College Kosgi', code: 'GECK', district: 'Mahabubnagar', type: 'Government'),
    CollegeModel(id: 'c_100', universityId: '5', name: 'MGU College of Engineering and Technology', code: 'MCOEA', district: 'Nalgonda', type: 'Government'),
    // National
    CollegeModel(id: 'c_101', universityId: '6', name: 'Indian Institute of Technology Hyderabad', code: 'IIOTH', district: 'Sangareddy', type: 'National Institute'),
    CollegeModel(id: 'c_102', universityId: '6', name: 'National Institute of Technology Warangal', code: 'NIOTW', district: 'Warangal', type: 'National Institute'),
    CollegeModel(id: 'c_103', universityId: '6', name: 'International Institute of Information Technology Hyderabad', code: 'IIOIT', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: 'c_104', universityId: '6', name: 'BITS Pilani Hyderabad Campus', code: 'BPHC', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: 'c_105', universityId: '6', name: 'Mahindra University', code: 'MU', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: 'c_106', universityId: '6', name: 'Woxsen University', code: 'WU', district: 'Sangareddy', type: 'Deemed University'),
    CollegeModel(id: 'c_107', universityId: '6', name: 'Anurag University', code: 'AU', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: 'c_108', universityId: '6', name: 'ICFAI Tech School', code: 'ITS', district: 'Hyderabad', type: 'Deemed University'),
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
