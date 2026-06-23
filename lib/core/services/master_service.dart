import 'supabase_service.dart';
import '../../shared/models/college_model.dart';
import '../../shared/models/university_model.dart';

class MasterService {
  MasterService._();

  static Future<List<UniversityModel>> getUniversities() async {
    try {
      final response = await SupabaseService.client
          .from('universities')
          .select();
      return (response as List)
          .map((e) => UniversityModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<CollegeModel>> getColleges(String universityId) async {
    if (universityId.isEmpty) return [];
    try {
      final response = await SupabaseService.client
          .from('colleges')
          .select()
          .eq('university_id', universityId);
      return (response as List)
          .map((e) => CollegeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<CollegeModel>> getCollegesByUniversityName(
    String universityName,
    List<UniversityModel> universities,
  ) async {
    UniversityModel? uni;
    for (final u in universities) {
      if (u.name == universityName) {
        uni = u;
        break;
      }
    }
    if (uni == null) return [];
    return getColleges(uni.id);
  }
}
