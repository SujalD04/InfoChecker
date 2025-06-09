import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  static const double borderRadius = 8.0;
  static const double borderRadiusLarge = 16.0; // For cards and main elements

  static final TextStyle headline1 = GoogleFonts.poppins(
    fontSize: 32, // Larger and bolder
    fontWeight: FontWeight.w800, // Extra bold
    color: AppColors.text,
    letterSpacing: -0.8,
  );

  static final TextStyle subheading = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static final TextStyle bodyText = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.text,
    height: 1.6,
  );

  static final TextStyle buttonText = GoogleFonts.poppins(
    fontSize: 17, // Slightly larger button text
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle verdictText = GoogleFonts.poppins(
    fontSize: 20, // More prominent verdict
    fontWeight: FontWeight.w700,
  );

  static final TextStyle linkText = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle cardTitle = GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static final TextStyle errorText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.error,
  );

  static final TextStyle successText = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.success,
  );

  static final TextStyle toastMessage = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
}
