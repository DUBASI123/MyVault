import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/constants/app_colors.dart';

class PdfViewerScreen extends StatefulWidget {
  /// Pass either [filePath] (local file) or [url] (remote Supabase URL)
  final String? filePath;
  final String? url;
  final String fileName;

  const PdfViewerScreen({
    super.key,
    this.filePath,
    this.url,
    required this.fileName,
  }) : assert(filePath != null || url != null);

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int _totalPages = 0;
  bool _showToolbar = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _showToolbar ? _buildAppBar() : null,
      body: GestureDetector(
        onTap: () => setState(() => _showToolbar = !_showToolbar),
        child: _buildPdfView(),
      ),
      bottomNavigationBar: _showToolbar ? _buildPageIndicator() : null,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.fileName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (_totalPages > 0)
            Text(
              'Page $_currentPage of $_totalPages',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins'),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.zoom_in_rounded, color: Colors.white),
          onPressed: () => _controller.zoomLevel += 0.25,
        ),
        IconButton(
          icon: const Icon(Icons.zoom_out_rounded, color: Colors.white),
          onPressed: () {
            if (_controller.zoomLevel > 1.0) _controller.zoomLevel -= 0.25;
          },
        ),
        IconButton(
          icon: const Icon(Icons.fit_screen_rounded, color: Colors.white),
          onPressed: () => _controller.zoomLevel = 1.0,
        ),
      ],
    );
  }

  Widget _buildPdfView() {
    if (widget.filePath != null) {
      return SfPdfViewer.file(
        File(widget.filePath!),
        controller: _controller,
        onPageChanged: (details) => setState(() {
          _currentPage = details.newPageNumber;
        }),
        onDocumentLoaded: (details) => setState(() {
          _totalPages = details.document.pages.count;
        }),
        onDocumentLoadFailed: (details) => _buildError(details.error),
      );
    }
    return SfPdfViewer.network(
      widget.url!,
      controller: _controller,
      onPageChanged: (details) => setState(() {
        _currentPage = details.newPageNumber;
      }),
      onDocumentLoaded: (details) => setState(() {
        _totalPages = details.document.pages.count;
      }),
      onDocumentLoadFailed: (details) => _buildError(details.error),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Failed to load PDF',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
          Text(error, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    if (_totalPages == 0) return const SizedBox.shrink();
    return Container(
      height: 48,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
            onPressed: _currentPage > 1
                ? () => _controller.previousPage()
                : null,
          ),
          Text(
            '$_currentPage / $_totalPages',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white),
            onPressed: _currentPage < _totalPages
                ? () => _controller.nextPage()
                : null,
          ),
        ],
      ),
    );
  }
}
