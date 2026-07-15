import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class AppDataService {
  AppDataService._();

  static Future<String> getNotificationTicker() async {
    try {
      final items = await SupabaseService.client
          .from('notifications')
          .select('title')
          .order('created_at', ascending: false)
          .limit(5);
      if (items.isNotEmpty) {
        return items.map((n) => '🔔 ${n['title']}').join(' | ');
      }
    } catch (e) {
      debugPrint('Supabase getNotificationTicker error: $e');
    }
    return 'My Vault — student platform';
  }

  static Future<List<Map<String, dynamic>>> getNotifications({String? collegeId}) async {
    try {
      var query = SupabaseService.client.from('notifications').select();
      if (collegeId != null && collegeId.isNotEmpty) {
        query = query.eq('college_id', collegeId);
      }
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Supabase notifications error: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getResults({
    String? branch,
    int? semester,
  }) async {
    try {
      var query = SupabaseService.client.from('exam_results').select();
      if (branch != null) {
        query = query.eq('branch', branch);
      }
      if (semester != null) {
        query = query.eq('semester', semester);
      }
      final response = await query.order('subject', ascending: true);
      return (response as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
        return {
          'subject': m['subject'],
          'code': m['code'],
          'internal': m['internal'],
          'external': m['external'],
          'total': m['total'],
          'max': m['max_marks'] ?? m['maxMarks'] ?? 100,
          'grade': m['grade'],
          'status': m['status'],
        };
      }).toList();
    } catch (e) {
      debugPrint('Supabase results error: $e');
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInternships({
    List<String>? types,
    String? collegeId,
  }) async {
    try {
      var query = SupabaseService.client.from('internships').select();
      if (types != null && types.isNotEmpty) {
        query = query.inFilter('sector', types);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
        return {
          'id': m['id']?.toString(),
          'company': m['company_name'] ?? m['company'],
          'role': m['title'] ?? m['role'],
          'type': m['sector'] ?? m['type'],
          'domain': m['domain'],
          'stipend': m['stipend'],
          'duration': m['duration'],
          'deadline': m['deadline'],
          'applyLink': m['apply_url'] ?? m['applyLink'],
          'logo': m['logo'] ?? '🏢',
          'status': m['is_active'] == false ? 'Closed' : 'Open',
        };
      }).toList();
    } catch (e) {
      debugPrint('Supabase internships error: $e');
    }
    return [];
  }
}

  }
}
