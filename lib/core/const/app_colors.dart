import 'package:flutter/material.dart';

class AppColors {
  // Brand Blue Colors
  static const Color primaryColor = Color(0xFF1976D2);       // Modern vibrant Blue
  static const Color primaryDark = Color(0xFF0D47A1);        // Deep Navy Blue
  static const Color primaryLight = Color(0xFFE3F2FD);       // Soft Blue tint
  static const Color accentColor = Color(0xFF0288D1);        // Sky Blue accent
  static const Color secondaryColor = Color(0xFF26A69A);     // Teal accent

  // Neutral / Background
  static const Color bgColor = Color(0xFFF7F9FC);            // Clean light grayish-blue background
  static const Color cardColor = Colors.white;
  static const Color strokeColor = Color(0xFFE2E8F0);        // Modern subtle border
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);        // High contrast slate
  static const Color textSecondary = Color(0xFF64748B);      // Subdued subtitle
  static const Color textMuted = Color(0xFF94A3B8);          // Placeholder & hint

  // Compatibility helpers
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color textColor = Color(0xFF1E293B);
  static const Color greyColor = Color(0xFF838383);
  static const Color greenColor = Color(0xFF10B981);
  static const Color redColor = Color(0xFFEF4444);

  // Status Colors
  static const Color success = Color(0xFF10B981);            // Emerald Green (Confirmed/Completed)
  static const Color warning = Color(0xFFF59E0B);            // Amber (Pending)
  static const Color error = Color(0xFFEF4444);              // Crimson Red (Cancelled/Error)
  static const Color info = Color(0xFF3B82F6);               // Blue (Info)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2196F3),
      Color(0xFF1565C0),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF0F7FF),
    ],
  );
}
