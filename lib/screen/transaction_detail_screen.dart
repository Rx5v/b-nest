// lib/screen/transaction_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/transaction_provider.dart';
import 'package:admin_batik/models/transaction_model.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TransactionDetailScreen extends StatefulWidget {
  final int transactionId;
  final String transactionCode;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    required this.transactionCode,
  });

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactionDetail(widget.transactionId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail ${widget.transactionCode}')),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetail) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.detailErrorMessage != null ||
              provider.selectedTransactionDetail == null) {
            return Center(
              child: Text(
                provider.detailErrorMessage ?? 'Gagal memuat detail transaksi.',
              ),
            );
          }
          final transaction = provider.selectedTransactionDetail!;
          return _buildDetailContent(context, transaction);
        },
      ),
    );
  }

  Widget _buildDetailContent(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- KARTU STATUS ---
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusColumn(
                      'Status Pesanan',
                      transaction.orderStatus,
                      _getStatusColor(transaction.orderStatus),
                    ),
                    _buildStatusColumn(
                      'Status Pembayaran',
                      transaction.paymentStatus,
                      _getStatusColor(transaction.paymentStatus),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- INFO UTAMA ---
            _buildSectionTitle('Informasi Pesanan'),
            _buildInfoRow(
              'Tanggal:',
              DateFormat(
                'EEEE, d MMMM yyyy, HH:mm',
                'id_ID',
              ).format(transaction.transactionDate),
            ),
            _buildInfoRow('Tipe:', transaction.type),
            _buildInfoRow('Pengiriman:', transaction.methodDelivery),
            _buildInfoRow('Alamat:', transaction.shippingLocation),
            const Divider(height: 32),

            // --- INFO PEMBAYARAN ---
            _buildSectionTitle('Informasi Pembayaran'),
            _buildInfoRow(
              'Total Belanja:',
              formatCurrency.format(
                transaction.totalPrice - transaction.shippingCost,
              ),
            ),
            _buildInfoRow(
              'Ongkos Kirim:',
              formatCurrency.format(transaction.shippingCost),
            ),
            _buildInfoRow(
              'Total Pembayaran:',
              formatCurrency.format(transaction.totalPrice),
              isBold: true,
            ),
            if (transaction.customerNotes != null &&
                transaction.customerNotes!.isNotEmpty)
              _buildInfoRow('Catatan Pelanggan:', transaction.customerNotes!),

            const Divider(height: 32),

            // --- RINCIAN ITEM ---
            _buildSectionTitle('Rincian Item (${transaction.details.length})'),
            ...transaction.details
                .map(
                  (detail) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.white,
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl:
                                  detail.images.isNotEmpty
                                      ? detail.images.first.fullImageUrl
                                      : '',
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder:
                                  (ctx, url) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade200,
                                  ),
                              errorWidget:
                                  (ctx, url, err) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  detail.productName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Ukuran: ${detail.variantSize}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${detail.quantity} x ${formatCurrency.format(detail.price)}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(context, transaction),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusColumn(String title, String status, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Chip(
          label: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ],
    );
  }

  // Helper untuk baris info
  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
      case 'diterima':
        return Colors.green.shade600;
      case 'dibatalkan':
      case 'ditolak':
        return Colors.red.shade600;
      case 'diproses':
        return Colors.blue.shade600;
      case 'pending':
      case 'menunggu persetujuan':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  // Method untuk menampilkan tombol aksi
  Widget _buildActionButtons(
    BuildContext context,
    TransactionModel transaction,
  ) {
    // Tombol hanya muncul jika status pesanan BUKAN 'Selesai' atau 'Dibatalkan'
    final orderStatus = transaction.orderStatus.toLowerCase();
    if (orderStatus != 'selesai' &&
        orderStatus != 'dibatalkan' &&
        orderStatus != 'ditolak') {
      return Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('TOLAK'),
                onPressed:
                    () => _showConfirmationDialog(
                      context,
                      'Tolak',
                      transaction.id,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('SETUJUI'),
                onPressed:
                    () => _showConfirmationDialog(
                      context,
                      'Setujui',
                      transaction.id,
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _showConfirmationDialog(
    BuildContext context,
    String action,
    int transactionId,
  ) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi Aksi'),
            content: Text('Apakah Anda yakin ingin "$action" pesanan ini?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  bool success = false;
                  if (action == 'Setujui') {
                    success = await provider.approveTransaction(transactionId);
                  } else {
                    success = await provider.rejectTransaction(transactionId);
                  }

                  if (context.mounted) {
                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Pesanan berhasil di-$action.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.detailErrorMessage ??
                                'Gagal mengubah status pesanan.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      action == 'Setujui' ? Colors.green : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(action),
              ),
            ],
          ),
    );
  }
}
