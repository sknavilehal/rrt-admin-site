import '../config/constants.dart';

/// Admin model for managing admin users
class Admin {
  final String email;
  final String role;
  final List<String> assignedDistricts;
  final bool active;
  final String? createdAt;
  final String? createdBy;

  Admin({
    required this.email,
    required this.role,
    required this.assignedDistricts,
    required this.active,
    this.createdAt,
    this.createdBy,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      email: json['email'] ?? '',
      role: json['role'] ?? AppConstants.roleAdmin,
      assignedDistricts: List<String>.from(json['assignedDistricts'] ?? []),
      active: json['active'] ?? false,
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'assignedDistricts': assignedDistricts,
      'active': active,
      if (createdAt != null) 'createdAt': createdAt,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }
}
