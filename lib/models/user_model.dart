// lib/models/user_model.dart

class UserModel {
  final int id;
  final String role;
  final String? image; // Nullable as per response
  final String name;
  final String? phoneNumber;
  final String? address;
  final String? gender;
  final String? pob; // place of birth
  final DateTime? dob; // date of birth
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.role,
    this.image,
    required this.name,
    this.phoneNumber,
    this.address,
    this.gender,
    this.pob,
    this.dob,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      role: json['role'] as String,
      image: json['image'] as String?,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      pob: json['pob'] as String?,
      dob:
          json['dob'] == null ? null : DateTime.tryParse(json['dob'] as String),
      email: json['email'] as String,
      emailVerifiedAt:
          json['email_verified_at'] == null
              ? null
              : DateTime.tryParse(json['email_verified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'image': image,
      'name': name,
      'phone_number': phoneNumber,
      'address': address,
      'gender': gender,
      'pob': pob,
      'dob': dob?.toIso8601String(),
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
