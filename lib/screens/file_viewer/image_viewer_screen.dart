import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ImageViewerScreen extends StatefulWidget {
  final String? filePath;
  final String? url;
  final String fileName;

  const ImageViewerScreen({
    super.key,
    this.filePath,
    this.url,
    required this.fileName,
  }) : assert(filePath != null || url != null);

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.fileName,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map_rounded, color: Colors.white),
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          child: widget.filePath != null
              ? Image.file(File(widget.filePath!))
              : Image.network(
                  widget.url!,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      color: AppColors.primary,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
