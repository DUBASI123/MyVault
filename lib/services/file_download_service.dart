import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileDownloadService {
  static final FileDownloadService _instance = FileDownloadService._internal();
  factory FileDownloadService() => _instance;
  FileDownloadService._internal();

  final Dio _dio = Dio();

  /// Returns the local saved file path, or throws on error.
  Future<String> downloadFile({
    required String url,
    required String fileName,
    void Function(int received, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // 1. Ensure the filename has an extension (derive from URL if missing)
    final resolvedName = _ensureExtension(fileName, url);

    // 2. Resolve save directory (no MANAGE_EXTERNAL_STORAGE needed)
    final dir = await _getSaveDirectory();
    final savePath = '${dir.path}/$resolvedName';

    // 3. Download with progress
    await _dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        headers: {'Accept': '*/*'},
      ),
    );

    return savePath;
  }

  /// Ensures the fileName has a file extension.
  /// If it doesn't, tries to extract one from the URL.
  String _ensureExtension(String fileName, String url) {
    if (fileName.contains('.')) return fileName;
    try {
      final uri = Uri.parse(url);
      final lastSegment = uri.path.split('/').last.split('?').first;
      if (lastSegment.contains('.')) {
        final ext = lastSegment.split('.').last.toLowerCase();
        return '$fileName.$ext';
      }
    } catch (_) {}
    return '$fileName.pdf'; // default fallback
  }

  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      // Use app-specific external storage — no MANAGE_EXTERNAL_STORAGE needed
      final dirs = await getExternalStorageDirectories();
      final base = dirs?.isNotEmpty == true ? dirs!.first : await getTemporaryDirectory();
      final vaultDir = Directory('${base.path}/MyVault');
      if (!await vaultDir.exists()) await vaultDir.create(recursive: true);
      return vaultDir;
    } else {
      // iOS: app Documents folder
      final dir = await getApplicationDocumentsDirectory();
      final vaultDir = Directory('${dir.path}/MyVault');
      if (!await vaultDir.exists()) await vaultDir.create(recursive: true);
      return vaultDir;
    }
  }

  void cancelDownload(CancelToken token) {
    token.cancel('User cancelled download');
  }
}

