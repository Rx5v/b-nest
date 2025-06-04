// lib/main.dart
import 'package:admin_batik/screen/add_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:admin_batik/providers/product_provider.dart'; // Impor ProductProvider
import 'package:admin_batik/screen/login.dart';
// import 'package:admin_batik/screen/dashboard_screen.dart'; // Tidak digunakan langsung di sini lagi
import 'package:admin_batik/screen/main_layout_screen.dart'; // Impor MainLayoutScreen
import 'package:intl/date_symbol_data_local.dart'; // Untuk inisialisasi locale intl

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding sudah siap
  await initializeDateFormatting(
    'id_ID',
    null,
  ); // Inisialisasi locale untuk intl
  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Gunakan MultiProvider untuk beberapa provider
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
          create:
              (ctx) => ProductProvider(
                Provider.of<AuthProvider>(ctx, listen: false),
              ),
          update: (ctx, auth, previousProductProvider) => ProductProvider(auth),
          // previousProductProvider bisa digunakan jika Anda ingin mempertahankan state lama
          // tapi di sini kita buat instance baru dengan AuthProvider yang terupdate
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-nest Admin', // Judul aplikasi bisa diubah
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA16C22)),
        useMaterial3: true,
        textTheme: GoogleFonts.crimsonProTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor:
            Colors.white, // Atur default scaffold background
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          if (auth.isInitializing) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFFA16C22)),
              ),
            );
          } else if (auth.isAuthenticated) {
            return const MainLayoutScreen(); // Arahkan ke MainLayoutScreen
          } else {
            return const LoginScreen();
          }
        },
      ),
      routes: {AddProductScreen.routeName: (ctx) => const AddProductScreen()},
    );
  }
}
