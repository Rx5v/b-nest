// lib/services/variant_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class VariantService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/admin';

  // Asumsi endpoint untuk GET semua varian
  Future<Map<String, dynamic>> getVariants(String token) async {
    final url = Uri.parse('$_baseUrl/product-variants');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      return jsonDecode(response.body.trim());
    } catch (e) {
      throw Exception('Failed to load variants: $e');
    }
  }

  Future<Map<String, dynamic>> getVariantsForProduct(
    String token,
    int productId,
  ) async {
    final url = Uri.parse('$_baseUrl/product-variants?product_id=$productId');
    print('Fetching variants for product $productId from: $url');
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
      throw Exception('Failed to load variants for product: $e');
    }
  }

  Future<Map<String, dynamic>> addVariant(
    String token,
    Map<String, String> fields,
  ) async {
    final url = Uri.parse('$_baseUrl/product-variants');
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      request.fields.addAll(fields);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body.trim());
      return jsonDecode(response.body.trim());
    } catch (e) {
      throw Exception('Failed to add variant: $e');
    }
  }
}
