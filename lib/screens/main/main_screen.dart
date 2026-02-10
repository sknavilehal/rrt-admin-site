import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../monitor/sos_monitor_screen.dart';
import '../admin/manage_admins_screen.dart';
import '../admin/users_list_screen.dart';

/// Main screen with role-based navigation
class MainScreen extends StatefulWidget {
  final AuthService authService;

  const MainScreen({super.key, required this.authService});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  UserProfile? _userProfile;
  bool _isLoadingProfile = true;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(widget.authService);
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _apiService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProfile = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    await widget.authService.signOut();
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return SOSMonitorScreen(userProfile: _userProfile!);
      case 1:
        return UsersListScreen(
          userProfile: _userProfile!,
          apiService: _apiService,
        );
      case 2:
        return ManageAdminsScreen(
          userProfile: _userProfile!,
          apiService: _apiService,
        );
      default:
        return SOSMonitorScreen(userProfile: _userProfile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Error loading profile'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _logout,
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    final isSuperAdmin = _userProfile!.isSuperAdmin;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(isSuperAdmin),

            // Content
            Expanded(
              child: _getSelectedScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSuperAdmin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogo(),
          Row(
            children: [
              _buildNavButton('MONITOR', 0),
              const SizedBox(width: 16),
              _buildNavButton('USERS', 1),
              const SizedBox(width: 16),
              if (isSuperAdmin) ...[
                _buildNavButton('MANAGE ADMINS', 2),
                const SizedBox(width: 16),
              ],
              const SizedBox(width: 16),
              _buildUserInfo(isSuperAdmin),
              const SizedBox(width: 16),
              _buildLogoutButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.emergency,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapid',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
            Text(
              'Response Team',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.grey.shade600,
                height: 1.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavButton(String label, int index) {
    final isSelected = _selectedIndex == index;
    return TextButton(
      onPressed: () => setState(() => _selectedIndex = index),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey.shade600,
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildUserInfo(bool isSuperAdmin) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _userProfile!.email,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          isSuperAdmin ? 'SUPER ADMIN' : 'ADMIN',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return ElevatedButton(
      onPressed: _logout,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'LOGOUT',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward, size: 16),
        ],
      ),
    );
  }
}
