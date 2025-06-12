// lib/providers/auth_provider.dart
import 'dart:convert'; // Untuk jsonEncode dan jsonDecode
import 'package:flutter/material.dart';
import 'package:admin_batik/services/auth_service.dart';
import 'package:admin_batik/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage(); // Inisialisasi secure storage
  static const String _tokenKey = 'authToken'; // Kunci untuk token
  static const String _userKey = 'currentUser'; // Kunci untuk data pengguna

  String? _token;
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false; // Untuk status loading login/auto-login
  bool _isInitializing = true; // Untuk status inisialisasi _tryAutoLogin

  String? get token => _token;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  bool get isInitializing =>
      _isInitializing; // Getter untuk status inisialisasi
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _tryAutoLogin();
  }
  Future<void> _tryAutoLogin() async {
    _isInitializing = true;
    notifyListeners();

    // 1. Definisikan future untuk pengecekan otentikasi
    Future<void> authCheckFuture = Future(() async {
      try {
        final storedToken = await _storage.read(key: _tokenKey);
        final storedUserJson = await _storage.read(key: _userKey);

        if (storedToken != null && storedUserJson != null) {
          _token = storedToken;
          _currentUser = UserModel.fromJson(
            jsonDecode(storedUserJson) as Map<String, dynamic>,
          );
          _isAuthenticated = true;
        } else {
          _isAuthenticated = false;
        }
      } catch (e) {
        print("Error during auto login auth check: $e");
        _isAuthenticated = false;
      }
    });

    // 2. Definisikan future untuk durasi minimum splash screen
    Future<void> splashDelayFuture = Future.delayed(
      const Duration(seconds: 3),
    ); // Durasi 3 detik

    // 3. Tunggu kedua future selesai
    await Future.wait([authCheckFuture, splashDelayFuture]);

    // 4. Setelah keduanya selesai, baru hentikan inisialisasi
    _isInitializing = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.login(email, password);

    if (result['meta'] != null && result['meta']['success'] == true) {
      final data = result['data'];
      if (data != null && data['token'] != null && data['user'] != null) {
        _token = data['token'] as String;
        _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        _isAuthenticated = true;

        try {
          await _storage.write(key: _tokenKey, value: _token);
          await _storage.write(
            key: _userKey,
            value: jsonEncode(_currentUser!.toJson()),
          );
        } catch (e) {
          print("Error saving to secure storage: $e");
          // Pertimbangkan bagaimana menangani error penyimpanan ini
          // Mungkin logout atau tampilkan pesan error?
        }

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            result['meta']['message'] ??
            'Login successful, but data is missing.';
      }
    } else {
      _errorMessage =
          result['meta']?['message'] ?? result['message'] ?? 'Login failed.';
    }

    _isAuthenticated = false;
    _currentUser = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    _isAuthenticated = false;
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
    } catch (e) {
      print("Error deleting from secure storage: $e");
    }
    notifyListeners();
  }

  void handleTokenExpired() {
    print("Token expired, logging out.");
    logout(); // Logout akan menghapus data dari secure storage juga
  }
}
