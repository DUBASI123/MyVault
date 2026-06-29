import 'package:flutter/material.dart';
import '../models/internship_models.dart';
import '../widgets/course_video_player.dart';

class CourseDetailScreen extends StatefulWidget {
  final InternshipCourse course;
  final StudentCourseProgress initialProgress;

  /// Called whenever the student toggles a video's completed state.
  /// Wire this to your backend/repository to persist the change.
  final Future<void> Function(String videoId, bool completed) onToggleVideo;

  /// Called when the student taps "Take Test" after finishing all videos.
  final VoidCallback? onTakeTest;

  /// Internships that become visible once this course is completed
  /// (matched via [InternshipOpportunity.relatedCourseId] or
  /// [InternshipOpportunity.preferredCourseIds]).
  final List<InternshipOpportunity> unlockedOpportunities;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.initialProgress,
    required this.onToggleVideo,
    this.onTakeTest,
    this.unlockedOpportunities = const [],
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late StudentCourseProgress _progress;
  final Set<String> _pendingToggles = {};

  @override
  void initState() {
    super.initState();
    _progress = widget.initialProgress;
  }

  int get _totalVideos => widget.course.computedTotalVideos;

  List<String> get _allVideoIds => widget.course.sections
      .expand((s) => s.videos)
      .map((v) => v.id)
      .toList();

  bool get _allVideosDone => _progress.allVideosCompleted(_allVideoIds);

  Future<void> _openVideo(CourseVideo video) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _VideoPlaybackScreen(video: video)),
    );
    // Offer to mark as watched after returning from playback, rather than
    // auto-completing on tap — confirmation keeps progress data honest.
    if (!mounted) return;
    final alreadyDone = _progress.completedVideoIds.contains(video.id);
    if (alreadyDone) return;

    final shouldMark = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as watched?'),
        content: Text('Mark "${video.title}" as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Mark complete'),
          ),
        ],
      ),
    );
    if (shouldMark == true) {
      await _toggleVideo(video);
    }
  }

  Future<void> _toggleVideo(CourseVideo video) async {
    final currentlyDone = _progress.completedVideoIds.contains(video.id);
    final nextDone = !currentlyDone;

    setState(() {
      _pendingToggles.add(video.id);
      final updated = Set<String>.from(_progress.completedVideoIds);
      nextDone ? updated.add(video.id) : updated.remove(video.id);
      _progress = StudentCourseProgress(
        id: _progress.id,
        studentId: _progress.studentId,
        courseId: _progress.courseId,
        completedVideoIds: updated,
        submittedAssignmentIds: _progress.submittedAssignmentIds,
        status: _progress.status,
        testScore: _progress.testScore,
        testMaxScore: _progress.testMaxScore,
        testPassed: _progress.testPassed,
        certificateId: _progress.certificateId,
        enrolledAt: _progress.enrolledAt,
        completedAt: _progress.completedAt,
        certifiedAt: _progress.certifiedAt,
      );
    });

    try {
      await widget.onToggleVideo(video.id, nextDone);
    } catch (_) {
      // Revert on failure so the UI doesn't drift from the backend.
      if (!mounted) return;
      setState(() {
        final reverted = Set<String>.from(_progress.completedVideoIds);
        currentlyDone ? reverted.add(video.id) : reverted.remove(video.id);
        _progress = StudentCourseProgress(
          id: _progress.id,
          studentId: _progress.studentId,
          courseId: _progress.courseId,
          completedVideoIds: reverted,
          submittedAssignmentIds: _progress.submittedAssignmentIds,
          status: _progress.status,
          testScore: _progress.testScore,
          testMaxScore: _progress.testMaxScore,
          testPassed: _progress.testPassed,
          certificateId: _progress.certificateId,
          enrolledAt: _progress.enrolledAt,
          completedAt: _progress.completedAt,
          certifiedAt: _progress.certifiedAt,
        );
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update progress. Try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _pendingToggles.remove(video.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final percent = _progress.videoProgressPercent(_totalVideos);

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _CourseHeader(course: course, progressPercent: percent),
          const SizedBox(height: 20),
          ...course.sections
              .asMap()
              .entries
              .map((entry) => _SectionCard(
                    index: entry.key + 1,
                    section: entry.value,
                    completedVideoIds: _progress.completedVideoIds,
                    submittedAssignmentIds: _progress.submittedAssignmentIds,
                    pendingToggles: _pendingToggles,
                    onOpenVideo: _openVideo,
                  )),
          const SizedBox(height: 12),
          if (_allVideosDone) _TestUnlockCard(onTakeTest: widget.onTakeTest),
          if (widget.unlockedOpportunities.isNotEmpty &&
              _progress.status == CourseStatus.certified)
            _OpportunitiesUnlockedCard(
                opportunities: widget.unlockedOpportunities),
        ],
      ),
    );
  }
}

