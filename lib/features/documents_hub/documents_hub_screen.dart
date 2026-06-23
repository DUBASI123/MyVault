import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_scaffold.dart';


// ─── Document Model ──────────────────────────────────────────────────────────

class DocumentModel {
  final String id;
  final String name;
  final String category;
  final String filePath;
  final String fileSize;
  final DateTime addedAt;
  final String? description;

  DocumentModel({
    required this.id,
    required this.name,
    required this.category,
    required this.filePath,
    required this.fileSize,
    required this.addedAt,
    this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'filePath': filePath,
    'fileSize': fileSize,
    'addedAt': addedAt.toIso8601String(),
    'description': description,
  };

  factory DocumentModel.fromJson(Map<String, dynamic> j) => DocumentModel(
    id: j['id'] as String,
    name: j['name'] as String,
    category: j['category'] as String,
    filePath: j['filePath'] as String,
    fileSize: j['fileSize'] as String,
    addedAt: DateTime.parse(j['addedAt'] as String),
    description: j['description'] as String?,
  );
}

// ─── Documents Provider ──────────────────────────────────────────────────────

final documentsProvider = StateNotifierProvider<DocumentsNotifier, List<DocumentModel>>((ref) {
  return DocumentsNotifier();
});

class DocumentsNotifier extends StateNotifier<List<DocumentModel>> {
  DocumentsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('documents_hub_data');
    if (raw != null) {
      final list = (jsonDecode(raw) as List).map((e) => DocumentModel.fromJson(e as Map<String, dynamic>)).toList();
      state = list;
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('documents_hub_data', jsonEncode(state.map((d) => d.toJson()).toList()));
  }

  Future<void> addDocument(DocumentModel doc) async {
    state = [...state, doc];
    await _save();
  }

  Future<void> removeDocument(String id) async {
    state = state.where((d) => d.id != id).toList();
    await _save();
  }
}

// ─── Categories ──────────────────────────────────────────────────────────────

const _categories = [
  _DocCategory('All', Icons.folder_open_rounded, AppColors.primary),
  _DocCategory('Certificates', Icons.workspace_premium_rounded, AppColors.certificates),
  _DocCategory('ID Cards', Icons.badge_rounded, AppColors.info),
  _DocCategory('Academic Papers', Icons.article_rounded, AppColors.academicHub),
  _DocCategory('Marksheets', Icons.grade_rounded, AppColors.results),
  _DocCategory('Bonafide', Icons.verified_rounded, AppColors.success),
  _DocCategory('Others', Icons.more_horiz_rounded, AppColors.textSecondary),
];

class _DocCategory {
  final String name;
  final IconData icon;
  final Color color;
  const _DocCategory(this.name, this.icon, this.color);
}

// ─── Screen ──────────────────────────────────────────────────────────────────

class DocumentsHubScreen extends ConsumerStatefulWidget {
  const DocumentsHubScreen({super.key});

  @override
  ConsumerState<DocumentsHubScreen> createState() => _DocumentsHubScreenState();
}

class _DocumentsHubScreenState extends ConsumerState<DocumentsHubScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndAddDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final size = file.size;
    final sizeStr = size > 1024 * 1024
        ? '${(size / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(size / 1024).toStringAsFixed(0)} KB';

    // Ask for category
    final category = await _showCategoryPicker();
    if (category == null) return;

    final doc = DocumentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: file.name,
      category: category,
      filePath: file.path ?? '',
      fileSize: sizeStr,
      addedAt: DateTime.now(),
    );
    await ref.read(documentsProvider.notifier).addDocument(doc);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${file.name} added to Documents Hub'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<String?> _showCategoryPicker() async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ..._categories.where((c) => c.name != 'All').map((c) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: c.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(c.icon, color: c.color, size: 20),
              ),
              title: Text(c.name, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500)),
              onTap: () => Navigator.pop(ctx, c.name),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(DocumentModel doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Document'),
        content: Text('Remove "${doc.name}" from Documents Hub?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(documentsProvider.notifier).removeDocument(doc.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allDocs = ref.watch(documentsProvider);

    final filtered = allDocs.where((d) {
      final matchCat = _selectedCategory == 'All' || d.category == _selectedCategory;
      final matchQ = _searchQuery.isEmpty || d.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchQ;
    }).toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));

    final catCounts = <String, int>{'All': allDocs.length};
    for (final c in _categories.where((c) => c.name != 'All')) {
      catCounts[c.name] = allDocs.where((d) => d.category == c.name).length;
    }

    return AppScaffold(
      showAppBar: false,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickAndAddDocument,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Document', style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.certificates, Color(0xFFD4520C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Documents Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${allDocs.length} files',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: const InputDecoration(
                      hintText: 'Search documents...',
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      hintStyle: TextStyle(fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category tabs ─────────────────────────────────────────────────
          Container(
            height: 48,
            color: AppColors.surface,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = _selectedCategory == cat.name;
                final count = catCounts[cat.name] ?? 0;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat.name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? cat.color : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? cat.color : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                        const SizedBox(width: 4),
                        Text(
                          '${cat.name} ($count)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ── Documents list ────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      return _documentCard(filtered[i], i).animate(
                        delay: Duration(milliseconds: i * 50),
                      ).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.certificates.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, size: 60, color: AppColors.certificates),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Documents Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add\ncertificates, ID cards, or any documents',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', fontSize: 13),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _documentCard(DocumentModel doc, int index) {
    final cat = _categories.firstWhere(
      (c) => c.name == doc.category,
      orElse: () => _categories.last,
    );
    final isImage = doc.filePath.toLowerCase().endsWith('.jpg') ||
        doc.filePath.toLowerCase().endsWith('.jpeg') ||
        doc.filePath.toLowerCase().endsWith('.png');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: cat.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: isImage && doc.filePath.isNotEmpty && File(doc.filePath).existsSync()
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(doc.filePath), fit: BoxFit.cover),
                )
              : Icon(_fileIcon(doc.name), color: cat.color, size: 24),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(doc.category, style: TextStyle(fontSize: 10, color: cat.color, fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                ),
                const SizedBox(width: 6),
                Text(doc.fileSize, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'Poppins')),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('d MMM yyyy, hh:mm a').format(doc.addedAt),
              style: const TextStyle(fontSize: 10, color: AppColors.textLight, fontFamily: 'Poppins'),
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () => _confirmDelete(doc),
          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
        ),
        isThreeLine: true,
      ),
    );
  }

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf_rounded;
      case 'jpg': case 'jpeg': case 'png': return Icons.image_rounded;
      case 'doc': case 'docx': return Icons.description_rounded;
      case 'txt': return Icons.text_snippet_rounded;
      default: return Icons.insert_drive_file_rounded;
    }
  }
}
