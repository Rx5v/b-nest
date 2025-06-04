// lib/screen/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Anda bisa menggunakan warna tema utama aplikasi Anda di sini
      backgroundColor: const Color(0xFFA16C22), // Contoh: Warna primer tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Jika Anda punya logo, Anda bisa menampilkannya di sini:
            // Image.asset('assets/images/logo.png', width: 150, height: 150),
            // const SizedBox(height: 24),
            Text(
              'B-nest',
              style: GoogleFonts.croissantOne(
                // Font yang sama dengan di LoginScreen
                fontSize: 48,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
