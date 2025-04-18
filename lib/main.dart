import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // generated by flutterfire
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load();
  runApp(const MyApp());
}

void _launchURL(String url) async {
  final uri = Uri.tryParse(url);
  if (uri != null && await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home:
          FirebaseAuth.instance.currentUser == null
              ? LoginScreen()
              : ClaimInputScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> loginWithEmailPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ClaimInputScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: ${e.toString()}')));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // user canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ClaimInputScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user, size: 80, color: Colors.blueAccent),
              SizedBox(height: 16),
              Text(
                "Misinformation Checker",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: loginWithEmailPassword,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text("Login", style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 20),
              Text("or", style: TextStyle(fontSize: 14, color: Colors.grey)),
              SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: signInWithGoogle,
                icon: Image.asset(
                  'assets/google_icon.webp',
                  width: 24, // Add a Google logo in assets folder
                  height: 24,
                ),
                label: Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClaimInputScreen extends StatefulWidget {
  @override
  _ClaimInputScreenState createState() => _ClaimInputScreenState();
}

class _ClaimInputScreenState extends State<ClaimInputScreen> {
  final claimController = TextEditingController();
  String claim = "";
  String verdict = "";
  String explanation = "";
  List<String> sources = [];
  List<dynamic> resultLinks = [];
  List<dynamic> responseData = []; // Define responseData as an empty list
  bool isLoading = false;
  String errorMessage = '';

  Future<void> sendClaim() async {
    final input = claimController.text.trim();
    if (input.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a claim before checking.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
      verdict = '';
      explanation = '';
      sources = [];
      resultLinks = [];
      responseData = [];
    });

    try {
      final response = await http.post(
        Uri.parse(dotenv.env['API_URL']!),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'claim': input}),
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Extracting directly from JSON
        final String result = data['result'] ?? "";

        // Example result: "Verdict: true\nExplanation: The moon landing was not faked."
        final int verdictStart = result.indexOf('Verdict:') + 'Verdict:'.length;
        final int verdictEnd = result.indexOf('\n', verdictStart);
        verdict =
            result.substring(verdictStart, verdictEnd).trim().toUpperCase();

        // Explanation
        final int explanationStart =
            result.indexOf('Explanation:') + 'Explanation:'.length;
        final int explanationEnd = result.indexOf('Sources:', explanationStart);
        explanation = result.substring(explanationStart, explanationEnd).trim();

        // Handling sources - splitting them based on "Sources:" delimiter
        final String sourcesText =
            result.substring(explanationEnd + 'Sources:'.length).trim();
        sources =
            sourcesText.split('\n').map((source) => source.trim()).toList();

        setState(() {
          claim = data['claim'] ?? '';
          responseData = data['responseData'] ?? [];
          resultLinks = data['resultLinks'] ?? [];
        });
      } else {
        setState(() {
          errorMessage = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Misinformation Checker"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Enter a claim, news headline, or statement to verify:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            TextField(
              controller: claimController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "E.g. 'The Earth is flat'",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLoading ? null : sendClaim,
              icon: Icon(Icons.search),
              label: Text("Check Fact"),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 24),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (errorMessage.isNotEmpty) _buildErrorCard(errorMessage),
                  if (verdict.isNotEmpty ||
                      explanation.isNotEmpty ||
                      resultLinks.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Analysis Result:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Verdict: $verdict",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        verdict.toLowerCase() == "true"
                                            ? Colors.green
                                            : verdict.toLowerCase() == "false"
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Explanation:",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  explanation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "Supporting Sources:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ...resultLinks
                            .map((link) => _buildResultCard(link))
                            .toList(),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(dynamic result) {
    final title = result['title'];
    final snippet = result['snippet'];
    final url = result['url'];

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? 'No title available',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              snippet ?? 'No snippet available.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 8),
            if (url != null) ...[
              GestureDetector(
                onTap: () => _launchURL(url),
                child: Text(
                  'Source: $url',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      color: Colors.red[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          error,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
