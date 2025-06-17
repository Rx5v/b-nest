// lib/providers/report_provider.dart
import 'package:flutter/material.dart';
// import 'package:admin_batik/models/monthly_income_model.dart'; // Tidak diperlukan lagi
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:admin_batik/services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final ReportService _service = ReportService();

  String _dailyIncome = "0";
  String _weeklyIncome = "0";
  String _monthlyIncome = "0";
  String _yearlyIncome = "0";
  // HAPUS: List<MonthlyIncomeModel> _monthlyBreakdown = [];

  bool _isLoading = false;
  String? _errorMessage;

  ReportProvider(this.authProvider);

  String get dailyIncome => _dailyIncome;
  String get weeklyIncome => _weeklyIncome;
  String get monthlyIncome => _monthlyIncome;
  String get yearlyIncome => _yearlyIncome;
  // HAPUS: List<MonthlyIncomeModel> get monthlyBreakdown => _monthlyBreakdown;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllReports() async {
    if (authProvider.token == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _service.getIncomeReport(authProvider.token!, period: 'day'),
        _service.getIncomeReport(authProvider.token!, period: 'week'),
        _service.getIncomeReport(authProvider.token!, period: 'month'),
        _service.getIncomeReport(authProvider.token!, period: 'year'),
      ]);

      _dailyIncome = (responses[0]['data']?['income'].toString()) ?? "0";
      _weeklyIncome = (responses[1]['data']?['income'].toString()) ?? "0";
      _monthlyIncome = (responses[2]['data']?['income'].toString()) ?? "0";
      _yearlyIncome = (responses[3]['data']?['income'].toString()) ?? "0";

      // HAPUS Logika untuk monthly_breakdown
      // final List<dynamic> monthlyData = responses[3]['data']?['monthly_breakdown'] ?? [];
      // _monthlyBreakdown = monthlyData.map((d) => MonthlyIncomeModel.fromJson(d)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      print('Error fetching reports: $_errorMessage');
    }
    _isLoading = false;
    notifyListeners();
  }
}
