import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../../features/academic_hub/services/academic_service.dart';

final socketClientProvider = Provider<SocketClient>((ref) {
  final client = SocketClient(ref);
  ref.onDispose(() {
    client.disconnect();
  });
  return client;
});

class SocketClient {
  final Ref _ref;
  RealtimeChannel? _channel;

  SocketClient(this._ref);

  void connect() {
    if (_channel != null) return;

    debugPrint('🔌 Connecting to Supabase Realtime for academic resources changes');

    _channel = SupabaseService.client.channel('public:academic_resources');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'academic_resources',
      callback: (payload) {
        debugPrint('🔔 Real-time database update received: ${payload.toString()}');
        final record = payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
        if (record.containsKey('subject_id')) {
          final subjectId = record['subject_id'] as String?;
          if (subjectId != null) {
            debugPrint('Invalidating subjectContentsProvider for subjectId: $subjectId');
            _ref.invalidate(subjectContentsProvider(subjectId));
          }
        }
      },
    );

    _channel!.subscribe((status, [error]) {
      debugPrint('Realtime channel status: $status');
      if (error != null) {
        debugPrint('Realtime channel error: $error');
      }
    });
  }

  void disconnect() {
    if (_channel != null) {
      SupabaseService.client.removeChannel(_channel!);
      _channel = null;
    }
  }
}
