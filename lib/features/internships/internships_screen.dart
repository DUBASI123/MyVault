import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/app_data_service.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/college_logo_header.dart';
import '../auth/data/auth_repository.dart';

class InternshipsScreen extends ConsumerStatefulWidget {
  const InternshipsScreen({super.key});

  @override
  ConsumerState<InternshipsScreen> createState() => _InternshipsScreenState();
}

class _InternshipsScreenState extends ConsumerState<InternshipsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final student = ref.watch(currentStudentProvider);

    return AppScaffold(
      showAppBar: false,
      body: Column(
        children: [
          CollegeLogoHeader(
            collegeName: student?.collegeName ?? 'Your College',
            studentName: student?.displayName,
            onNotificationTap: () => context.push(AppRoutes.notifications),
          ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Internships', style: AppTextStyles.heading2),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textLight,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'IT Field'),
                    Tab(text: 'Core Field'),
                    Tab(text: 'Prep Videos'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _list('IT'),
                _list('core'),
                _videosList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(String type) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: AppDataService.getInternships(type: type),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Failed to load: ${snap.error}'));
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('No listings yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => _card(items[i]),
        );
      },
    );
  }

  Widget _card(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.internshipDetail, extra: item['id'] as String),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['logo'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item['logo'] as String,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40,
                          height: 40,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(Icons.business, color: AppColors.primary, size: 20),
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['company'] ?? '', style: AppTextStyles.heading3),
                        Text(item['role'] ?? '', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('${item['stipend'] ?? ''} • ${item['duration'] ?? ''}', style: AppTextStyles.bodySmall),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.internshipDetail, extra: item['id'] as String),
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('View Details & Apply'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videosList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _prepVideos.length,
      itemBuilder: (context, i) {
        final video = _prepVideos[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () async {
              final url = Uri.parse(video.youtubeUrl);
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              } catch (_) {}
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      video.thumbnailUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.black12,
                        child: const Icon(Icons.video_library_rounded, size: 48, color: AppColors.textLight),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.duration,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Poppins'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.channel,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'Poppins'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PrepVideo {
  final String title;
  final String channel;
  final String duration;
  final String youtubeUrl;
  final String thumbnailUrl;
  const _PrepVideo(this.title, this.channel, this.duration, this.youtubeUrl, this.thumbnailUrl);
}

const _prepVideos = [
  _PrepVideo(
    'How to Get an Internship with No Experience',
    'Programming with Mosh',
    '12:45',
    'https://www.youtube.com/watch?v=gT8q3Phs-6c',
    'https://img.youtube.com/vi/gT8q3Phs-6c/0.jpg',
  ),
  _PrepVideo(
    'Ace Your Coding Interview: Tips & Tricks',
    'Clever Programmer',
    '18:20',
    'https://www.youtube.com/watch?v=0h5o82-o_U4',
    'https://img.youtube.com/vi/0h5o82-o_U4/0.jpg',
  ),
  _PrepVideo(
    'Write a Killer Resume for Internships',
    'Jeff Su',
    '10:15',
    'https://www.youtube.com/watch?v=uG2aEH56aR4',
    'https://img.youtube.com/vi/uG2aEH56aR4/0.jpg',
  ),
  _PrepVideo(
    'How to Find Remote Internships Globally',
    'Clément Mihailescu',
    '15:30',
    'https://www.youtube.com/watch?v=Vl3l2PqJ-wI',
    'https://img.youtube.com/vi/Vl3l2PqJ-wI/0.jpg',
  ),
];
