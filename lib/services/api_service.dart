import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/user_profile.dart';
import '../models/admin.dart';
import 'auth_service.dart';

/// Service for handling API calls to the backend
class ApiService {
  final AuthService _authService;

  ApiService(this._authService);

  /// Get common headers with authentication token
  Future<Map<String, String>> _getHeaders() async {
    final idToken = await _authService.getIdToken();
    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
  }

  /// Get the current user's profile
  Future<UserProfile> getUserProfile() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/admin/profile'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserProfile.fromJson(data['user']);
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  /// Get list of all admins (Super Admin only)
  Future<List<Admin>> getAdmins() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}/admin/admins'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['admins'] as List)
          .map((a) => Admin.fromJson(a))
          .toList();
    } else {
      throw Exception('Failed to load admins: ${response.statusCode}');
    }
  }

  /// Create a new admin (Super Admin only)
  Future<void> createAdmin({
    required String email,
    required String password,
    required List<String> assignedDistricts,
  }) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/admin/admins'),
      headers: headers,
      body: json.encode({
        'email': email,
        'password': password,
        'assignedDistricts': assignedDistricts,
      }),
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to create admin');
    }
  }

  /// Delete an admin (Super Admin only)
  Future<void> deleteAdmin(String email) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${AppConstants.apiBaseUrl}/admin/admins/$email'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to delete admin');
    }
  }
}
