import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// In-app PDF preview sheet — used for notes, syllabus, marksheets,
/// certificates, etc. Opens as a bottom sheet or full page depending on
/// [asBottomSheet]; falls back to a retry state on load failure instead
/// of leaving the user on a blank screen.
class PdfPreviewWidget extends StatefulWidget {
  const PdfPreviewWidget({
    super.key,
    required this.url,
    required this.title,
    this.asBottomSheet = false,
  });

  final String url;
  final String title;
  final bool asBottomSheet;

  static Future<void> show(
    BuildContext context, {
    required String url,
    required String title,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.92,
        child: PdfPreviewWidget(url: url, title: title, asBottomSheet: true),
      ),
    );
  }

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  final _controller = PdfViewerController();
  bool _hasError = false;
  bool _isLoading = true;

  void _retry() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final body = _hasError
        ? _ErrorState(onRetry: _retry)
        : Stack(
            children: [
              SfPdfViewer.network(
                widget.url,
                controller: _controller,
                onDocumentLoadFailed: (details) {
                  setState(() {
                    _hasError = true;
                    _isLoading = false;
                  });
                },
                onDocumentLoaded: (details) {
                  setState(() => _isLoading = false);
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
                ),
            ],
          );

    if (!widget.asBottomSheet) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: const Color(0xFF1A1A2E),
        ),
        body: body,
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.picture_as_pdf_outlined,
              size: 48, color: Colors.white38),
          const SizedBox(height: 12),
          const Text(
            "Couldn't load this document",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }
}
