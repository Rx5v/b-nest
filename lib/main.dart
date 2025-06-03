// lib/main.dart
import 'package:admin_batik/screen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:admin_batik/screen/login.dart';
// import 'package:admin_batik/screen/dashboard_screen.dart';

void main() {
  runApp(const MyAppWrapper());
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-nest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFA16C22)),
        useMaterial3: true,
        textTheme: GoogleFonts.crimsonProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) {
          if (auth.isAuthenticated) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      // You can also define routes for more complex navigation
      // routes: {
      //   LoginScreen.routeName: (ctx) => const LoginScreen(),
      //   DashboardScreen.routeName: (ctx) => const DashboardScreen(),
      // },
    );
  }
}
