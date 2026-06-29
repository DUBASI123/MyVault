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
    // 1. Request storage permission (Android <= 12)
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkVersion();
      if (sdkInt <= 32) {
        final status = await Permission.storage.request();
        if (!status.isGranted) throw Exception('Storage permission denied');
      }
    }

    // 2. Resolve save directory
    final dir = await _getSaveDirectory();
    final savePath = '${dir.path}/$fileName';

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

  Future<Directory> _getSaveDirectory() async {
    if (Platform.isAndroid) {
      // Save to cache directory on Android to avoid legacy storage issues
      final dir = await getTemporaryDirectory();
      final vaultDir = Directory('${dir.path}/MyVault');
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

  Future<int> _getAndroidSdkVersion() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return int.tryParse(result.stdout.toString().trim()) ?? 33;
    } catch (_) {
      return 33;
    }
  }

  void cancelDownload(CancelToken token) {
    token.cancel('User cancelled download');
  }
}
