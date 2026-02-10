/// Application-wide constants
class AppConstants {
  // API Configuration
  static const String apiBaseUrl =
      'https://us-central1-rrt-sos.cloudfunctions.net/api';

  // Districts
  static const List<String> districts = [
    'udupi',
    'mangalore',
    'kasaragod',
    'puttur',
    'bantwal',
  ];

  // App Info
  static const String appTitle = 'Rapid Response Team';
  static const String appSubtitle = 'Admin Portal';
  static const String copyright = '© 2026 RAPID RESPONSE TEAM';

  // Roles
  static const String roleSuperAdmin = 'superadmin';
  static const String roleAdmin = 'admin';
}
