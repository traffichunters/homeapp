class Contact {
  final int? id;
  final String firstName;
  final String lastName;
  final String? companyName;
  final String? email;
  final String? phoneNumber;
  final String? url;
  final DateTime createdDate;

  Contact({
    this.id,
    required this.firstName,
    required this.lastName,
    this.companyName,
    this.email,
    this.phoneNumber,
    this.url,
    required this.createdDate,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'company_name': companyName,
      'email': email,
      'phone_number': phoneNumber,
      'url': url,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      companyName: map['company_name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      url: map['url'],
      createdDate: DateTime.parse(map['created_date']),
    );
  }

  Contact copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? companyName,
    String? email,
    String? phoneNumber,
    String? url,
    DateTime? createdDate,
  }) {
    return Contact(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      url: url ?? this.url,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}