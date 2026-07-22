import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Watermark Overlay & Water Transparent UI Style Wrapper
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
        // Water transparent gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A0A0F),
                Color(0xFF101222),
                Color(0xFF0A0A0F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Watermark Crest Layer (Background behind text & cards)
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: Opacity(
                opacity: 0.08,
                child: logoUrl != null && logoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: logoUrl!,
                        width: 260,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => _defaultWatermark(),
                      )
                    : _defaultWatermark(),
              ),
            ),
          ),
        ),

        // Foreground content with transparent hit testing
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _defaultWatermark() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 140,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'MYVAULT ACADEMIC',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}
