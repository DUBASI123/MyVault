import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/uploaded_files_repository.dart';

class UploadedFilesController extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final UploadedFilesRepository _repo;
  UploadedFilesController(this._repo) : super(const AsyncValue.loading()) {
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    state = const AsyncValue.loading();
    try {
      final files = await _repo.getFiles();
      state = AsyncValue.data(files);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchFilesFiltered({String? branch, String? semester}) async {
    state = const AsyncValue.loading();
    try {
      final files = await _repo.getFilesFiltered(branch: branch, semester: semester);
      state = AsyncValue.data(files);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final uploadedFilesProvider =
    StateNotifierProvider<UploadedFilesController, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return UploadedFilesController(UploadedFilesRepository());
});
