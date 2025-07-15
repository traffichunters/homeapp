class ProjectContact {
  final int projectId;
  final int contactId;

  ProjectContact({
    required this.projectId,
    required this.contactId,
  });

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'contact_id': contactId,
    };
  }

  factory ProjectContact.fromMap(Map<String, dynamic> map) {
    return ProjectContact(
      projectId: map['project_id'],
      contactId: map['contact_id'],
    );
  }
}