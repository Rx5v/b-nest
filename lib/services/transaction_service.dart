// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/admin';

  Future<Map<String, dynamic>> getTransactions(String token) async {
    final url = Uri.parse('$_baseUrl/transactions');
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
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<Map<String, dynamic>> getTransactionDetail(
    String token,
    int transactionId,
  ) async {
    // Sesuai permintaan Anda, menggunakan POST dengan query parameter id
    // Asumsi: /transaction (singular) dan ?id=
    final url = Uri.parse('$_baseUrl/transactions?id=$transactionId');
    print('Fetching transaction detail for ID $transactionId from: $url');

    try {
      // Menggunakan method POST sesuai spesifikasi
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Transaction Detail Raw Response: ${response.body}');
      final cleanBody = response.body.trim();
      return jsonDecode(cleanBody);
    } catch (e) {
      print('Error fetching transaction detail: $e');
      throw Exception('Failed to load transaction detail: $e');
    }
  }

  // --- PERUBAHAN PADA METHOD INI ---
  Future<Map<String, dynamic>> updateOrderStatus(
    String token,
    int transactionId,
    String status,
  ) async {
    // URL disesuaikan dengan route baru: /transactions/{status}?id={id}
    // 'status' akan berisi 'approve' atau 'reject'
    final url = Uri.parse('$_baseUrl/transactions/$status?id=$transactionId');
    print(
      'Updating transaction status to "$status" at: $url',
    ); // Logging untuk debugging

    try {
      // Menggunakan method POST sesuai spesifikasi
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final responseBody = response.body.trim();
      print('Update Status Raw Response: $responseBody');

      // Jika body kosong tapi sukses, kembalikan respons sukses manual
      if (responseBody.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {
            'meta': {
              'success': true,
              'code': response.statusCode,
              'message': 'Status updated successfully.',
            },
          };
        }
      }

      return jsonDecode(responseBody);
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }
}
