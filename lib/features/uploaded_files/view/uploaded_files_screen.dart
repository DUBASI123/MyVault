import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/uploaded_files_controller.dart';

class UploadedFilesScreen extends ConsumerWidget {
  const UploadedFilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(uploadedFilesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Documents Hub')),
      body: filesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (files) => RefreshIndicator(
          onRefresh: () => ref.read(uploadedFilesProvider.notifier).fetchFiles(),
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
    );
  }
}
