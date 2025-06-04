// lib/screen/dashboard_screen.dart
import 'package:flutter/material.dart';
// Hapus import provider jika tidak digunakan langsung di sini untuk AppBar/BottomNav
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  // Tidak perlu StatefulWidget jika hanya UI statis
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tidak ada Scaffold, AppBar, atau BottomNavigationBar di sini lagi
    return SingleChildScrollView(
      // Langsung return konten body
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMonthNavigator(),
          const SizedBox(height: 20),
          Text(
            'Total Sales',
            style: GoogleFonts.crimsonPro(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Rp. 21.000.000.000',
            style: GoogleFonts.crimsonPro(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCategoryItem('27', 'Kain', 'Rp. 7.000.000.000'),
        _buildCategoryItem('27', 'Kaos', 'Rp. 7.000.000.000'),
        _buildCategoryItem('27', 'Kemeja', 'Rp. 7.000.000.000'),
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
              amount,
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
    final List<Map<String, String>> salesData = List.generate(
      7,
      (index) => {
        'trx': 'trx00001',
        'date': '1/06/2025',
        'name': 'Aviana Candra A.N',
        'location': 'Klaten, Jawa Tengah, Indonesia',
        'amount': 'Rp. 12.000.000',
      },
    );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: salesData.length,
      itemBuilder: (context, index) {
        final item = salesData[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['trx']!,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    item['date']!,
                    style: GoogleFonts.crimsonPro(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name']!,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3A3A3A),
                      ),
                    ),
                    Text(
                      item['location']!,
                      style: GoogleFonts.crimsonPro(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                item['amount']!,
                style: GoogleFonts.crimsonPro(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3A3A3A),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
