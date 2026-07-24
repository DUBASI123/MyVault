import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final govtJobsSearchProvider = StateProvider<String>((ref) => '');
final govtJobsSectorProvider = StateProvider<String>((ref) => 'All');

final govtJobsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final res = await Supabase.instance.client
        .from('active_govt_jobs')
        .select();
    final list = List<Map<String, dynamic>>.from(res as List);
    if (list.isNotEmpty) return list;
  } catch (_) {}

  try {
    final cmsRes = await Supabase.instance.client
        .from('cms_job_listings')
        .select()
        .eq('category', 'Govt Jobs')
        .eq('active', true)
        .order('created_at', ascending: false);
    return (cmsRes as List).map((e) => {
      'id': e['id'],
      'title': e['title'],
      'organization': e['company_or_dept'],
      'sector': e['sector'],
      'description': e['description'],
      'apply_link': e['apply_link'],
      'deadline': e['deadline'],
    }).toList();
  } catch (_) {}

  return [];
});

final filteredGovtJobsProvider = Provider<AsyncValue<List<Map<String, dynamic>>>>((ref) {
  final jobsAsync = ref.watch(govtJobsProvider);
  final search = ref.watch(govtJobsSearchProvider).toLowerCase();
  final sector = ref.watch(govtJobsSectorProvider);

  return jobsAsync.whenData((list) {
    return list.where((job) {
      final matchesSearch = search.isEmpty ||
          (job['title'] as String? ?? '').toLowerCase().contains(search) ||
          (job['organization'] as String? ?? '').toLowerCase().contains(search) ||
          (job['eligibility'] as String? ?? '').toLowerCase().contains(search);

      final matchesSector = sector == 'All' ||
          (job['sector'] as String? ?? '').toLowerCase() == sector.toLowerCase().replaceAll(' ', '_');

      return matchesSearch && matchesSector;
    }).toList();
  });
});
