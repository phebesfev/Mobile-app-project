import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

/// This screen waits for the user to verify their email
/// It automatically checks if email is verified and navigates to home
class EmailVerificationScreen extends StatefulWidget {
  final String email;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  Timer? _verificationTimer;
  bool _isChecking = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    // Start checking for verification every 3 seconds
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  /// Check if email is verified every 3 seconds
  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      if (_isVerified) {
        timer.cancel();
        return;
      }

      setState(() {
        _isChecking = true;
      });

      try {
        // Reload user to get latest verification status
        await _authService.reloadUser();
        
        if (_authService.isEmailVerified()) {
          setState(() {
            _isVerified = true;
          });
          
          timer.cancel();
          
          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Email verified! Welcome!'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate to home after a short delay
            Future.delayed(Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            });
          }
        }
      } catch (e) {
        debugPrint('Error checking verification: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }
      }
    });
  }

  /// Manually check verification (when user clicks button)
  Future<void> _checkVerification() async {
    setState(() {
      _isChecking = true;
    });

    try {
      await _authService.reloadUser();
      
      if (_authService.isEmailVerified()) {
        setState(() {
          _isVerified = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email verified! Welcome!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email not verified yet. Please check your inbox.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  /// Resend verification email
  Future<void> _resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email resent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Your Email'),
        automaticallyImplyLeading: false, // Prevent going back
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email icon
            Icon(
              Icons.email_outlined,
              size: 80,
              color: Colors.blue,
            ),
            SizedBox(height: 24),
            
            // Title
            Text(
              'Check Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
            // Email address
            Text(
              'We sent a verification link to:',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              widget.email,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '1. Open your email inbox',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '2. Find the verification email',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '3. Click the verification link',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '4. Come back here - we\'ll detect it automatically!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            
            // Status indicator
            if (_isChecking)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Checking verification status...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            else if (_isVerified)
              Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Email verified! Redirecting...',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            
            SizedBox(height: 32),
            
            // Check verification button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isChecking ? null : _checkVerification,
                child: Text(
                  _isChecking ? 'Checking...' : 'I\'ve Verified My Email',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // Resend email button
            TextButton(
              onPressed: _resendVerificationEmail,
              child: Text('Resend Verification Email'),
            ),
          ],
        ),
      ),
    );
  }
}