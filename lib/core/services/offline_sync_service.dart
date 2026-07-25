import 'dart:convert';
import 'package:flutter/foundation.dart';

class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  final Map<String, String> _subjectsBox = {};
  final Map<String, String> _contentsBox = {};
  final Map<String, String> _bookmarksBox = {};
  final Map<String, String> _syncQueueBox = {};

  Future<void> init() async {
    debugPrint('[OfflineSyncService] Initialized in-memory mock boxes successfully');
  }

  // ─── Subjects Cache ────────────────────────────────────────────────────────
  Future<void> cacheSubjects(String key, List<Map<String, dynamic>> data) async {
    _subjectsBox[key] = jsonEncode(data);
  }

  List<Map<String, dynamic>>? getCachedSubjects(String key) {
    final raw = _subjectsBox[key];
    if (raw != null) {
      final List list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ─── Contents Cache ────────────────────────────────────────────────────────
  Future<void> cacheContents(String subjectId, List<Map<String, dynamic>> data) async {
    _contentsBox[subjectId] = jsonEncode(data);
  }

  List<Map<String, dynamic>>? getCachedContents(String subjectId) {
    final raw = _contentsBox[subjectId];
    if (raw != null) {
      final List list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ─── Bookmarks Cache ───────────────────────────────────────────────────────
  Future<void> cacheBookmarks(List<Map<String, dynamic>> bookmarks) async {
    _bookmarksBox['student_bookmarks'] = jsonEncode(bookmarks);
  }

  List<Map<String, dynamic>>? getCachedBookmarks() {
    final raw = _bookmarksBox['student_bookmarks'];
    if (raw != null) {
      final List list = jsonDecode(raw);
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  // ─── Sync Queue for Offline Operations ───────────────────────────────────
  Future<void> queueOfflineAction(String action, Map<String, dynamic> payload) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _syncQueueBox[id] = jsonEncode({'action': action, 'payload': payload});
  }

  List<Map<String, dynamic>> getPendingQueue() {
    final keys = _syncQueueBox.keys;
    final List<Map<String, dynamic>> items = [];
    for (var key in keys) {
      final raw = _syncQueueBox[key];
      if (raw != null) {
        items.add({'queueKey': key, ...Map<String, dynamic>.from(jsonDecode(raw))});
      }
    }
    return items;
  }

  Future<void> removeQueueItem(dynamic key) async {
    _syncQueueBox.remove(key.toString());
  }
}
