import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../screens/file_viewer/pdf_viewer_screen.dart';
import '../screens/file_viewer/image_viewer_screen.dart';
import '../utils/file_type_utils.dart';
import 'download_progress_sheet.dart';
import '../core/constants/app_colors.dart';

class FileActionHandler {
  /// Call this when user taps the view/download icon on any file card.
  static Future<void> handleFileTap({
    required BuildContext context,
    required String fileUrl,       // Supabase storage signed URL
    required String fileName,      // e.g. "Unit1_Notes.pdf"
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DownloadProgressSheet(
        url: fileUrl,
        fileName: fileName,
        onOpenFile: (localPath) {
          final viewType = FileTypeUtils.getViewType(fileName);
          if (viewType == FileViewType.pdf) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PdfViewerScreen(filePath: localPath, fileName: fileName),
              ),
            );
          } else if (viewType == FileViewType.image) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageViewerScreen(filePath: localPath, fileName: fileName),
              ),
            );
          } else {
            _openLocalFile(context, localPath);
          }
        },
      ),
    );
  }

  /// Opens any locally downloaded file with the system's default app
  static Future<void> _openLocalFile(BuildContext context, String filePath) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: ${result.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
