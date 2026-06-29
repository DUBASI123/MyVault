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
    final viewType = FileTypeUtils.getViewType(fileName);

    switch (viewType) {
      case FileViewType.pdf:
        // Stream PDF directly in-app — no download needed first
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(url: fileUrl, fileName: fileName),
          ),
        );
        break;

      case FileViewType.image:
        // Show image in-app full-screen viewer
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImageViewerScreen(url: fileUrl, fileName: fileName),
          ),
        );
        break;

      case FileViewType.other:
        // Show download sheet for DOCX/XLSX/PPT/ZIP etc.
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => DownloadProgressSheet(
            url: fileUrl,
            fileName: fileName,
            onOpenFile: (localPath) => _openLocalFile(context, localPath),
          ),
        );
        break;
    }
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
