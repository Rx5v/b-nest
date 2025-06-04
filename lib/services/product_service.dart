// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/admin';

  Future<Map<String, dynamic>> getProducts(String token, {int page = 1}) async {
    // ... (method getProducts yang sudah ada)
    final url = Uri.parse('$_baseUrl/products?page=$page');
    print('Fetching products from: $url');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final responseBody = jsonDecode(response.body);
      print('Product Response Body: $responseBody');
      return responseBody;
    } catch (e) {
      print('Error fetching products: $e');
      return {
        'meta': {
          'success': false,
          'code': 500,
          'message': 'An error occurred: ${e.toString()}',
        },
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> addProduct(
    String token,
    Map<String, dynamic> productData,
  ) async {
    // ... (method addProduct yang sudah ada)
    final url = Uri.parse('$_baseUrl/products');
    print('Adding product to: $url with data: $productData');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );
      final responseBody = jsonDecode(response.body);
      print('Add Product Response Body: $responseBody');
      return responseBody;
    } catch (e) {
      print('Error adding product: $e');
      return {
        'meta': {
          'success': false,
          'code': 500,
          'message': 'An error occurred while adding product: ${e.toString()}',
        },
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> productData,
  ) async {
    final url = Uri.parse('$_baseUrl/products'); // Menggunakan ID produk di URL
    print('Updating product $productId at: $url with data: $productData');

    try {
      final response = await http.put(
        // Menggunakan method PUT
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      final responseBody = jsonDecode(response.body);
      print('Update Product Response Body: $responseBody');
      return responseBody;
    } catch (e) {
      print('Error updating product $productId: $e');
      return {
        'meta': {
          'success': false,
          'code': 500,
          'message':
              'An error occurred while updating product: ${e.toString()}',
        },
        'data': null,
      };
    }
  }
}