class _CourseHeader extends StatelessWidget {
  final InternshipCourse course;
  final double progressPercent;

  const _CourseHeader({required this.course, required this.progressPercent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.subtitle, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (progressPercent / 100).clamp(0.0, 1.0),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${progressPercent.round()}%',
                    style: theme.textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(label: Text(course.category)),
                Chip(label: Text(course.difficulty.name)),
                Chip(label: Text('${course.totalVideos} videos')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final int index;
  final CourseSection section;
  final Set<String> completedVideoIds;
  final Set<String> submittedAssignmentIds;
  final Set<String> pendingToggles;
  final Future<void> Function(CourseVideo) onOpenVideo;

  const _SectionCard({
    required this.index,
    required this.section,
    required this.completedVideoIds,
    required this.submittedAssignmentIds,
    required this.pendingToggles,
    required this.onOpenVideo,
  });

  @override
  Widget build(BuildContext context) {
    final doneCount =
        section.videos.where((v) => completedVideoIds.contains(v.id)).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text('$index. ${section.title}'),
        subtitle: Text('$doneCount/${section.videos.length} videos complete'),
        children: [
          ...section.videos.map((video) => _VideoTile(
                video: video,
                isCompleted: completedVideoIds.contains(video.id),
                isPending: pendingToggles.contains(video.id),
                onTap: () => onOpenVideo(video),
              )),
          ...section.assignments.map((a) => _AssignmentTile(
                assignment: a,
                isSubmitted: submittedAssignmentIds.contains(a.id),
              )),
        ],
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final CourseVideo video;
  final bool isCompleted;
  final bool isPending;
  final VoidCallback onTap;

  const _VideoTile({
    required this.video,
    required this.isCompleted,
    required this.isPending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: isPending
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              isCompleted ? Icons.check_circle : Icons.play_circle_outline,
              color: isCompleted ? Colors.green : null,
            ),
      title: Text(video.title),
      subtitle: Text(video.formattedDuration),
      trailing: video.isPreview ? const Chip(label: Text('Preview')) : null,
      onTap: isPending ? null : onTap,
    );
  }
}

class _VideoPlaybackScreen extends StatelessWidget {
  final CourseVideo video;

  const _VideoPlaybackScreen({required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(video.title)),
      body: Column(
        children: [
          CourseVideoPlayer(video: video),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              video.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final CourseAssignment assignment;
  final bool isSubmitted;

  const _AssignmentTile({required this.assignment, required this.isSubmitted});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        isSubmitted ? Icons.assignment_turned_in : Icons.assignment_outlined,
        color: isSubmitted ? Colors.green : null,
      ),
      title: Text(assignment.title),
      subtitle: Text(isSubmitted ? 'Submitted' : 'Not submitted'),
    );
  }
}

class _TestUnlockCard extends StatelessWidget {
  final VoidCallback? onTakeTest;

  const _TestUnlockCard({required this.onTakeTest});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.quiz_outlined),
        title: const Text('All videos complete — ready for the test'),
        subtitle: const Text('Pass the test to earn your certificate'),
        trailing: FilledButton(
          onPressed: onTakeTest,
          child: const Text('Take Test'),
        ),
      ),
    );
  }
}

class _OpportunitiesUnlockedCard extends StatelessWidget {
  final List<InternshipOpportunity> opportunities;

  const _OpportunitiesUnlockedCard({required this.opportunities});

  @override
  Widget build(BuildContext context) {
    final active = opportunities.where((o) => !o.isExpired()).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Opportunities unlocked',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...active.map((o) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.work_outline),
                  title: Text('${o.role} — ${o.companyName}'),
                  subtitle: Text('${o.duration} · ${o.stipend}'),
                )),
          ],
        ),
      ),
    );
  }
}
