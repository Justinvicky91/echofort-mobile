import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  // Primary navy blue color
  static const Color primary = Color(0xFF1E3A8A);
  
  // Text colors
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  
  // Background colors
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}

/// App-wide constant values
class AppConstants {
  static const String appName = 'EchoFort';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.echofort.ai';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration otpResendTimeout = Duration(seconds: 60);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
}
