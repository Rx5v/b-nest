// lib/screen/main_layout_screen.dart
import 'package:admin_batik/providers/product_provider.dart';
import 'package:admin_batik/screen/dashboard.dart';
import 'package:admin_batik/screen/product_menu_screen.dart';
import 'package:admin_batik/screen/transaction_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:admin_batik/models/user_model.dart';

import 'package:google_fonts/google_fonts.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    ProductMenuScreen(),
    Text('Stock Page (Coming Soon)'),
    TransactionListScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 1) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts(refresh: true);
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFA16C22),
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage:
                    currentUser?.image != null && currentUser!.image!.isNotEmpty
                        ? NetworkImage(currentUser.image!)
                        : null,
                backgroundColor: Colors.white54,
                child:
                    currentUser?.image == null || currentUser!.image!.isEmpty
                        ? const Icon(
                          Icons.person,
                          color: Color(0xFFA16C22),
                          size: 28,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentUser?.name ?? 'Administrator',
                    style: GoogleFonts.crimsonPro(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentUser?.role ?? 'Admin',
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
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: _widgetOptions),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
            offset: const Offset(0, -1),
          ),
        ],
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
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Transaction',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFA16C22),
        unselectedItemColor: Colors.grey.shade500,
        onTap: _onItemTapped,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.crimsonPro(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.crimsonPro(fontSize: 12),
      ),
    );
  }
}
