import '../config/env_config.dart';
import 'api_client.dart';

class AppDataService {
  AppDataService._();

  static Future<String> getNotificationTicker() async {
    if (!EnvConfig.isBackendConfigured) {
      return 'Connect backend for live notifications';
    }
    try {
      final data = await ApiClient.getMap('/content/ticker');
      return data['ticker'] as String? ?? '';
    } catch (_) {
      return 'My Vault — student platform';
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    if (!EnvConfig.isBackendConfigured) return [];
    final list = await ApiClient.getList('/content/notifications');
    return list.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>> getResults({
    String? branch,
    int? semester,
  }) async {
    if (!EnvConfig.isBackendConfigured) return [];
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
  }

  static Future<List<Map<String, dynamic>>> getInternships({String? type}) async {
    if (!EnvConfig.isBackendConfigured) return [];
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
  }
}
