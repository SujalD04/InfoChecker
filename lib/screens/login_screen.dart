import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart'; // Import glass_kit
import 'package:lottie/lottie.dart'; // Import lottie
import '../services/auth_service.dart';
import '../widgets/custom_field_text.dart'; // Corrected import name (assuming 'custom_field_text.dart' was renamed)
import '../widgets/animated_loading_button.dart'; // Use the new button
import '../widgets/custom_toast.dart'; // Use the new toast
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'claim_input_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _loginWithEmailPassword() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Login successful!',
          isSuccess: true,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClaimInputScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Login failed: ${e.toString().split('] ').last}',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _authService.signInWithGoogle();
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Google Sign-In successful!',
          isSuccess: true,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ClaimInputScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomToast.show(
          context,
          message: 'Google Sign-In failed: ${e.toString().split('] ').last}',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the height of the keyboard (0 if not visible)
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Calculate the effective screen height available for the UI
    final double availableScreenHeight =
        MediaQuery.of(context).size.height - keyboardHeight;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Animated decorative elements (Lottie with .lottie files)
          Positioned(
            top: -50,
            left: -50,
            child: Lottie.asset(
              'assets/success_check.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Lottie.asset(
              'assets/error_cross.json',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Center(
            child: GlassContainer(
              height: availableScreenHeight * 0.75,
              width: MediaQuery.of(context).size.width * 0.9,
              borderRadius: BorderRadius.circular(
                AppStyles.borderRadiusLarge * 2,
              ),
              blur: 15,
              alignment: Alignment.center,
              borderWidth: 0,
              color: Colors.white.withOpacity(0.1),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.2),
                  Colors.white.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // Ensure stretching
                    children: [
                      Hero(
                        tag: 'app_icon',
                        child: Icon(
                          Icons.shield_rounded,
                          size: 100,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Misinformation Guard",
                        style: AppStyles.headline1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: emailController,
                        labelText: "Email",
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: passwordController,
                        labelText: "Password",
                        prefixIcon: Icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      AnimatedLoadingButton(
                        onPressed: _loginWithEmailPassword,
                        text: "Login",
                        icon: Icons.login,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "or",
                        style: AppStyles.bodyText.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: Image.asset(
                          'assets/google_icon.webp', // Assuming .webp as per previous fix, adjust if still .png
                          width: 24,
                          height: 24,
                        ),
                        label: const Text("Continue with Google"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          // Set background to white
                          backgroundColor: Colors.white,
                          // Set text and icon color to black
                          foregroundColor: Colors.black,
                          side: BorderSide(
                            color: Colors.grey.shade400, // A subtle grey border
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppStyles.borderRadiusLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
