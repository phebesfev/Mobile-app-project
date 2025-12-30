import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/scan/edit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDXssIZd3_LhRbmcqgOcaTWtG--ECF4WqA",
        authDomain: "quick-scanner-27853.firebaseapp.com",
        projectId: "quick-scanner-27853",
        storageBucket: "quick-scanner-27853.appspot.com",
        messagingSenderId: "331380527736",
        appId: "1:331380527736:web:85259d7d5bbaa322ea138d",
        measurementId: "G-930MJL5P8G",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
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
        '/scan': (context) => const ScanScreen(),
        '/edit': (context) => const EditDocumentPage(),
      },
    );
  }
}
