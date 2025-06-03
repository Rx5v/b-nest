// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:admin_batik/services/auth_service.dart';
// In a real app, you'd use flutter_secure_storage or similar for tokens
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  // final _storage = const FlutterSecureStorage(); // For token storage

  String? _token;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    // In a real app, you would try to load the token from secure storage
    // final storedToken = await _storage.read(key: 'authToken');
    // if (storedToken != null) {
    //   // You might want to validate the token with the backend here
    //   _token = storedToken;
    //   _isAuthenticated = true;
    //   notifyListeners();
    // }
    // For this example, we'll assume no auto-login without a token mechanism.
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.login(email, password);

    if (result['success']) {
      // In a real app, the token would come from result['data']['token'] or similar
      // _token = result['data']['token'];
      // await _storage.write(key: 'authToken', value: _token); // Store token
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          result['message'] ?? 'Login failed due to an unknown error.';
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    // await _storage.delete(key: 'authToken'); // Clear token from storage
    notifyListeners();
    // Potentially notify the backend about logout
  }

  // This method would be called if an API call fails due to an expired token
  void handleTokenExpired() {
    print("Token expired, logging out.");
    logout();
  }
}
