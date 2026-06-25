import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/models/student_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

class AdminRepository {
  AdminRepository();

  SupabaseClient get _db => SupabaseService.client;

  /// Watch pending students for a specific college
  Stream<List<StudentModel>> watchPendingStudents(String collegeId) {
    return _db
        .from('students')
        .stream(primaryKey: ['id'])
        .eq('college_id', collegeId)
        .map((list) => list
            .map((e) => StudentModel.fromMap(e))
            .where((student) => student.verificationStatus == 'Pending')
            .toList());
  }

  /// Approve a student registration
  Future<void> approveStudent(String studentId) async {
    await _db.from('students').update({
      'is_verified': true,
      'verification_status': 'Approved',
      'rejection_reason': null,
    }).eq('id', studentId);
  }

  /// Reject a student registration with a reason
  Future<void> rejectStudent(String studentId, String reason) async {
    await _db.from('students').update({
      'is_verified': false,
      'verification_status': 'Rejected',
      'rejection_reason': reason,
    }).eq('id', studentId);
  }
}
