// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  static const String _baseUrl = 'http://10.200.5.145:8000/api/admin';

  Future<Map<String, dynamic>> getProducts(String token, {int page = 1}) async {
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

      print('Get Products Raw Response: ${response.body}');
      // SOLUSI: Bersihkan body sebelum parsing
      final cleanBody = response.body.trim();
      return jsonDecode(cleanBody);
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
    Map<String, String> fields,
    List<String> imagePaths,
  ) async {
    final url = Uri.parse('$_baseUrl/products');
    print('Adding product (multipart) to: $url');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll(fields);

      for (var path in imagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images[]', path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Add Product Raw Response: ${response.body}');
      // SOLUSI: Bersihkan body sebelum parsing
      final cleanBody = response.body.trim();
      return jsonDecode(cleanBody);
    } catch (e) {
      print('Error adding product: $e');
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

  Future<Map<String, dynamic>> updateProduct(
    String token,
    int productId,
    Map<String, String> fields,
    List<String> newImagePaths,
  ) async {
    final url = Uri.parse('$_baseUrl/products?id=$productId');
    print('Updating product $productId (multipart)');

    try {
      var request = http.MultipartRequest(
        'POST',
        url,
      ); // Gunakan POST dengan _method override
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll(fields);
      request.fields['_method'] = 'PUT';

      for (var path in newImagePaths) {
        request.files.add(await http.MultipartFile.fromPath('images[]', path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('Update Product Raw Response: ${response.body}');
      // SOLUSI: Bersihkan body sebelum parsing
      final cleanBody = response.body.trim();
      return jsonDecode(cleanBody);
    } catch (e) {
      print('Error updating product: $e');
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

  Future<Map<String, dynamic>> deleteProduct(
    String token,
    int productId,
  ) async {
    // Sesuai contoh Anda, ID dikirim sebagai query parameter
    final url = Uri.parse('$_baseUrl/products?id=$productId');
    print('Deleting product $productId at: $url');

    try {
      // Menggunakan http.delete() untuk kemudahan, ini setara dengan http.Request('DELETE', ...)
      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Product Raw Response: ${response.body}');
      final cleanBody = response.body.trim();
      // Periksa jika body kosong, karena delete sukses mungkin tidak mengembalikan body
      if (cleanBody.isEmpty) {
        // Jika status code 200 OK atau 204 No Content, anggap sukses
        if (response.statusCode == 200 || response.statusCode == 204) {
          return {
            'meta': {
              'success': true,
              'code': response.statusCode,
              'message': 'Product deleted successfully.',
            },
          };
        }
      }
      return jsonDecode(cleanBody);
    } catch (e) {
      print('Error deleting product $productId: $e');
      return {
        'meta': {
          'success': false,
          'code': 500,
          'message':
              'An error occurred while deleting product: ${e.toString()}',
        },
      };
    }
  }
}
