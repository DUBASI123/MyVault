import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';

// ─── Live Notification Ticker ─────────────────────────────────────────────────
// A horizontally scrolling banner that shows live notifications/announcements

final liveNotificationsProvider = StateProvider<List<_TickerItem>>((ref) => [
  _TickerItem('📢 Results for Semester 4 are now live! Check your scores in Results Hub.', AppColors.results),
  _TickerItem('🎓 New study materials uploaded for CSE Semester 3 subjects.', AppColors.academicHub),
  _TickerItem('💼 Campus placement drive by TCS on July 15th. Register before July 10th!', AppColors.internships),
  _TickerItem('📋 Mid-semester exams scheduled from July 20th to July 28th.', AppColors.warning),
  _TickerItem('🏆 Project Expo 2026 registrations open. Submit by July 5th!', AppColors.projects),
  _TickerItem('📱 MyVault app updated with new features. Check Documents Hub!', AppColors.primary),
]);

class _TickerItem {
  final String message;
  final Color color;
  _TickerItem(this.message, this.color);
}

class LiveNotificationTicker extends ConsumerStatefulWidget {
  const LiveNotificationTicker({super.key});

  @override
  ConsumerState<LiveNotificationTicker> createState() => _LiveNotificationTickerState();
}

class _LiveNotificationTickerState extends ConsumerState<LiveNotificationTicker> {
  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) _cycleNotification();
  }

  void _cycleNotification() async {
    while (mounted) {
      if (!_paused) {
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted) break;
        final notifications = ref.read(liveNotificationsProvider);
        setState(() {
          _currentIndex = (_currentIndex + 1) % notifications.length;
        });
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(liveNotificationsProvider);
    if (notifications.isEmpty) return const SizedBox.shrink();

    final item = notifications[_currentIndex % notifications.length];

    return GestureDetector(
      onTap: () => setState(() => _paused = !_paused),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: FadeTransition(opacity: anim, child: child),
        ),
        child: Container(
          key: ValueKey(_currentIndex),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: item.color.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.campaign_rounded, color: item.color, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.message,
                  style: TextStyle(
                    fontSize: 11,
                    color: item.color,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              if (_paused)
                Icon(Icons.pause_circle_outline_rounded, color: item.color, size: 14)
              else
                Icon(Icons.play_circle_outline_rounded, color: item.color.withValues(alpha: 0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
