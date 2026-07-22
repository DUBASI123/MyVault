import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';

class TechStackScreen extends StatelessWidget {
  const TechStackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Tech Stack & Architecture',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
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
                  child: Icon(Icons.memory_rounded, color: Colors.white24, size: 90),
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
                  _headerCard().animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 20),

                  // 1. Frontend Technologies
                  _categoryTitle('Frontend Stack', Icons.phone_android_rounded, const Color(0xFF6C63FF)),
                  const SizedBox(height: 10),
                  _techCard([
                    _techTile('Flutter 3.x & Dart', 'Cross-platform native mobile UI framework', Icons.flutter_dash_rounded, const Color(0xFF02569B)),
                    _techTile('Riverpod 2.x', 'Reactive state management & dependency injection', Icons.sync_alt_rounded, const Color(0xFF00C2A8)),
                    _techTile('GoRouter', 'Declarative routing & deep navigation management', Icons.alt_route_rounded, const Color(0xFF9B59B6)),
                    _techTile('Custom UI & Design Tokens', 'Glassmorphism, HSL theme palette, Poppins font', Icons.palette_outlined, const Color(0xFFFF6B6B)),
                  ]).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // 2. Backend & Server
                  _categoryTitle('Backend & Server API', Icons.dns_rounded, const Color(0xFF4F46E5)),
                  const SizedBox(height: 10),
                  _techCard([
                    _techTile('Node.js (ES Modules)', 'Asynchronous JavaScript runtime environment', Icons.code_rounded, const Color(0xFF68A063)),
                    _techTile('Express.js', 'REST API framework handling authentication & routes', Icons.api_rounded, const Color(0xFF333333)),
                    _techTile('Socket.io', 'Real-time WebSocket event broadcasting & live sync', Icons.bolt_rounded, const Color(0xFFFFB020)),
                    _techTile('JWT & BcryptJS', 'Secure token authentication & salted password hashing', Icons.security_rounded, const Color(0xFFE74C3C)),
                  ]).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // 3. Database & Cloud Storage
                  _categoryTitle('Database & Storage', Icons.storage_rounded, const Color(0xFF00C2A8)),
                  const SizedBox(height: 10),
                  _techCard([
                    _techTile('PostgreSQL Database', 'Relational database hosted on Supabase Cloud', Icons.dataset_rounded, const Color(0xFF336791)),
                    _techTile('Prisma ORM v6', 'Type-safe database queries & migration management', Icons.table_chart_rounded, const Color(0xFF2D3748)),
                    _techTile('AWS S3 Bucket', 'Production release APK hosting (myvault-files)', Icons.cloud_done_rounded, const Color(0xFFFF9900)),
                    _techTile('Cloudinary Storage', 'Media CDN for Student ID Cards & Profile Photos', Icons.cloud_upload_rounded, const Color(0xFF3448C5)),
                  ]).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  // 4. REST API Endpoints Overview
                  _categoryTitle('Backend REST API Routes', Icons.hub_rounded, const Color(0xFFE67E22)),
                  const SizedBox(height: 10),
                  _techCard([
                    _apiTile('POST /api/auth/login', 'User authentication & session token generation'),
                    _apiTile('POST /api/auth/register', 'Student registration & Prisma profile creation'),
                    _apiTile('GET /api/academic/subjects', 'Curriculum subjects filtered by branch & sem'),
                    _apiTile('GET /api/content/notifications', 'System alerts & live announcement ticker'),
                    _apiTile('GET /api/master/colleges', 'Master directory lookup for universities & colleges'),
                    _apiTile('GET /api/s3/download/*path', 'Pre-signed S3 download URL generation'),
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

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text(
                'MyVault Tech Stack',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Built with high-performance modern web & mobile technologies, scalable cloud databases, and real-time backend API architecture.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 1.2,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _techCard(List<Widget> children) {
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

  Widget _techTile(String title, String subtitle, IconData icon, Color color) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins'),
          ),
          dense: true,
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }

  Widget _apiTile(String endpoint, String description) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.http_rounded, color: AppColors.primary, size: 18),
          ),
          title: Text(
            endpoint,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: AppColors.primary),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Poppins'),
          ),
          dense: true,
        ),
        const Divider(height: 1, indent: 56),
      ],
    );
  }
}
