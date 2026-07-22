import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState
    extends State<NotificationHistoryScreen> {
  final _client = Supabase.instance.client;
  late final _studentId = _client.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    if (_studentId == null) return [];

    final rows = await _client
        .from('notifications')
        .select()
        .or('student_id.eq.$_studentId,is_broadcast.eq.true')
        .order('sent_at', ascending: false)
        .limit(100);

    final reads = await _client
        .from('notification_reads')
        .select('notification_id')
        .eq('student_id', _studentId!);

    final readIds =
        (reads as List).map((r) => r['notification_id'] as String).toSet();

    return (rows as List).map((n) {
      final map = Map<String, dynamic>.from(n as Map);
      map['is_read'] = readIds.contains(map['id']);
      return map;
    }).toList();
  }

  Future<void> _markRead(String notificationId) async {
    if (_studentId == null) return;
    await _client.from('notification_reads').upsert({
      'student_id': _studentId,
      'notification_id': notificationId,
    });
  }

  IconData _iconFor(String category) => switch (category) {
        'academic' => Icons.school_rounded,
        'internship' => Icons.work_outline_rounded,
        'job' => Icons.business_center_outlined,
        'result' => Icons.grade_outlined,
        'course' => Icons.play_circle_outline_rounded,
        'system' => Icons.info_outline_rounded,
        _ => Icons.notifications_none_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1A1A2E),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const Divider(color: Colors.white12, height: 1),
            itemBuilder: (context, index) {
              final n = items[index];
              final isRead = n['is_read'] as bool;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _iconFor(n['category'] as String),
                    color: const Color(0xFF6C63FF),
                    size: 20,
                  ),
                ),
                title: Text(
                  n['title'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isRead ? FontWeight.normal : FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  n['body'] as String,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60),
                ),
                trailing: Text(
                  timeago.format(DateTime.parse(n['sent_at'] as String)),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                onTap: () async {
                  await _markRead(n['id'] as String);
                  final deepLink = n['deep_link'] as String?;
                  if (deepLink != null && context.mounted) {
                    context.push(deepLink);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
