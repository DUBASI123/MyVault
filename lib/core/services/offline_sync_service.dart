import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  static const String subjectsBoxName = 'offline_subjects';
  static const String contentsBoxName = 'offline_contents';
  static const String bookmarksBoxName = 'offline_bookmarks';
  static const String syncQueueBoxName = 'offline_sync_queue';

  late Box _subjectsBox;
  late Box _contentsBox;
  late Box _bookmarksBox;
  late Box _syncQueueBox;

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _subjectsBox = await Hive.openBox(subjectsBoxName);
      _contentsBox = await Hive.openBox(contentsBoxName);
      _bookmarksBox = await Hive.openBox(bookmarksBoxName);
      _syncQueueBox = await Hive.openBox(syncQueueBoxName);
      debugPrint('[OfflineSyncService] Initialized Hive boxes successfully');
    } catch (e) {
      debugPrint('[OfflineSyncService] Init error: $e');
    }
  }

  // ─── Subjects Cache ────────────────────────────────────────────────────────
  Future<void> cacheSubjects(String key, List<Map<String, dynamic>> data) async {
    await _subjectsBox.put(key, jsonEncode(data));
  }

  List<Map<String, dynamic>>? getCachedSubjects(String key) {
    final raw = _subjectsBox.get(key);
    if (raw != null) {
      final List list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ─── Contents Cache ────────────────────────────────────────────────────────
  Future<void> cacheContents(String subjectId, List<Map<String, dynamic>> data) async {
    await _contentsBox.put(subjectId, jsonEncode(data));
  }

  List<Map<String, dynamic>>? getCachedContents(String subjectId) {
    final raw = _contentsBox.get(subjectId);
    if (raw != null) {
      final List list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ─── Bookmarks Cache ───────────────────────────────────────────────────────
  Future<void> cacheBookmarks(List<Map<String, dynamic>> bookmarks) async {
    await _bookmarksBox.put('student_bookmarks', jsonEncode(bookmarks));
  }

  List<Map<String, dynamic>>? getCachedBookmarks() {
    final raw = _bookmarksBox.get('student_bookmarks');
    if (raw != null) {
      final List list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ─── Sync Queue for Offline Operations ───────────────────────────────────
  Future<void> queueOfflineAction(String action, Map<String, dynamic> payload) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    await _syncQueueBox.put(id, jsonEncode({'action': action, 'payload': payload}));
  }

  List<Map<String, dynamic>> getPendingQueue() {
    final keys = _syncQueueBox.keys;
    final List<Map<String, dynamic>> items = [];
    for (var key in keys) {
      final raw = _syncQueueBox.get(key);
      if (raw != null) {
        items.add({'queueKey': key, ...Map<String, dynamic>.from(jsonDecode(raw))});
      }
    }
    return items;
  }

  Future<void> removeQueueItem(dynamic key) async {
    await _syncQueueBox.delete(key);
  }
}
