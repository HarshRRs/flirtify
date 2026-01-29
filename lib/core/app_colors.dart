import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFFFF4D67); // Vibrant Rose
  static const Color primaryLight = Color(0xFFFF8597);
  static const Color primaryDark = Color(0xFFE63E56);
  
  // Secondary / Accent
  static const Color secondary = Color(0xFF7B61FF); // Royal Purple
  static const Color accent = Color(0xFF00E5FF); // Electric Cyan
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color dark = Color(0xFF121212);
  static const Color surface = Color(0xFFF8F9FA);
  
  // Greys
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFE9ECEF);
  static const Color grey200 = Color(0xFFDEE2E6);
  static const Color grey300 = Color(0xFFCED4DA);
  static const Color grey400 = Color(0xFFADB5BD);
  static const Color grey500 = Color(0xFF6C757D);
  static const Color grey600 = Color(0xFF495057);
  static const Color grey700 = Color(0xFF343A40);
  static const Color grey800 = Color(0xFF212529);
  static const Color grey900 = Color(0xFF1A1D21); // Darkest grey
  static const Color softGrey = Color(0xFFE9ECEF); // Soft grey for subtle backgrounds
  static const Color grey = Color(0xFF6C757D); // Default grey (same as grey500)
  static const Color softPink = Color(0xFFFFE5E9); // Soft pink for backgrounds
  
  // Semantic Colors
  static const Color success = Color(0xFF28A745);
  static const Color info = Color(0xFF17A2B8);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFFF8A5B)], // Rose to Sunset Orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1F1F1F), Color(0xFF121212)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Status Colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color away = Color(0xFFFFC107);
}
