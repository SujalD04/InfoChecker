import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  Future<Map<String, dynamic>?> checkClaim(String claim) async {
    final apiUrl = dotenv.env['API_URL'];

    if (apiUrl == null) {
      throw Exception('API_URL not found in .env file.');
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'claim': claim}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // You might want to parse the error message from the backend if available
        throw Exception(
          'Server error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network error or API call failed: $e');
    }
  }
}
