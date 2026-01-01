import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/home/initial_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/scan/edit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
     
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: dotenv.env['FIREBASE_API_KEY']!,
          authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
          projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
          storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
          messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
          appId: dotenv.env['FIREBASE_APP_ID']!,
          measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const QuickScanApp());
}

class QuickScanApp extends StatelessWidget {
  const QuickScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Scan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitialScreen(),
        '/home': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/edit': (context) => const EditDocumentPage(),
      },
    );
  }
}
