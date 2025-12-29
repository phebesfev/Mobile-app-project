import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/home/initial_screen.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const QuickScanApp());
}

class QuickScanApp extends StatelessWidget {
  const QuickScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Scan',
      debugShowCheckedModeBanner: false, // Removes the "Debug" banner
      theme: AppTheme.lightTheme, // Apply our custom professional theme
      // home: const LoginScreen(),// Start at Login for now
      // home: const InitialScreen(),
      home: const HomeScreen(),
    );
  }
}
