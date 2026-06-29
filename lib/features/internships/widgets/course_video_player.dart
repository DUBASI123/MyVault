import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/internship_models.dart';

class CourseVideoPlayer extends StatelessWidget {
  final CourseVideo video;

  const CourseVideoPlayer({super.key, required this.video});

  String? _getYouTubeId(String url) {
    try {
      final uri = Uri.parse(url);
      if (uri.host.contains('youtube.com') && uri.queryParameters.containsKey('v')) {
        return uri.queryParameters['v'];
      } else if (uri.host.contains('youtu.be')) {
        return uri.pathSegments.first;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _playVideo(BuildContext context) async {
    final url = Uri.parse(video.videoUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open video URL: ${video.videoUrl}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final youtubeId = _getYouTubeId(video.videoUrl);
    final thumbnailUrl = youtubeId != null
        ? 'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg'
        : (video.thumbnailUrl ?? '');

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: () => _playVideo(context),
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail image
              if (thumbnailUrl.isNotEmpty)
                Image.network(
                  thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.video_library_rounded, size: 64, color: Colors.grey),
                  ),
                )
              else
                Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(Icons.video_library_rounded, size: 64, color: Colors.grey),
                  ),
                ),
              // Play button overlay
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
