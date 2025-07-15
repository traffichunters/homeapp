class Activity {
  final int? id;
  final int projectId;
  final DateTime date;
  final String activity;
  final DateTime createdDate;

  Activity({
    this.id,
    required this.projectId,
    required this.date,
    required this.activity,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'date': date.toIso8601String(),
      'activity': activity,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      projectId: map['project_id'],
      date: DateTime.parse(map['date']),
      activity: map['activity'],
      createdDate: DateTime.parse(map['created_date']),
    );
  }

  Activity copyWith({
    int? id,
    int? projectId,
    DateTime? date,
    String? activity,
    DateTime? createdDate,
  }) {
    return Activity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      date: date ?? this.date,
      activity: activity ?? this.activity,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}