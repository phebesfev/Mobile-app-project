import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _checkAuthState() {
    try {
      // Wait longer before checking, so initial screen shows first
      Future.delayed(Duration(seconds: 2), () {
        if (!mounted) return;
        
        // Only navigate to home if user is logged in AND email is verified
        final user = _authService.currentUser;
        if (user != null && user.emailVerified) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });

      // Listen for auth state changes (only navigate if verified)
      _authSubscription = _authService.authStateChanges.listen(
        (User? user) {
          // Only navigate if user exists AND email is verified
          if (user != null && user.emailVerified && mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        onError: (error) {
          debugPrint('Auth state error: $error');
          // Continue showing the initial screen even if auth fails
        },
      );
    } catch (e) {
      debugPrint('Error checking auth state: $e');
      // Continue showing the initial screen even if auth check fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top:90,left:20,right: 20,bottom: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1st child:logo
              Center(
                child: CircleAvatar(
                  radius: 120,
                  child: Icon(Icons.document_scanner_rounded, size: 80),
                ),
              ),

              // 2nd child:message
              SizedBox(height: 30),
              Center(
                child: Text(
                  'Scan,Organize and Secure',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Your Documents.',
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // 3rd child:4dots
              SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Dot 1 (active)
                  Container(
                    width: 10,
                    height: 10,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Dot 2
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Dot 3
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Dot 4
                  Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              // 4th child:buttons
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text('Login'),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: SizedBox(
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text('join now'),
                      ),
                    ),
                  ),
                ],
              ),

              // 5th child:continue as guest
              SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  // Allow user to continue without logging in
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Text(
                  'Continue as a guest',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
