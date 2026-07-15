import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Static content that doesn't rotate: Recorded Videos, Study Material,
/// Previous Papers, Cheat Sheets. Quiz and Mock Test are handled by the
/// rotation providers below instead.
final examStaticContentProvider = FutureProvider.family<
    List<Map<String, dynamic>>, ({String examId, String contentType})>(
  (ref, args) async {
    final res = await Supabase.instance.client
        .from('exam_content')
        .select()
        .eq('exam_id', args.examId)
        .eq('content_type', args.contentType)
        .eq('is_active', true)
        .order('created_at');
    return List<Map<String, dynamic>>.from(res as List);
  },
);

/// Today's quiz for a given exam — rotates day-to-day.
/// Reads from the `today_quiz` SQL view, which computes the correct
/// rotation_index server-side using (current_date - quiz_rotation_start) % cycle_length.
final todaysQuizProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, examId) async {
  final res = await Supabase.instance.client
      .from('today_quiz')
      .select()
      .eq('exam_id', examId)
      .maybeSingle();
  return res;
});

/// This month's mock test for a given exam — rotates month-to-month.
/// Reads from the `this_month_mock` SQL view.
final thisMonthMockProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, examId) async {
  final res = await Supabase.instance.client
      .from('this_month_mock')
      .select()
      .eq('exam_id', examId)
      .maybeSingle();
  return res;
});

/// Full quiz history for an exam (so students can revisit past days'
/// quizzes, not just today's), ordered by rotation_index.
final quizArchiveProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, examId) async {
  final res = await Supabase.instance.client
      .from('exam_content')
      .select()
      .eq('exam_id', examId)
      .eq('content_type', 'quiz')
      .eq('is_active', true)
      .order('rotation_index');
  return List<Map<String, dynamic>>.from(res as List);
});

/// Full mock test archive for an exam, ordered by rotation_index.
final mockTestArchiveProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, examId) async {
  final res = await Supabase.instance.client
      .from('exam_content')
      .select()
      .eq('exam_id', examId)
      .eq('content_type', 'mock_test')
      .eq('is_active', true)
      .order('rotation_index');
  return List<Map<String, dynamic>>.from(res as List);
});
