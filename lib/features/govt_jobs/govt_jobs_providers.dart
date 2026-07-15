import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final govtJobsSearchProvider = StateProvider<String>((ref) => '');
final govtJobsSectorProvider = StateProvider<String>((ref) => 'All');

final govtJobsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final res = await Supabase.instance.client
      .from('active_govt_jobs')
      .select();
  return List<Map<String, dynamic>>.from(res as List);
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
