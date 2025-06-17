// lib/screen/dashboard_screen.dart
import 'package:admin_batik/providers/report_provider.dart';
import 'package:admin_batik/providers/transaction_provider.dart';
import 'package:admin_batik/screen/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
// Hapus import provider jika tidak digunakan langsung di sini untuk AppBar/BottomNav
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreen();
}

class _DashboardScreen extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<ReportProvider>(context, listen: false).fetchAllReports(),
    );
    Future.microtask(
      () =>
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).fetchTransactions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReportProvider>(context);
    return SingleChildScrollView(
      // Langsung return konten body
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthNavigator(),
          const SizedBox(height: 20),
          Text(
            'Today Sales',
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            NumberFormat.currency(
              locale: 'id-ID',
            ).format(double.parse(provider.dailyIncome)),
            style: GoogleFonts.crimsonPro(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Recap',
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategorySummary(),
          const SizedBox(height: 24),
          _buildTodaySalesHeader(),
          const SizedBox(height: 12),
          _buildTodaySalesList(),
        ],
      ),
    );
  }

  // ... (Semua method _build... yang ada di DashboardScreen sebelumnya tetap di sini)
  Widget _buildMonthNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chevron_left, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Text(
            'June 2025',
            style: GoogleFonts.crimsonPro(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade700),
        ],
      ),
    );
  }

  Widget _buildCategorySummary() {
    final provider = Provider.of<ReportProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryItem('27', 'Week', provider.weeklyIncome),
        _buildCategoryItem('27', 'Month', provider.monthlyIncome),
        _buildCategoryItem('27', 'Year', provider.yearlyIncome),
      ],
    );
  }

  Widget _buildCategoryItem(String count, String name, String amount) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.crimsonPro(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF3A3A3A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.crimsonPro(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              NumberFormat.currency(
                locale: 'id-ID',
              ).format(double.parse(amount)),

              style: GoogleFonts.crimsonPro(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySalesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Today sale',
          style: GoogleFonts.crimsonPro(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'view all',
            style: GoogleFonts.crimsonPro(
              fontSize: 13,
              color: const Color(0xFFA16C22),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySalesList() {
    final listProvider = Provider.of<TransactionProvider>(context);

    return listProvider.isLoadingList
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: listProvider.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = listProvider.transactions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        transaction.code,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        DateFormat(
                          'd MMM yyyy, HH:mm',
                        ).format(transaction.transactionDate),
                      ),
                      trailing: Chip(
                        label: Text(
                          transaction.orderStatus,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: _getStatusColor(
                          transaction.orderStatus,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (_) => TransactionDetailScreen(
                                  transactionId: transaction.id,
                                  transactionCode: transaction.code,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'selesai':
      return Colors.green;
    case 'dibatalkan':
      return Colors.red;
    case 'diproses':
      return Colors.blue;
    case 'menunggu persetujuan':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
