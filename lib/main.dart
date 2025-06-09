import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart'; // Import google_fonts

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/claim_input_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misinformation Guard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Apply Google Fonts globally
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: AppColors.text,
          displayColor: AppColors.text,
        ),
        primarySwatch: AppColors.primaryMaterial,
        primaryColor: AppColors.primary,
        hintColor: AppColors.accent,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22, // Slightly larger for impact
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          elevation: 0, // Flat app bar
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppStyles.borderRadiusLarge,
            ), // Larger border radius
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ), // Highlight on focus
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          filled: true,
          fillColor: AppColors.inputFill,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18.0, // More padding
            horizontal: 20.0,
          ),
          hintStyle: AppStyles.bodyText.copyWith(color: Colors.grey[500]),
          labelStyle: AppStyles.bodyText.copyWith(color: Colors.grey[700]),
          prefixIconColor: AppColors.primary.withOpacity(0.7),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 40,
              vertical: 16,
            ), // More padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            ),
            textStyle: AppStyles.buttonText,
            elevation: 5, // More prominent shadow
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            side: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ), // Stronger border
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
            ),
            textStyle: AppStyles.buttonText.copyWith(color: AppColors.primary),
            elevation: 1,
          ),
        ),
        cardTheme: CardTheme(
          elevation: 8, // More prominent card shadow
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadiusLarge),
          ),
          color: Colors.white,
          margin: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 4,
          ), // Add margin to cards
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // A more visually appealing loading indicator for splash
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      size: 120,
                      color: AppColors.primary,
                    ),
                    SizedBox(height: 20),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Loading...",
                      style: TextStyle(color: AppColors.text, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasData) {
            return const ClaimInputScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
