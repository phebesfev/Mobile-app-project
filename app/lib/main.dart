import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const QuickScanApp());
}

class QuickScanApp extends StatelessWidget {
  const QuickScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Scan',
      debugShowCheckedModeBanner: false, // 
      theme: AppTheme.lightTheme, // 
      home: const LoginScreen(), 
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
