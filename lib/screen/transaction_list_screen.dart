// lib/screen/transaction_list_screen.dart
import 'package:admin_batik/screen/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/transaction_provider.dart';
import 'package:admin_batik/models/transaction_model.dart';
import 'package:intl/intl.dart';
// import 'package:admin_batik/screen/transaction_detail_screen.dart'; // Akan dibuat

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<TransactionProvider>(
            context,
            listen: false,
          ).fetchTransactions(),
    );
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

  @override
  Widget build(BuildContext context) {
    final listProvider = Provider.of<TransactionProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Transaksi')),
      body:
          listProvider.isLoadingList
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: () => listProvider.fetchTransactions(),
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
    );
  }
}
