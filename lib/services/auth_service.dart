// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.157.232:8000/api';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final responseBody = jsonDecode(response.body);

      // Directly return the parsed response body.
      // AuthProvider will handle the 'meta' and 'data' keys.
      return responseBody;
    } catch (error) {
      // Handle network errors or other exceptions
      print("Login error: $error");
      // Return a structure consistent with what AuthProvider might expect on error
      return {
        'meta': {
          'success': false,
          'code': 500, // Or some other error code
          'message': 'An error occurred: ${error.toString()}',
        },
        'data': null,
      };
    }
  }

  // ... (fetchSomeData method remains the same conceptually)
}
