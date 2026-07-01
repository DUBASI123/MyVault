import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';

// ─── Notification Model ────────────────────────────────────────────────────────

class _NotifItem {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? link;
  final DateTime createdAt;

  const _NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.link,
    required this.createdAt,
  });

  factory _NotifItem.fromMap(Map<String, dynamic> m) {
    return _NotifItem(
      id: m['id']?.toString() ?? '',
      title: m['title'] as String? ?? '',
      body: m['body'] as String? ?? '',
      type: (m['type'] as String? ?? 'general').toLowerCase(),
      link: m['link'] as String?,
      createdAt: m['created_at'] != null
          ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────────
  List<_NotifItem> _notifications = [];
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'All';
  final Set<String> _readIds = {};

  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _bellController;
  late final Animation<double> _bellRotation;
  late final AnimationController _headerFadeController;
  late final Animation<double> _headerFade;

  static const List<String> _filters = [
    'All',
    'Exam',
    'Internship',
    'Project',
    'Academic',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _bellController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bellRotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.15), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.1), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _bellController, curve: Curves.easeInOut));

    _headerFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _headerFade =
        CurvedAnimation(parent: _headerFadeController, curve: Curves.easeOut);
    _headerFadeController.forward();

    _fetchNotifications();
  }

  @override
  void dispose() {
    _bellController.dispose();
    _headerFadeController.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  Future<void> _fetchNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final student = ref.read(currentStudentProvider);
      List<dynamic> res;

      if (student?.collegeId != null && student!.collegeId.isNotEmpty) {
        res = await Supabase.instance.client
            .from('notifications')
            .select()
            .or('college_id.eq.${student.collegeId},college_id.is.null')
            .order('created_at', ascending: false);
      } else {
        res = await Supabase.instance.client
            .from('notifications')
            .select()
            .order('created_at', ascending: false);
      }

      final items = res
          .map((m) => _NotifItem.fromMap(m as Map<String, dynamic>))
          .toList();

      if (mounted) {
        setState(() {
          _notifications = items;
          _loading = false;
        });
        if (_unreadCount > 0) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) _bellController.forward(from: 0);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  int get _unreadCount =>
      _notifications.where((n) => !_readIds.contains(n.id)).length;

  List<_NotifItem> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    return _notifications
        .where((n) => n.type == _selectedFilter.toLowerCase())
        .toList();
  }

  void _markAsRead(String id) {
    if (!_readIds.contains(id)) {
      setState(() => _readIds.add(id));
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (final n in _notifications) {
        _readIds.add(n.id);
      }
    });
  }

  void _navigateForLink(String? link) {
    if (link == null || link.isEmpty) return;
    final path = link.trim().toLowerCase();
    if (path == '/results' || path.startsWith('/results')) {
      context.push(AppRoutes.results);
    } else if (path == '/internships' || path.startsWith('/internships')) {
      context.push(AppRoutes.internships);
    } else if (path == '/projects' || path.startsWith('/projects')) {
      context.push(AppRoutes.projects);
    } else if (path == '/academic-hub' || path.startsWith('/academic-hub')) {
      context.push(AppRoutes.academicHub);
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  // ── Type meta ──────────────────────────────────────────────────────────────

  Color _typeColor(String type) {
    switch (type) {
      case 'exam':
        return AppColors.warning;
      case 'internship':
        return AppColors.success;
      case 'project':
        return AppColors.projects;
      case 'academic':
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'exam':
        return Icons.edit_note_rounded;
      case 'internship':
        return Icons.work_outline_rounded;
      case 'project':
        return Icons.rocket_launch_rounded;
      case 'academic':
        return Icons.menu_book_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'exam':
        return 'Exam';
      case 'internship':
        return 'Internship';
      case 'project':
        return 'Project';
      case 'academic':
        return 'Academic';
      default:
        return 'General';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    final unread = _unreadCount;

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            showNotification: false,
          ),
          _buildHeader(unread),
          _buildFilterChips(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.notifications,
              backgroundColor: AppColors.surface,
              onRefresh: _fetchNotifications,
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header with animated bell ──────────────────────────────────────────────

  Widget _buildHeader(int unread) {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Animated bell + badge
            GestureDetector(
              onTap: () {
                _bellController.forward(from: 0);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _bellRotation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _bellRotation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.notifications.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: AppColors.notifications,
                        size: 26,
                      ),
                    ),
                  ),
                  if (unread > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : unread.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications', style: AppTextStyles.heading2),
                  Text(
                    unread > 0
                        ? '$unread unread notification${unread == 1 ? '' : 's'}'
                        : 'All caught up!',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            // Mark all as read button
            if (_notifications.isNotEmpty && unread > 0)
              TextButton.icon(
                onPressed: _markAllAsRead,
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text(
                  'Mark all',
                  style: TextStyle(fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.notifications,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final filter = _filters[i];
            final isSelected = _selectedFilter == filter;
            final chipColor = filter == 'All'
                ? AppColors.notifications
                : _typeColor(filter.toLowerCase());
            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? chipColor
                      : chipColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? chipColor
                        : chipColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : chipColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.notifications,
                    backgroundColor:
                        AppColors.notifications.withValues(alpha: 0.15),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Loading notifications\u2026',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.error,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _error!.length > 80
                        ? '${_error!.substring(0, 80)}\u2026'
                        : _error!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: _fetchNotifications,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('Try again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.notifications,
                      side: const BorderSide(color: AppColors.notifications),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final filtered = _filteredNotifications;

    if (filtered.isEmpty) {
      return ListView(
        children: [_buildEmptyState()],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _NotifCard(
          item: item,
          isRead: _readIds.contains(item.id),
          typeColor: _typeColor(item.type),
          typeIcon: _typeIcon(item.type),
          typeLabel: _typeLabel(item.type),
          relativeTime: _relativeTime(item.createdAt),
          animationIndex: index,
          onTap: () {
            _markAsRead(item.id);
            _navigateForLink(item.link);
          },
        );
      },
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isFiltered = _selectedFilter != 'All';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.notifications.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.notifications.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.notifications.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: AppColors.notifications,
                  size: 34,
                ),
              ),
              Positioned(
                top: 8,
                right: 12,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.success,
                    size: 14,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 14,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppColors.warning,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            isFiltered
                ? 'No $_selectedFilter notifications'
                : 'No notifications yet',
            style: AppTextStyles.heading3
                .copyWith(color: AppColors.textPrimary, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            isFiltered
                ? 'There are no notifications in this category right now. Try another filter or check back later.'
                : "You're all caught up! New notifications from your college will appear here.",
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          if (isFiltered) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => setState(() => _selectedFilter = 'All'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.notifications,
                side: const BorderSide(color: AppColors.notifications),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
              child: const Text('Show all notifications'),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Notification Card ────────────────────────────────────────────────────────

class _NotifCard extends StatefulWidget {
  final _NotifItem item;
  final bool isRead;
  final Color typeColor;
  final IconData typeIcon;
  final String typeLabel;
  final String relativeTime;
  final int animationIndex;
  final VoidCallback onTap;

  const _NotifCard({
    required this.item,
    required this.isRead,
    required this.typeColor,
    required this.typeIcon,
    required this.typeLabel,
    required this.relativeTime,
    required this.animationIndex,
    required this.onTap,
  });

  @override
  State<_NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<_NotifCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: 40 * widget.animationIndex), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.typeColor;
    final isRead = widget.isRead;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              splashColor: color.withValues(alpha: 0.08),
              highlightColor: color.withValues(alpha: 0.04),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  color: isRead
                      ? AppColors.surface
                      : color.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isRead
                        ? AppColors.border
                        : color.withValues(alpha: 0.25),
                    width: isRead ? 1 : 1.5,
                  ),
                  boxShadow: isRead
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left colored border stripe
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 4,
                        decoration: BoxDecoration(
                          color: isRead
                              ? color.withValues(alpha: 0.35)
                              : color,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      // Content
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon circle
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  widget.typeIcon,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Text column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Type badge + time row
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                color.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            widget.typeLabel.toUpperCase(),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          widget.relativeTime,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                            color: AppColors.textLight,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    // Title
                                    Text(
                                      widget.item.title,
                                      style: AppTextStyles.label.copyWith(
                                        fontWeight: isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                        color: isRead
                                            ? AppColors.textSecondary
                                            : AppColors.textPrimary,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    // Body
                                    Text(
                                      widget.item.body,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isRead
                                            ? AppColors.textLight
                                            : AppColors.textSecondary,
                                        height: 1.45,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    // Link indicator
                                    if (widget.item.link != null &&
                                        widget.item.link!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            size: 11,
                                            color:
                                                color.withValues(alpha: 0.8),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tap to view \u2192',
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              // Unread indicator dot
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 2),
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 300),
                                    width: isRead ? 0 : 8,
                                    height: isRead ? 0 : 8,
                                    decoration: const BoxDecoration(
                                      color: AppColors.info,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
