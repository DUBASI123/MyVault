import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/file_download_service.dart';
import '../utils/file_type_utils.dart';
import '../core/constants/app_colors.dart';

class DownloadProgressSheet extends StatefulWidget {
  final String url;
  final String fileName;
  final VoidCallback? onDownloadComplete;
  final void Function(String filePath)? onOpenFile;

  const DownloadProgressSheet({
    super.key,
    required this.url,
    required this.fileName,
    this.onDownloadComplete,
    this.onOpenFile,
  });

  @override
  State<DownloadProgressSheet> createState() => _DownloadProgressSheetState();
}

class _DownloadProgressSheetState extends State<DownloadProgressSheet> {
  final _service = FileDownloadService();
  late CancelToken _cancelToken;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  String _status = 'Starting download...';
  bool _isDone = false;
  bool _hasError = false;
  String? _savedPath;

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
    _startDownload();
  }

  Future<void> _startDownload() async {
    try {
      setState(() => _status = 'Downloading...');
      final path = await _service.downloadFile(
        url: widget.url,
        fileName: widget.fileName,
        cancelToken: _cancelToken,
        onProgress: (received, total) {
          if (total <= 0) return;
          setState(() {
            _receivedBytes = received;
            _totalBytes = total;
            _progress = received / total;
            _status =
                '${FileTypeUtils.getReadableSize(received)} / ${FileTypeUtils.getReadableSize(total)}';
          });
        },
      );
      setState(() {
        _isDone = true;
        _savedPath = path;
        _status = 'Saved to Cache Directory';
      });
      widget.onDownloadComplete?.call();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        if (mounted) Navigator.pop(context);
        return;
      }
      setState(() {
        _hasError = true;
        _status = 'Download failed. Tap to retry.';
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _status = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.textLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // File icon + name
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    FileTypeUtils.getFileIcon(widget.fileName),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _hasError ? AppColors.error : AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress bar
          if (!_isDone && !_hasError) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                backgroundColor: AppColors.inputFill,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _service.cancelDownload(_cancelToken);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded, color: AppColors.error),
              label: const Text('Cancel', style: TextStyle(color: AppColors.error, fontFamily: 'Poppins')),
            ),
          ],

          // Done state
          if (_isDone) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
                  SizedBox(width: 8),
                  Text('Download complete!',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Close', style: TextStyle(fontFamily: 'Poppins')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onOpenFile?.call(_savedPath!);
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open File', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Error state
          if (_hasError) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _progress = 0;
                  _status = 'Retrying...';
                  _cancelToken = CancelToken();
                });
                _startDownload();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
