import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/router/app_router.dart';
import '../../core/services/cloudinary_service.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../../shared/widgets/otp_verification_badge.dart';
import '../auth/data/auth_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploading = false;

  Future<void> _pickAndUploadPhoto() async {
    setState(() => _uploading = true);
    try {
      final student = ref.read(currentStudentProvider);
      if (student == null) return;
      final url = await CloudinaryService.uploadProfileImage(student.id);
      if (url != null && mounted) {
        // Refresh student profile from Supabase to get new pic URL
        await ref.read(currentStudentProvider.notifier).load();
        _snack('Profile photo updated');
      }
    } catch (e) {
      _snack('Upload failed: $e', error: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmLogout() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);
    if (student == null) {
      return AppScaffold(
        showAppBar: false,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle_outlined, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              const Text('Please log in to view your profile'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    final initials = student.firstName.isNotEmpty
        ? student.firstName[0].toUpperCase()
        : 'S';

    return AppScaffold(
      showAppBar: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CollegeLogoHeader(
              collegeName: student.collegeName,
              studentName: student.displayName,
              onNotificationTap: () => context.push(AppRoutes.notifications),
            ),

            // ── Profile card ────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, Color(0xFF4F46E5)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with upload button
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: student.profilePicUrl != null
                            ? CachedNetworkImageProvider(student.profilePicUrl!)
                            : null,
                        child: student.profilePicUrl == null
                            ? Text(initials, style: const TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                      ),
                      GestureDetector(
                        onTap: _uploading ? null : _pickAndUploadPhoto,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary, width: 2),
                          ),
                          child: _uploading
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    student.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.hallTicket,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _chip(Icons.school_outlined, student.branch),
                      const SizedBox(width: 8),
                      _chip(Icons.calendar_today_outlined, 'Year ${student.yearOfStudy}'),
                      const SizedBox(width: 8),
                      _chip(Icons.layers_outlined, 'Sem ${student.semester}'),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // ── Personal info ────────────────────────────────────────────────
            _section(
              'Personal Information',
              Icons.person_outlined,
              [
                _tile(Icons.email_outlined, 'Email', student.email, verified: student.isEmailVerified),
                _tile(Icons.phone_outlined, 'Mobile', student.mobile, verified: student.isMobileVerified),
                _tile(Icons.badge_outlined, 'Aadhaar Name', student.fullNameAadhar),
                _tile(Icons.wc_outlined, 'Gender', student.gender.isNotEmpty ? student.gender : '—'),
                _tile(Icons.location_on_outlined, 'State', student.state.isNotEmpty ? student.state : '—'),
              ],
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // ── Academic info ────────────────────────────────────────────────
            _section(
              'Academic Information',
              Icons.school_outlined,
              [
                _tile(Icons.account_balance_outlined, 'University', student.universityName),
                _tile(Icons.business_outlined, 'College', student.collegeName),
                _tile(Icons.menu_book_outlined, 'Course', student.course),
                _tile(Icons.device_hub_outlined, 'Branch', student.branch),
                _tile(Icons.layers_outlined, 'Semester', 'Semester ${student.semester}'),
                _tile(Icons.calendar_today_outlined, 'Year of Study', 'Year ${student.yearOfStudy}'),
                if (student.passingYear != null)
                  _tile(Icons.flag_outlined, 'Passing Year', student.passingYear.toString()),
              ],
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // ── Quick Links ──────────────────────────────────────────────────
            _section(
              'Quick Access',
              Icons.apps_outlined,
              [
                _navTile(Icons.workspace_premium_outlined, 'My Certificates', AppColors.academicHub, () => context.push(AppRoutes.certificates)),
                _navTile(Icons.folder_rounded, 'Documents Hub', AppColors.certificates, () => context.push(AppRoutes.documentsHub)),
                _navTile(Icons.work_outline_rounded, 'Internships', AppColors.internships, () => context.push(AppRoutes.internships)),
                _navTile(Icons.emoji_events_outlined, 'Competitive Exams', AppColors.compExams, () => context.push(AppRoutes.competitiveExams)),
                _navTile(Icons.folder_special_outlined, 'My Projects', AppColors.projects, () => context.push(AppRoutes.projects)),
                _navTile(Icons.settings_rounded, 'Settings', AppColors.textSecondary, () => context.push(AppRoutes.settings)),
              ],
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 12),

            // ── Logout ───────────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                ),
                title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                subtitle: const Text('Sign out of your account', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                onTap: _confirmLogout,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Poppins')),
        ],
      ),
    );
  }

  Widget _section(String title, IconData icon, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title, style: AppTextStyles.heading3),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value, {bool? verified}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(label, style: AppTextStyles.bodySmall),
      subtitle: Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      trailing: verified == null
          ? null
          : OtpVerificationBadge(
              status: verified ? OtpBadgeStatus.verified : OtpBadgeStatus.pending,
            ),
      dense: true,
    );
  }

  Widget _navTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
      dense: true,
    );
  }
}
