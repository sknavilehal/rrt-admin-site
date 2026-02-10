import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/main/main_screen.dart';

/// Wrapper that determines which screen to show based on authentication state
class AuthWrapper extends StatelessWidget {
  final AuthService authService;

  const AuthWrapper({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return MainScreen(authService: authService);
        }

        return LoginScreen(authService: authService);
      },
    );
  }
}
