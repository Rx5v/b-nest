// lib/services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/admin';

  Future<Map<String, dynamic>> getIncomeReport(
    String token, {
    String period = 'day',
  }) async {
    final url = Uri.parse('$_baseUrl/report/income?periode=$period');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print(response.body.trim());
      return jsonDecode(response.body.trim());
    } catch (e) {
      throw Exception('Failed to load income report for period $period: $e');
    }
  }
}
