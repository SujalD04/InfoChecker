import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/result_card.dart';
import '../widgets/error_card.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation

class ClaimInputScreen extends StatefulWidget {
  const ClaimInputScreen({super.key});

  @override
  _ClaimInputScreenState createState() => _ClaimInputScreenState();
}

class _ClaimInputScreenState extends State<ClaimInputScreen> {
  final claimController = TextEditingController();
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  String verdict = "";
  String explanation = "";
  List<dynamic> resultLinks = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _sendClaim() async {
    final input = claimController.text.trim();
    if (input.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a claim before checking.';
        verdict = '';
        explanation = '';
        resultLinks = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      verdict = '';
      explanation = '';
      resultLinks = [];
    });

    try {
      final data = await _apiService.checkClaim(input);

      if (data != null) {
        final String result = data['result'] ?? "";

        // Extracting directly from JSON
        final int verdictStart = result.indexOf('Verdict:') + 'Verdict:'.length;
        final int verdictEnd = result.indexOf('\n', verdictStart);
        verdict =
            result.substring(verdictStart, verdictEnd).trim().toUpperCase();

        // Explanation
        final int explanationStart =
            result.indexOf('Explanation:') + 'Explanation:'.length;
        int explanationEnd = result.indexOf('Sources:', explanationStart);
        if (explanationEnd == -1) {
          // If 'Sources:' not found, take till end
          explanationEnd = result.length;
        }
        explanation = result.substring(explanationStart, explanationEnd).trim();

        // Ensure resultLinks is populated if available
        resultLinks = data['resultLinks'] ?? [];
      } else {
        errorMessage = 'Failed to get a valid response from the server.';
      }
    } catch (e) {
      errorMessage = 'Error checking claim: ${e.toString()}';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    claimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Misinformation Guard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a claim, news headline, or statement to verify:",
              style: AppStyles.subheading,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: claimController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "E.g. 'The Earth is flat'",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.primary),
                  onPressed: () {
                    claimController.clear();
                    setState(() {
                      verdict = '';
                      explanation = '';
                      resultLinks = [];
                      errorMessage = '';
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onPressed: isLoading ? null : _sendClaim,
              text: "Check Fact",
              icon: Icons.search,
              isLoading: isLoading,
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage.isNotEmpty)
                    ErrorCard(errorMessage: errorMessage),
                  if (verdict.isNotEmpty ||
                      explanation.isNotEmpty ||
                      resultLinks.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Analysis Result:",
                          style: AppStyles.subheading.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppStyles.borderRadius,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Verdict: $verdict",
                                  style: AppStyles.verdictText.copyWith(
                                    color:
                                        verdict.toLowerCase() == "true"
                                            ? AppColors.success
                                            : verdict.toLowerCase() == "false"
                                            ? AppColors.error
                                            : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Explanation:",
                                  style: AppStyles.bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(explanation, style: AppStyles.bodyText),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (resultLinks.isNotEmpty) ...[
                          Text(
                            "Supporting Sources:",
                            style: AppStyles.subheading.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...resultLinks
                              .map((link) => ResultCard(result: link))
                              .toList(),
                        ],
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
