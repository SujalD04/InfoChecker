import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90E2); // Modern Blue
  static const MaterialColor primaryMaterial = MaterialColor(
    0xFF4A90E2,
    <int, Color>{
      50: Color(0xFFEAF4FF),
      100: Color(0xFFCDE3FF),
      200: Color(0xFFAAD0FF),
      300: Color(0xFF87BDFF),
      400: Color(0xFF64A9FF),
      500: Color(0xFF4A90E2), // Original
      600: Color(0xFF3F7ED3),
      700: Color(0xFF346CC4),
      800: Color(0xFF295BB5),
      900: Color(0xFF1E4AA6),
    },
  );
  static const Color primaryLight = Color(
    0xFF7CB8F7,
  ); // Lighter shade for gradients
  static const Color primaryDark = Color(
    0xFF336EAF,
  ); // Darker shade for gradients

  static const Color accent = Color(0xFFFFD166); // Softer Gold
  static const Color background = Color(
    0xFFF7F9FC,
  ); // Very light grey blue for background
  static const Color inputFill = Color(
    0xFFEFEFF4,
  ); // Light grey for input fields
  static const Color success = Color(0xFF5CB85C); // Green for success
  static const Color error = Color(0xFFD9534F); // Red for error
  static const Color warning = Color(0xFFF0AD4E); // Orange for warning
  static const Color text = Color(0xFF333333); // Dark grey for general text
  static const Color lightText = Color(
    0xFF666666,
  ); // Medium grey for secondary text
  static const Color shadowColor = Color(
    0x304A90E2,
  ); // Soft shadow from primary color
}
