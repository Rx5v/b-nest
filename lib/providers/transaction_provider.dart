// lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:admin_batik/models/transaction_model.dart';
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:admin_batik/services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final TransactionService _service = TransactionService();

  List<TransactionModel> _transactions = [];
  bool _isLoadingList = false;
  String? _listErrorMessage;

  TransactionModel? _selectedTransactionDetail;
  bool _isLoadingDetail = false;
  String? _detailErrorMessage;

  TransactionProvider(this.authProvider);

  List<TransactionModel> get transactions => _transactions;
  bool get isLoadingList => _isLoadingList;
  String? get listErrorMessage => _listErrorMessage;

  TransactionModel? get selectedTransactionDetail => _selectedTransactionDetail;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get detailErrorMessage => _detailErrorMessage;

  Future<void> fetchTransactions() async {
    if (authProvider.token == null) return;
    _isLoadingList = true;
    notifyListeners();
    try {
      final response = await _service.getTransactions(authProvider.token!);
      if (response['meta']['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _transactions =
            data.map((item) => TransactionModel.fromJson(item)).toList();
        _listErrorMessage = null;
      } else {
        _listErrorMessage = response['meta']['message'];
      }
    } catch (e) {
      _listErrorMessage = e.toString();
    }
    _isLoadingList = false;
    notifyListeners();
  }

  Future<void> fetchTransactionDetail(int transactionId) async {
    if (authProvider.token == null) return;
    _isLoadingDetail = true;
    _selectedTransactionDetail = null; // Kosongkan data lama
    _detailErrorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getTransactionDetail(
        authProvider.token!,
        transactionId,
      );
      if (response['meta']['success'] == true) {
        // 'data' dari respons detail adalah satu objek, bukan list
        _selectedTransactionDetail = TransactionModel.fromJson(
          response['data'],
        );
      } else {
        _detailErrorMessage = response['meta']['message'];
      }
    } catch (e) {
      _detailErrorMessage = e.toString();
    }
    _isLoadingDetail = false;
    notifyListeners();
  }

  Future<bool> approveTransaction(int transactionId) async {
    return _updateStatus(transactionId, 'approve');
  }

  Future<bool> rejectTransaction(int transactionId) async {
    return _updateStatus(transactionId, 'reject');
  }

  Future<bool> _updateStatus(int transactionId, String status) async {
    if (authProvider.token == null) return false;
    _isLoadingList = true;
    notifyListeners();
    try {
      final response = await _service.updateOrderStatus(
        authProvider.token!,
        transactionId,
        status,
      );
      if (response['meta']['success'] == true) {
        // Refresh list untuk mendapatkan status terbaru
        await fetchTransactions();
        return true;
      } else {
        _listErrorMessage = response['meta']['message'];
        return false;
      }
    } catch (e) {
      _listErrorMessage = e.toString();
      return false;
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }
}
