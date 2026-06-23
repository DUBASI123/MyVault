import '../../features/academic_hub/models/academic_content_model.dart';
import '../../features/academic_hub/models/subject_model.dart';
import '../../shared/models/college_model.dart';
import '../../shared/models/student_model.dart';
import '../../shared/models/university_model.dart';

/// Local mock data — replace with API repositories later.
class MockData {
  static final universities = [
    UniversityModel(id: '00000000-0000-0000-0000-000000000001', name: 'JNTUH Affiliated', code: 'JNTUH', state: 'Telangana'),
    UniversityModel(id: '00000000-0000-0000-0000-000000000002', name: 'Osmania University Affiliated', code: 'OU', state: 'Telangana'),
    UniversityModel(id: '00000000-0000-0000-0000-000000000003', name: 'Kakatiya University Affiliated', code: 'KU', state: 'Telangana'),
    UniversityModel(id: '00000000-0000-0000-0000-000000000004', name: 'RGUKT Campuses', code: 'RGUKT', state: 'Telangana'),
    UniversityModel(id: '00000000-0000-0000-0000-000000000005', name: 'Government Engineering Colleges', code: 'Govt', state: 'Telangana'),
    UniversityModel(id: '00000000-0000-0000-0000-000000000006', name: 'National Institutes & Private Universities', code: 'National', state: 'Telangana'),
  ];

