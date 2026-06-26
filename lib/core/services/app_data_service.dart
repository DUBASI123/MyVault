import 'package:flutter/foundation.dart';
import '../config/env_config.dart';
import 'api_client.dart';
import 'supabase_service.dart';

class AppDataService {
  AppDataService._();

  static Future<String> getNotificationTicker() async {
    if (EnvConfig.isBackendConfigured) {
      try {
        final data = await ApiClient.getMap('/content/ticker');
        return data['ticker'] as String? ?? '';
      } catch (_) {}
    }
    if (SupabaseService.isAvailable) {
      try {
        final items = await SupabaseService.client
            .from('notifications')
            .select('title')
            .order('created_at', ascending: false)
            .limit(5);
        if (items.isNotEmpty) {
          return items.map((n) => '🔔 ${n['title']}').join(' | ');
        }
      } catch (_) {}
    }
    return 'My Vault — student platform';
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    if (EnvConfig.isBackendConfigured) {
      try {
        final list = await ApiClient.getList('/content/notifications');
        return list.cast<Map<String, dynamic>>();
      } catch (e) {
        debugPrint('Backend notifications error, falling back to Supabase: $e');
      }
    }
    if (SupabaseService.isAvailable) {
      try {
        final response = await SupabaseService.client
            .from('notifications')
            .select()
            .order('created_at', ascending: false);
        return List<Map<String, dynamic>>.from(response);
      } catch (e) {
        debugPrint('Supabase notifications error: $e');
      }
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getResults({
    String? branch,
    int? semester,
  }) async {
    if (EnvConfig.isBackendConfigured) {
      try {
        final list = await ApiClient.getList('/content/results', query: {
          if (branch != null) 'branch': branch,
          if (semester != null) 'semester': semester,
        });
        return list.map((e) {
          final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
          return {
            'subject': m['subject'],
            'code': m['code'],
            'internal': m['internal'],
            'external': m['external'],
            'total': m['total'],
            'max': m['maxMarks'] ?? m['max_marks'] ?? 100,
            'grade': m['grade'],
            'status': m['status'],
          };
        }).toList();
      } catch (e) {
        debugPrint('Backend results error, falling back to Supabase: $e');
      }
    }
    if (SupabaseService.isAvailable) {
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
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getInternships({String? type}) async {
    if (EnvConfig.isBackendConfigured) {
      try {
        final list = await ApiClient.getList('/content/internships', query: {
          if (type != null) 'type': type,
        });
        return list.map((e) {
          final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
          return {
            'id': m['id']?.toString(),
            'company': m['company'],
            'role': m['role'],
            'type': m['type'],
            'domain': m['domain'],
            'stipend': m['stipend'],
            'duration': m['duration'],
            'deadline': m['deadline'],
            'applyLink': m['applyLink'] ?? m['apply_link'],
            'logo': m['logo'],
            'status': m['status'],
          };
        }).toList();
      } catch (e) {
        debugPrint('Backend internships error, falling back to Supabase: $e');
      }
    }
    if (SupabaseService.isAvailable) {
      try {
        var query = SupabaseService.client.from('internships').select();
        if (type != null) {
          query = query.eq('type', type);
        }
        final response = await query.order('created_at', ascending: false);
        return (response as List).map((e) {
          final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
          return {
            'id': m['id']?.toString(),
            'company': m['company'],
            'role': m['role'],
            'type': m['type'],
            'domain': m['domain'],
            'stipend': m['stipend'],
            'duration': m['duration'],
            'deadline': m['deadline'],
            'applyLink': m['apply_link'] ?? m['applyLink'],
            'logo': m['logo'],
            'status': m['status'],
          };
        }).toList();
      } catch (e) {
        debugPrint('Supabase internships error: $e');
      }
    }
    return [];
  }
}
