// lib/screen/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart'; // For custom fonts if needed

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // For BottomNavigationBar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation or state change based on index
      // For now, just updating the index
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white, //頁面背景色
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA16C22),
        elevation: 0, // 移除陰影
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                // backgroundImage: AssetImage('assets/admin_avatar.png'), // 替換為你的頭像圖片路徑
                backgroundColor: Colors.white54, // 佔位符背景色
                child: Icon(Icons.person,
                    color: Color(0xFFA16C22), size: 28), // 佔位符圖標
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Administrator',
                    style: GoogleFonts.crimsonPro(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Admin',
                    style: GoogleFonts.crimsonPro(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp. 21.000.000.000',
              style: GoogleFonts.crimsonPro(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3A3A3A)),
            ),
            const SizedBox(height: 24),
            Text(
              'Category',
              style: GoogleFonts.crimsonPro(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildCategorySummary(),
            const SizedBox(height: 24),
            _buildTodaySalesHeader(),
            const SizedBox(height: 12),
            _buildTodaySalesList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

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
                color: Colors.grey.shade800),
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
                  color: const Color(0xFF3A3A3A)),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: GoogleFonts.crimsonPro(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: GoogleFonts.crimsonPro(
                  fontSize: 11, color: Colors.grey.shade500),
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
              fontWeight: FontWeight.w600),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'view all',
            style: GoogleFonts.crimsonPro(
                fontSize: 13,
                color: const Color(0xFFA16C22),
                fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildTodaySalesList() {
    // 靜態數據模擬
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
      physics:
          const NeverScrollableScrollPhysics(), // 因為在 SingleChildScrollView 中
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
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    item['date']!,
                    style: GoogleFonts.crimsonPro(
                        fontSize: 12, color: Colors.grey.shade400),
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
                          color: const Color(0xFF3A3A3A)),
                    ),
                    Text(
                      item['location']!,
                      style: GoogleFonts.crimsonPro(
                          fontSize: 12, color: Colors.grey.shade500),
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
                    color: const Color(0xFF3A3A3A)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1), // changes position of shadow
          ),
        ],
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(20),
        //   topRight: Radius.circular(20),
        // ) // Optional: if you want rounded top corners
      ),
      child: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Product',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.widgets_outlined),
            activeIcon: Icon(Icons.widgets),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaction',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFA16C22), // 選中項目的顏色
        unselectedItemColor: Colors.grey.shade500, // 未選中項目的顏色
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent, // 使容器背景色生效
        type: BottomNavigationBarType.fixed, // 確保所有標籤都可見且大小一致
        elevation: 0, // 移除 BottomNavigationBar 自帶的陰影
        showUnselectedLabels: true,
        selectedLabelStyle:
            GoogleFonts.crimsonPro(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.crimsonPro(fontSize: 12),
      ),
    );
  }
}