  static final colleges = [
    // JNTUH
    CollegeModel(id: '00000000-0000-0000-0000-000000000101', universityId: '00000000-0000-0000-0000-000000000001', name: 'A.M.R Institute of Technology', code: 'AIOT', district: 'Adilabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000102', universityId: '00000000-0000-0000-0000-000000000001', name: 'Abdul Kalam Institute of Technological Sciences', code: 'AKIOT', district: 'Karimnagar', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000103', universityId: '00000000-0000-0000-0000-000000000001', name: 'ACE Engineering College', code: 'AEC', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000104', universityId: '00000000-0000-0000-0000-000000000001', name: 'Adams Engineering College', code: 'AEC', district: 'Khammam', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000105', universityId: '00000000-0000-0000-0000-000000000001', name: 'Adusumalli Vijaya College of Engineering and Research Centre', code: 'AVCOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000106', universityId: '00000000-0000-0000-0000-000000000001', name: 'Adusumalli Vijaya Institute of Technology', code: 'AVIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000107', universityId: '00000000-0000-0000-0000-000000000001', name: 'Aizza College of Engineering and Technology', code: 'ACOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000108', universityId: '00000000-0000-0000-0000-000000000001', name: 'Al-Habeeb College of Engineering and Technology', code: 'ACOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000109', universityId: '00000000-0000-0000-0000-000000000001', name: 'Amina Institute of Technology', code: 'AIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000010a', universityId: '00000000-0000-0000-0000-000000000001', name: 'Anasuya Devi Institute of Technology and Sciences', code: 'ADIOT', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000010b', universityId: '00000000-0000-0000-0000-000000000001', name: 'Anjamma Agi Reddy Engineering College for Women', code: 'AAREC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000010c', universityId: '00000000-0000-0000-0000-000000000001', name: 'Annamacharya Institute of Technology and Sciences', code: 'AIOTA', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000010d', universityId: '00000000-0000-0000-0000-000000000001', name: 'Anu Bose Institute of Technology', code: 'ABIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000010e', universityId: '00000000-0000-0000-0000-000000000001', name: 'Anurag College of Engineering', code: 'ACOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000010f', universityId: '00000000-0000-0000-0000-000000000001', name: 'Anurag Engineering College', code: 'AEC', district: 'Nalgonda', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000110', universityId: '00000000-0000-0000-0000-000000000001', name: 'Aurora Group of Institutions', code: 'AGOI', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000111', universityId: '00000000-0000-0000-0000-000000000001', name: 'Aurora Scientific Technological Institute', code: 'ASTI', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000112', universityId: '00000000-0000-0000-0000-000000000001', name: 'Balaji Institute of Technology and Science', code: 'BIOTA', district: 'Nalgonda', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000113', universityId: '00000000-0000-0000-0000-000000000001', name: 'Bharat Institute of Engineering and Technology', code: 'BIOEA', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000114', universityId: '00000000-0000-0000-0000-000000000001', name: 'Bhoj Reddy Engineering College for Women', code: 'BRECF', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000115', universityId: '00000000-0000-0000-0000-000000000001', name: 'BVRIT Hyderabad College of Engineering for Women', code: 'BHCOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000116', universityId: '00000000-0000-0000-0000-000000000001', name: 'BV Raju Institute of Technology', code: 'BRIOT', district: 'Medak', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000117', universityId: '00000000-0000-0000-0000-000000000001', name: 'CMR College of Engineering and Technology', code: 'CCOEA', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000118', universityId: '00000000-0000-0000-0000-000000000001', name: 'CMR Engineering College', code: 'CEC', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000119', universityId: '00000000-0000-0000-0000-000000000001', name: 'CVR College of Engineering', code: 'CCOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000011a', universityId: '00000000-0000-0000-0000-000000000001', name: 'Ellenki College of Engineering and Technology', code: 'ECOEA', district: 'Sangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000011b', universityId: '00000000-0000-0000-0000-000000000001', name: 'Geethanjali College of Engineering and Technology', code: 'GCOEA', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000011c', universityId: '00000000-0000-0000-0000-000000000001', name: 'Gokaraju Rangaraju Institute of Engineering and Technology', code: 'GRIOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000011d', universityId: '00000000-0000-0000-0000-000000000001', name: 'Guru Nanak Institutions Technical Campus', code: 'GNITC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000011e', universityId: '00000000-0000-0000-0000-000000000001', name: 'Holy Mary Institute of Technology and Science', code: 'HMIOT', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000011f', universityId: '00000000-0000-0000-0000-000000000001', name: 'J.B. Institute of Engineering and Technology', code: 'JIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000120', universityId: '00000000-0000-0000-0000-000000000001', name: 'Joginpally B.R Engineering College', code: 'JBEC', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000121', universityId: '00000000-0000-0000-0000-000000000001', name: 'Kakatiya Institute of Technology and Science', code: 'KIOTA', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000122', universityId: '00000000-0000-0000-0000-000000000001', name: 'Keshav Memorial Institute of Technology', code: 'KMIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000123', universityId: '00000000-0000-0000-0000-000000000001', name: 'Kommuri Pratap Reddy Institute of Technology', code: 'KPRIO', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000124', universityId: '00000000-0000-0000-0000-000000000001', name: 'Mahatma Gandhi Institute of Technology', code: 'MGIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000125', universityId: '00000000-0000-0000-0000-000000000001', name: 'Malla Reddy College of Engineering', code: 'MRCOE', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000126', universityId: '00000000-0000-0000-0000-000000000001', name: 'Malla Reddy Engineering College', code: 'MREC', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000127', universityId: '00000000-0000-0000-0000-000000000001', name: 'Malla Reddy Institute of Technology', code: 'MRIOT', district: 'Medchal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000128', universityId: '00000000-0000-0000-0000-000000000001', name: 'Maturi Venkata Subba Rao Engineering College', code: 'MVSRE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000129', universityId: '00000000-0000-0000-0000-000000000001', name: 'MLR Institute of Technology', code: 'MIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000012a', universityId: '00000000-0000-0000-0000-000000000001', name: 'Nalla Malla Reddy Engineering College', code: 'NMREC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000012b', universityId: '00000000-0000-0000-0000-000000000001', name: 'Narsimha Reddy Engineering College', code: 'NREC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000012c', universityId: '00000000-0000-0000-0000-000000000001', name: 'Princeton Institute of Engineering and Technology', code: 'PIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000012d', universityId: '00000000-0000-0000-0000-000000000001', name: 'Sreyas Institute of Engineering and Technology', code: 'SIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000012e', universityId: '00000000-0000-0000-0000-000000000001', name: 'Sreenidhi Institute of Science and Technology', code: 'SIOSA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000012f', universityId: '00000000-0000-0000-0000-000000000001', name: 'Sri Indu College of Engineering and Technology', code: 'SICOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000130', universityId: '00000000-0000-0000-0000-000000000001', name: 'St Martins Engineering College', code: 'SMEC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000131', universityId: '00000000-0000-0000-0000-000000000001', name: 'TKR College of Engineering and Technology', code: 'TCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000132', universityId: '00000000-0000-0000-0000-000000000001', name: 'Vardhaman College of Engineering', code: 'VCOE', district: 'Rangareddy', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000133', universityId: '00000000-0000-0000-0000-000000000001', name: 'Vidya Jyothi Institute of Technology', code: 'VJIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000134', universityId: '00000000-0000-0000-0000-000000000001', name: 'Vignan Institute of Technology and Science', code: 'VIOTA', district: 'Nalgonda', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000135', universityId: '00000000-0000-0000-0000-000000000001', name: 'Vignana Bharathi Institute of Technology', code: 'VBIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000136', universityId: '00000000-0000-0000-0000-000000000001', name: 'VNR Vignana Jyothi Institute of Engineering and Technology', code: 'VVJIO', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000137', universityId: '00000000-0000-0000-0000-000000000001', name: 'Vaageshwari College of Engineering', code: 'VCOE', district: 'Karimnagar', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000138', universityId: '00000000-0000-0000-0000-000000000001', name: 'Vaagdevi Engineering College', code: 'VEC', district: 'Hanamkonda', type: 'Private'),
    // OU
    CollegeModel(id: '00000000-0000-0000-0000-000000000139', universityId: '00000000-0000-0000-0000-000000000002', name: 'Chaitanya Bharathi Institute of Technology', code: 'CBIOT', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000013a', universityId: '00000000-0000-0000-0000-000000000002', name: 'University College of Engineering Osmania University', code: 'UCOEO', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000013b', universityId: '00000000-0000-0000-0000-000000000002', name: 'Vasavi College of Engineering', code: 'VCOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000013c', universityId: '00000000-0000-0000-0000-000000000002', name: 'Muffakham Jah College of Engineering and Technology', code: 'MJCOE', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000013d', universityId: '00000000-0000-0000-0000-000000000002', name: 'Deccan College of Engineering and Technology', code: 'DCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000013e', universityId: '00000000-0000-0000-0000-000000000002', name: 'ISL Engineering College', code: 'IEC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000013f', universityId: '00000000-0000-0000-0000-000000000002', name: 'Lords Institute of Engineering and Technology', code: 'LIOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000140', universityId: '00000000-0000-0000-0000-000000000002', name: 'Methodist College of Engineering and Technology', code: 'MCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000141', universityId: '00000000-0000-0000-0000-000000000002', name: 'Nawab Shah Alam Khan College of Engineering and Technology', code: 'NSAKC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000142', universityId: '00000000-0000-0000-0000-000000000002', name: 'Stanley College of Engineering and Technology for Women', code: 'SCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000143', universityId: '00000000-0000-0000-0000-000000000002', name: 'Anwar Ul Uloom College of Engineering and Technology', code: 'AUUCO', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000144', universityId: '00000000-0000-0000-0000-000000000002', name: 'Mahaveer Institute of Science and Technology', code: 'MIOSA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000145', universityId: '00000000-0000-0000-0000-000000000002', name: 'Matrusri Engineering College', code: 'MEC', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000146', universityId: '00000000-0000-0000-0000-000000000002', name: 'Shadan College of Engineering and Technology', code: 'SCOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000147', universityId: '00000000-0000-0000-0000-000000000002', name: 'Islamia College of Engineering and Technology', code: 'ICOEA', district: 'Hyderabad', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000148', universityId: '00000000-0000-0000-0000-000000000002', name: 'Khaja Banda Nawaz College of Engineering', code: 'KBNCO', district: 'Kalaburagi', type: 'Private'),
    // KU
    CollegeModel(id: '00000000-0000-0000-0000-000000000149', universityId: '00000000-0000-0000-0000-000000000003', name: 'KITS Warangal', code: 'KW', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000014a', universityId: '00000000-0000-0000-0000-000000000003', name: 'KU College of Engineering and Technology', code: 'KCOEA', district: 'Warangal', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000014b', universityId: '00000000-0000-0000-0000-000000000003', name: 'KU College of Engineering Kothagudem', code: 'KCOEK', district: 'Bhadradri Kothagudem', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000014c', universityId: '00000000-0000-0000-0000-000000000003', name: 'Vaagdevi Engineering College', code: 'VEC', district: 'Hanamkonda', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000014d', universityId: '00000000-0000-0000-0000-000000000003', name: 'SR Engineering College', code: 'SEC', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000014e', universityId: '00000000-0000-0000-0000-000000000003', name: 'Christu Jyothi Institute of Technology and Science', code: 'CJIOT', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000014f', universityId: '00000000-0000-0000-0000-000000000003', name: 'Warangal Institute of Technology and Science', code: 'WIOTA', district: 'Hanamkonda', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000150', universityId: '00000000-0000-0000-0000-000000000003', name: 'Jayamukhi Institute of Technological Sciences', code: 'JIOTS', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000151', universityId: '00000000-0000-0000-0000-000000000003', name: 'Ganapathy Engineering College', code: 'GEC', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000152', universityId: '00000000-0000-0000-0000-000000000003', name: 'Mother Teresa Institute of Science and Technology', code: 'MTIOS', district: 'Khammam', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000153', universityId: '00000000-0000-0000-0000-000000000003', name: 'Aurum Institute of Technology', code: 'AIOT', district: 'Warangal', type: 'Private'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000154', universityId: '00000000-0000-0000-0000-000000000003', name: 'Vaageshwari Engineering College', code: 'VEC', district: 'Karimnagar', type: 'Private'),
    // RGUKT
    CollegeModel(id: '00000000-0000-0000-0000-000000000155', universityId: '00000000-0000-0000-0000-000000000004', name: 'RGUKT Basar', code: 'RB', district: 'Nirmal', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000156', universityId: '00000000-0000-0000-0000-000000000004', name: 'RGUKT Nuzvid', code: 'RN', district: 'Krishna', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000157', universityId: '00000000-0000-0000-0000-000000000004', name: 'RGUKT RK Valley', code: 'RRV', district: 'Kadapa', type: 'Government'),
    // Govt
    CollegeModel(id: '00000000-0000-0000-0000-000000000158', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Hyderabad', code: 'JCOEH', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000159', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Sultanpur', code: 'JCOES', district: 'Medak', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000015a', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Jagtial', code: 'JCOEJ', district: 'Jagitial', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000015b', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Manthani', code: 'JCOEM', district: 'Peddapalli', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000015c', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Rajanna Sircilla', code: 'JCOER', district: 'Rajanna Sircilla', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000015d', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Wanaparthy', code: 'JCOEW', district: 'Wanaparthy', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000015e', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Mahabubabad', code: 'JCOEM', district: 'Mahabubabad', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000015f', universityId: '00000000-0000-0000-0000-000000000005', name: 'JNTUH College of Engineering Palair', code: 'JCOEP', district: 'Khammam', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000160', universityId: '00000000-0000-0000-0000-000000000005', name: 'Osmania University College of Engineering', code: 'OUCOE', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000161', universityId: '00000000-0000-0000-0000-000000000005', name: 'Osmania University College of Technology', code: 'OUCOT', district: 'Hyderabad', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000162', universityId: '00000000-0000-0000-0000-000000000005', name: 'KU College of Engineering and Technology', code: 'KCOEA', district: 'Warangal', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000163', universityId: '00000000-0000-0000-0000-000000000005', name: 'Government Engineering College Kosgi', code: 'GECK', district: 'Mahabubnagar', type: 'Government'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000164', universityId: '00000000-0000-0000-0000-000000000005', name: 'MGU College of Engineering and Technology', code: 'MCOEA', district: 'Nalgonda', type: 'Government'),
    // National
    CollegeModel(id: '00000000-0000-0000-0000-000000000165', universityId: '00000000-0000-0000-0000-000000000006', name: 'Indian Institute of Technology Hyderabad', code: 'IIOTH', district: 'Sangareddy', type: 'National Institute'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000166', universityId: '00000000-0000-0000-0000-000000000006', name: 'National Institute of Technology Warangal', code: 'NIOTW', district: 'Warangal', type: 'National Institute'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000167', universityId: '00000000-0000-0000-0000-000000000006', name: 'International Institute of Information Technology Hyderabad', code: 'IIOIT', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000168', universityId: '00000000-0000-0000-0000-000000000006', name: 'BITS Pilani Hyderabad Campus', code: 'BPHC', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: '00000000-0000-0000-0000-000000000169', universityId: '00000000-0000-0000-0000-000000000006', name: 'Mahindra University', code: 'MU', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000016a', universityId: '00000000-0000-0000-0000-000000000006', name: 'Woxsen University', code: 'WU', district: 'Sangareddy', type: 'Deemed University'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000016b', universityId: '00000000-0000-0000-0000-000000000006', name: 'Anurag University', code: 'AU', district: 'Hyderabad', type: 'Deemed University'),
    CollegeModel(id: '00000000-0000-0000-0000-00000000016c', universityId: '00000000-0000-0000-0000-000000000006', name: 'ICFAI Tech School', code: 'ITS', district: 'Hyderabad', type: 'Deemed University'),
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
    universityId: '00000000-0000-0000-0000-000000000001',
    collegeId: '00000000-0000-0000-0000-000000000101',
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
      id: '00000000-0000-0000-0000-000000000101',
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
      id: '00000000-0000-0000-0000-000000000102',
      subjectId: 'sub-ds',
      title: 'DS Syllabus Copy',
      contentType: 'syllabus',
      fileUrl:
          'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
      createdAt: DateTime(2024, 7, 15),
    ),
    AcademicContentModel(
      id: '00000000-0000-0000-0000-000000000103',
      subjectId: 'sub-ds',
      title: 'Stacks & Queues Lecture',
      contentType: 'video',
      description: 'Recorded classroom session',
      fileUrl:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      createdAt: DateTime(2024, 9, 1),
    ),
    AcademicContentModel(
      id: '00000000-0000-0000-0000-000000000104',
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
