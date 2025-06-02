import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screen/login.dart'; // import halaman login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-nest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFA16C22)),
        useMaterial3: true,
        textTheme: GoogleFonts.crimsonProTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(), // set LoginScreen sebagai halaman pertama
    );
  }
}
