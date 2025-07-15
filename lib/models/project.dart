class Project {
  final int? id;
  final String title;
  final String? description;
  final DateTime createdDate;
  final DateTime updatedDate;
  final String? tags;

  Project({
    this.id,
    required this.title,
    this.description,
    required this.createdDate,
    required this.updatedDate,
    this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_date': createdDate.toIso8601String(),
      'updated_date': updatedDate.toIso8601String(),
      'tags': tags,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdDate: DateTime.parse(map['created_date']),
      updatedDate: DateTime.parse(map['updated_date']),
      tags: map['tags'],
    );
  }

  Project copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? tags,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      tags: tags ?? this.tags,
    );
  }
}