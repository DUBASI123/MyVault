import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/bookmarks_provider.dart';

/// Drop-in bookmark toggle for any content card (notes, courses,
/// internships, jobs, etc). Filled accent icon when saved, outline
/// otherwise, with a subtle scale animation on tap.
class BookmarkButton extends ConsumerStatefulWidget {
  const BookmarkButton({
    super.key,
    required this.contentType,
    required this.contentId,
    this.metadata = const {},
    this.size = 22,
  });

  final BookmarkContentType contentType;
  final String contentId;
  final Map<String, dynamic> metadata;
  final double size;

  @override
  ConsumerState<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends ConsumerState<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    lowerBound: 0.85,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.reverse();
    await _controller.forward();
    await ref.read(bookmarksControllerProvider).toggle(
          type: widget.contentType,
          contentId: widget.contentId,
          metadata: widget.metadata,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = ref.watch(isBookmarkedProvider(
      (type: widget.contentType, contentId: widget.contentId),
    ));

    return ScaleTransition(
      scale: _controller,
      child: IconButton(
        splashRadius: widget.size,
        visualDensity: VisualDensity.compact,
        onPressed: _handleTap,
        icon: Icon(
          isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          size: widget.size,
          color: isBookmarked
              ? const Color(0xFF6C63FF)
              : Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }
}
