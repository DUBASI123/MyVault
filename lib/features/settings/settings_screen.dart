import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../auth/data/auth_repository.dart';

// ─── Providers ────────────────────────────────────────────────────────────────
final notificationsEnabledProvider = StateProvider<bool>((ref) => true);
final liveTickerEnabledProvider = StateProvider<bool>((ref) => true);
final darkModeProvider = StateProvider<bool>((ref) => false);
final downloadWifiOnlyProvider = StateProvider<bool>((ref) => true);
final showBatchWatermarkProvider = StateProvider<bool>((ref) => true);

// Hub-specific toggles
final academicHubEnabledProvider = StateProvider<bool>((ref) => true);
final resultsHubEnabledProvider = StateProvider<bool>((ref) => true);
final internshipsHubEnabledProvider = StateProvider<bool>((ref) => true);
final projectsHubEnabledProvider = StateProvider<bool>((ref) => true);
final competitiveExamsHubEnabledProvider = StateProvider<bool>((ref) => true);
final documentsHubEnabledProvider = StateProvider<bool>((ref) => true);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);

    return AppScaffold(
      showAppBar: false,
      body: CustomScrollView(
        slivers: [
          // ── Custom App Bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.settings_rounded, color: Colors.white30, size: 80),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Account section ─────────────────────────────────────
                  if (student != null)
                    _accountCard(student).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── App Preferences ──────────────────────────────────────
                  _sectionHeader('App Preferences', Icons.tune_rounded),
                  const SizedBox(height: 10),
                  _settingsCard([
                    _switchTile(
                      icon: Icons.notifications_active_rounded,
                      iconColor: AppColors.notifications,
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts for updates',
                      provider: notificationsEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.campaign_rounded,
                      iconColor: AppColors.info,
                      title: 'Live Notification Ticker',
                      subtitle: 'Scrolling announcements on home',
                      provider: liveTickerEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.water_drop_rounded,
                      iconColor: AppColors.primary,
                      title: 'College Watermark',
                      subtitle: 'Show college logo watermark',
                      provider: showBatchWatermarkProvider,
                    ),
                    _switchTile(
                      icon: Icons.wifi_rounded,
                      iconColor: AppColors.success,
                      title: 'Download on Wi-Fi Only',
                      subtitle: 'Save mobile data',
                      provider: downloadWifiOnlyProvider,
                    ),
                  ]).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Hub Settings ─────────────────────────────────────────
                  _sectionHeader('Hub Visibility', Icons.hub_rounded),
                  const SizedBox(height: 10),
                  _settingsCard([
                    _switchTile(
                      icon: Icons.menu_book_rounded,
                      iconColor: AppColors.academicHub,
                      title: 'Academic Hub',
                      subtitle: 'Study materials, subjects, notes',
                      provider: academicHubEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.bar_chart_rounded,
                      iconColor: AppColors.results,
                      title: 'Results Hub',
                      subtitle: 'Exam results and grades',
                      provider: resultsHubEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.work_rounded,
                      iconColor: AppColors.internships,
                      title: 'Internships Hub',
                      subtitle: 'Internship listings and applications',
                      provider: internshipsHubEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.code_rounded,
                      iconColor: AppColors.projects,
                      title: 'Projects Hub',
                      subtitle: 'Student project submissions',
                      provider: projectsHubEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.emoji_events_rounded,
                      iconColor: AppColors.compExams,
                      title: 'Competitive Exams',
                      subtitle: 'Exam prep and mock tests',
                      provider: competitiveExamsHubEnabledProvider,
                    ),
                    _switchTile(
                      icon: Icons.folder_rounded,
                      iconColor: AppColors.certificates,
                      title: 'Documents Hub',
                      subtitle: 'Personal document storage',
                      provider: documentsHubEnabledProvider,
                      isLast: true,
                    ),
                  ]).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── About ────────────────────────────────────────────────
                  _sectionHeader('About', Icons.info_outline_rounded),
                  const SizedBox(height: 10),
                  _settingsCard([
                    _infoTile(Icons.app_shortcut_rounded, AppColors.primary, 'App Version', '1.0.0'),
                    _infoTile(Icons.business_rounded, AppColors.info, 'Organization', student?.collegeName ?? 'MyVault'),
                    _infoTile(Icons.badge_rounded, AppColors.academicHub, 'Student ID', student?.hallTicket ?? '—'),
                    _navTile(
                      icon: Icons.privacy_tip_outlined,
                      color: AppColors.textSecondary,
                      title: 'Privacy Policy',
                      onTap: () {},
                      isLast: true,
                    ),
                  ]).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // ── Danger zone ──────────────────────────────────────────
                  _settingsCard([
                    _navTile(
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Logout', style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && mounted) {
                          await ref.read(currentStudentProvider.notifier).logout();
                          if (mounted) context.go(AppRoutes.login);
                        }
                      },
                      isLast: true,
                    ),
                  ]).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _accountCard(dynamic student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: student.profilePicUrl != null ? NetworkImage(student.profilePicUrl!) : null,
            child: student.profilePicUrl == null
                ? Text(
                    student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'S',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  student.email,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontFamily: 'Poppins'),
                ),
                Text(
                  '${student.branch} • ${student.collegeName}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontFamily: 'Poppins'),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.profile),
            icon: const Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required StateProvider<bool> provider,
    bool isLast = false,
  }) {
    final value = ref.watch(provider);
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')),
          trailing: Switch.adaptive(
            value: value,
            onChanged: (v) => ref.read(provider.notifier).state = v,
            activeColor: AppColors.primary,
          ),
          dense: true,
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _infoTile(IconData icon, Color color, String label, String value) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Poppins')),
          trailing: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
          dense: true,
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _navTile({
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color == AppColors.error ? AppColors.error : AppColors.textPrimary, fontFamily: 'Poppins'),
          ),
          subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins')) : null,
          trailing: Icon(Icons.chevron_right_rounded, color: color == AppColors.error ? AppColors.error.withValues(alpha: 0.5) : AppColors.textSecondary),
          onTap: onTap,
          dense: true,
        ),
        if (!isLast) const Divider(height: 1, indent: 56),
      ],
    );
  }
}
