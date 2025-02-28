class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? role;
  final String? organization;
  final DateTime? createdAt;
  final DateTime? lastSignIn;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.role,
    this.organization,
    this.createdAt,
    this.lastSignIn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      organization: json['organization'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      lastSignIn:
          json['last_sign_in'] != null
              ? DateTime.parse(json['last_sign_in'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'organization': organization,
      'created_at': createdAt?.toIso8601String(),
      'last_sign_in': lastSignIn?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? organization,
    DateTime? createdAt,
    DateTime? lastSignIn,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }
}
