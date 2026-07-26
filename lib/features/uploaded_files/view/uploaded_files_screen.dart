import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/uploaded_files_controller.dart';

const _branchOptions = ['All', 'CSE', 'ECE', 'MECH', 'CIVIL', 'EEE', 'IT'];
const _semesterOptions = [
  'All', '1yr-1sem', '1yr-2sem', '2yr-1sem', '2yr-2sem',
  '3yr-1sem', '3yr-2sem', '4yr-1sem', '4yr-2sem',
];

class UploadedFilesScreen extends ConsumerStatefulWidget {
  const UploadedFilesScreen({super.key});

  @override
  ConsumerState<UploadedFilesScreen> createState() => _UploadedFilesScreenState();
}

class _UploadedFilesScreenState extends ConsumerState<UploadedFilesScreen> {
  String _branch = 'All';
  String _semester = 'All';

  void _applyFilters() {
    ref.read(uploadedFilesProvider.notifier).fetchFilesFiltered(
          branch: _branch == 'All' ? null : _branch,
          semester: _semester == 'All' ? null : _semester,
        );
  }

  @override
  Widget build(BuildContext context) {
    final filesState = ref.watch(uploadedFilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents Hub')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _branch,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Branch'),
                    items: _branchOptions
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _branch = v ?? 'All');
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _semester,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Semester'),
                    items: _semesterOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _semester = v ?? 'All');
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (files) => RefreshIndicator(
                onRefresh: () async => _applyFilters(),
                child: files.isEmpty
                    ? const Center(child: Text('No files yet'))
                    : ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (_, i) {
                          final file = files[i];
                          final branch = file['branch'] ?? 'General';
                          final semester = file['semester'];
                          return ListTile(
                            leading: const Icon(Icons.insert_drive_file),
                            title: Text(file['file_name'] ?? 'File'),
                            subtitle: Text(
                              '${file['created_at'] != null ? file['created_at'].toString().split('T')[0] : ''}'
                              '${branch != 'General' ? ' · $branch' : ''}'
                              '${semester != null ? ' · $semester' : ''}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () {
                                final url = file['file_url'];
                                if (url != null) {
                                  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
