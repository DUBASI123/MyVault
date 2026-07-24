class UploadedFileModel {
  final String id;
  final String title;
  final String fileName;
  final String storagePath;
  final String publicUrl;
  final String fileType;
  final int fileSize;
  final String? uploadedBy;
  final DateTime createdAt;

  UploadedFileModel({
    required this.id,
    required this.title,
    required this.fileName,
    required this.storagePath,
    required this.publicUrl,
    required this.fileType,
    required this.fileSize,
    this.uploadedBy,
    required this.createdAt,
  });

  factory UploadedFileModel.fromMap(Map<String, dynamic> map) {
    return UploadedFileModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Untitled File',
      fileName: map['file_name'] as String? ?? 'file',
      storagePath: map['storage_path'] as String? ?? '',
      publicUrl: map['public_url'] as String? ?? '',
      fileType: (map['file_type'] as String? ?? 'file').toLowerCase(),
      fileSize: map['file_size'] is int
          ? map['file_size'] as int
          : int.tryParse(map['file_size']?.toString() ?? '0') ?? 0,
      uploadedBy: map['uploaded_by'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'file_name': fileName,
      'storage_path': storagePath,
      'public_url': publicUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
