import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class WatermarkOverlay extends StatelessWidget {
  final Widget child;
  final String? logoUrl;

  const WatermarkOverlay({
    super.key,
    required this.child,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (logoUrl != null && logoUrl!.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Opacity(
                  opacity: 0.07,
                  child: CachedNetworkImage(
                    imageUrl: logoUrl!,
                    width: 220,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
