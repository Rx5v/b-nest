// lib/screen/product_menu_screen.dart
import 'package:admin_batik/screen/variant_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:admin_batik/screen/product_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductMenuScreen extends StatefulWidget {
  const ProductMenuScreen({super.key});

  @override
  State<ProductMenuScreen> createState() => _ProductMenuScreenState();
}

class _ProductMenuScreenState extends State<ProductMenuScreen> {
  // State untuk mengontrol tampilan
  bool _isShowingProductList = false;

  // Method untuk mengubah state
  void _toggleShowProductList(bool show) {
    setState(() {
      _isShowingProductList = show;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan widget yang sesuai berdasarkan state
    if (_isShowingProductList) {
      // Jika true, tampilkan halaman daftar produk
      // Kita kirim fungsi untuk kembali ke menu
      return ProductScreen(onBack: () => _toggleShowProductList(false));
    } else {
      // Jika false, tampilkan halaman menu
      return _buildMenuView();
    }
  }

  // Widget untuk UI Menu
  Widget _buildMenuView() {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildMenuCard(
            context: context,
            icon: Icons.inventory_2_outlined,
            title: 'Daftar Produk',
            subtitle: 'Lihat, tambah, ubah, dan hapus data produk utama.',
            onTap: () {
              // Saat di-tap, ubah state untuk menampilkan daftar produk
              _toggleShowProductList(true);
            },
          ),
        ],
      ),
    );
  }

  // Helper widget untuk kartu menu
  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1.5,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16.0,
        ),
        leading: Icon(icon, size: 40, color: const Color(0xFFA16C22)),
        title: Text(
          title,
          style: GoogleFonts.crimsonPro(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.crimsonPro(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
