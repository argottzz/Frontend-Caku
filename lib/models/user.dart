import 'json_utils.dart';

enum UserRole {
  admin,
  customer;

  static UserRole fromApi(Object? value) {
    return '$value'.toLowerCase() == 'admin'
        ? UserRole.admin
        : UserRole.customer;
  }

  String get apiValue => name;

  String get label => switch (this) {
    UserRole.admin => 'Admin',
    UserRole.customer => 'Customer',
  };
}

class User {
  const User({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.profileImage,
    this.phoneNumber,
  });

  final int id;
  final String nama;
  final String email;
  final UserRole role;
  final String? profileImage;
  final String? phoneNumber;

  bool get isAdmin => role == UserRole.admin;

  String get initials {
    final parts = nama.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: Json.asInt(json['id'] ?? json['id_user']),
      nama: Json.asString(json['nama']),
      email: Json.asString(json['email']),
      role: UserRole.fromApi(json['role']),
      profileImage: Json.asStringOrNull(json['profile_image']),
      phoneNumber: Json.asStringOrNull(json['phone_number']),
    );
  }
}
