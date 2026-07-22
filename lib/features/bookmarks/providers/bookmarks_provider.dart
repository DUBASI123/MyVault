import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum BookmarkContentType {
  note,
  video,
  labManual,
  syllabus,
  course,
  internship,
  job,
  govtJob,
  project,
  studyMaterial,
  certificate;

  String get dbValue => switch (this) {
        BookmarkContentType.note => 'note',
        BookmarkContentType.video => 'video',
        BookmarkContentType.labManual => 'lab_manual',
        BookmarkContentType.syllabus => 'syllabus',
        BookmarkContentType.course => 'course',
        BookmarkContentType.internship => 'internship',
        BookmarkContentType.job => 'job',
        BookmarkContentType.govtJob => 'govt_job',
        BookmarkContentType.project => 'project',
        BookmarkContentType.studyMaterial => 'study_material',
        BookmarkContentType.certificate => 'certificate',
      };
}

class Bookmark {
  final String id;
  final String contentType;
  final String contentId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  Bookmark({
    required this.id,
    required this.contentType,
    required this.contentId,
    required this.metadata,
    required this.createdAt,
  });

  factory Bookmark.fromMap(Map<String, dynamic> map) => Bookmark(
        id: map['id'] as String,
        contentType: map['content_type'] as String,
        contentId: map['content_id'] as String,
        metadata: (map['metadata'] as Map?)?.cast<String, dynamic>() ?? {},
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

final _client = Supabase.instance.client;

/// Live stream of the current student's bookmarks, newest first.
final bookmarksStreamProvider = StreamProvider<List<Bookmark>>((ref) {
  final studentId = _client.auth.currentUser?.id;
  if (studentId == null) return const Stream.empty();

  return _client
      .from('bookmarks')
      .stream(primaryKey: ['id'])
      .eq('student_id', studentId)
      .order('created_at', ascending: false)
      .map((rows) => rows.map(Bookmark.fromMap).toList());
});

/// Fast lookup for "is this piece of content bookmarked?"
final isBookmarkedProvider =
    Provider.family<bool, ({BookmarkContentType type, String contentId})>(
        (ref, args) {
  final bookmarks = ref.watch(bookmarksStreamProvider).value ?? [];
  return bookmarks.any((b) =>
      b.contentType == args.type.dbValue && b.contentId == args.contentId);
});

final bookmarksControllerProvider =
    Provider((ref) => BookmarksController(ref));

class BookmarksController {
  BookmarksController(this._ref);
  final Ref _ref;

  Future<void> toggle({
    required BookmarkContentType type,
    required String contentId,
    Map<String, dynamic> metadata = const {},
  }) async {
    final studentId = _client.auth.currentUser?.id;
    if (studentId == null) return;

    final isBookmarked = _ref.read(
      isBookmarkedProvider((type: type, contentId: contentId)),
    );

    if (isBookmarked) {
      await _client
          .from('bookmarks')
          .delete()
          .eq('student_id', studentId)
          .eq('content_type', type.dbValue)
          .eq('content_id', contentId);
    } else {
      await _client.from('bookmarks').insert({
        'student_id': studentId,
        'content_type': type.dbValue,
        'content_id': contentId,
        'metadata': metadata,
      });
    }
  }
}
