class Document {
  final int? id;
  final int projectId;
  final String title;
  final String filePath;
  final int fileSize;
  final String fileType;
  final String? thumbnailPath;
  final DateTime uploadDate;

  Document({
    this.id,
    required this.projectId,
    required this.title,
    required this.filePath,
    required this.fileSize,
    required this.fileType,
    this.thumbnailPath,
    required this.uploadDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'file_path': filePath,
      'file_size': fileSize,
      'file_type': fileType,
      'thumbnail_path': thumbnailPath,
      'upload_date': uploadDate.toIso8601String(),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      projectId: map['project_id'],
      title: map['title'],
      filePath: map['file_path'],
      fileSize: map['file_size'],
      fileType: map['file_type'],
      thumbnailPath: map['thumbnail_path'],
      uploadDate: DateTime.parse(map['upload_date']),
    );
  }

  Document copyWith({
    int? id,
    int? projectId,
    String? title,
    String? filePath,
    int? fileSize,
    String? fileType,
    String? thumbnailPath,
    DateTime? uploadDate,
  }) {
    return Document(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      fileType: fileType ?? this.fileType,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      uploadDate: uploadDate ?? this.uploadDate,
    );
  }
}