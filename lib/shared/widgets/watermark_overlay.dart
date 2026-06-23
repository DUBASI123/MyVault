import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';

/// Semi-transparent institute logo watermark (Figma spec: ~0.08 opacity).
class WatermarkOverlay extends ConsumerWidget {
  final Widget child;
  final double opacity;

  const WatermarkOverlay({
    super.key,
    required this.child,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoUrl = ref.watch(currentStudentProvider)?.collegeLogoUrl;

    return Stack(
      children: [
        child,
        if (logoUrl != null && logoUrl.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: opacity,
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    width: 220,
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => const SizedBox.shrink(),),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
