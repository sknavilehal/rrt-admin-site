import '../config/constants.dart';

/// User profile model representing the authenticated user
class UserProfile {
  final String email;
  final String role;
  final List<String> assignedDistricts;
  final bool active;

  UserProfile({
    required this.email,
    required this.role,
    required this.assignedDistricts,
    required this.active,
  });

  bool get isSuperAdmin => role == AppConstants.roleSuperAdmin;
  bool get isAdmin => role == AppConstants.roleAdmin;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? '',
      role: json['role'] ?? AppConstants.roleAdmin,
      assignedDistricts: List<String>.from(json['assignedDistricts'] ?? []),
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'role': role,
      'assignedDistricts': assignedDistricts,
      'active': active,
    };
  }
}
