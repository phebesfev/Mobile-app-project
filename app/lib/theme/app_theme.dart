import 'package:flutter/material.dart';


class AppTheme {
  // 1. Define the Color Palette
  // Using a modern, professional color scheme (Indigo & Teal)
  static const primaryColor = Color(0xFF4F46E5); // Indigo 600
  static const secondaryColor = Color(0xFF0EA5E9); // Sky 500
  static const accentColor = Color(0xFFF43F5E); // Rose 500 (for errors/alerts)
  static const backgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const surfaceColor = Colors.white;

  // 2. Define the Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: accentColor,
      ),

      // 3. Typography (Default or custom font family)
      fontFamily: 'Poppins', // Or your preferred font family, must be available on all platforms
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
      ),

      // 4. Component Styling (The "Professional Polish")

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0, // Flat design is trendy
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Soft rounded corners
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),

      // Text Fields (Input)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border when inactive (clean look)
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1),
        ),
      ),

      // Cards
      /*
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      */

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: Colors.black87, // Dark text on light background
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
