// lib/providers/variant_provider.dart
import 'package:flutter/material.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/models/variant_model.dart';
import 'package:admin_batik/providers/auth_provider.dart';
import 'package:admin_batik/services/product_service.dart';
import 'package:admin_batik/services/variant_service.dart';

class VariantProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final VariantService _variantService = VariantService();
  final ProductService _productService = ProductService();

  List<VariantModel> _variants = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<VariantModel> _variantsForProduct = [];
  bool _isLoadingProductVariants = false;

  List<VariantModel> get variantsForProduct => _variantsForProduct;
  bool get isLoadingProductVariants => _isLoadingProductVariants;

  VariantProvider(this.authProvider);

  List<VariantModel> get variants => _variants;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchVariants() async {
    if (authProvider.token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _variantService.getVariants(authProvider.token!);
      if (response['meta']['success'] == true) {
        final List<dynamic> variantData = response['data'] ?? [];
        _variants =
            variantData.map((data) => VariantModel.fromJson(data)).toList();
        _errorMessage = null;
      } else {
        _errorMessage = response['meta']['message'];
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Method untuk searchable dropdown
  Future<List<ProductModel>> findProducts(String filter) async {
    if (authProvider.token == null) return [];

    // Tidak ada lagi filter di sisi klien.
    // Langsung panggil service dengan filter/query dari dropdown.
    try {
      final products = await _productService.findProducts(
        authProvider.token!,
        filter,
      );
      return products;
    } catch (e) {
      print("Error finding products from provider: $e");
      // Anda bisa menangani error di sini, misal dengan menampilkan pesan
      _errorMessage = e.toString();
      notifyListeners();
      return []; // Kembalikan list kosong jika error
    }
  }

  Future<void> fetchVariantsForProduct(int productId) async {
    if (authProvider.token == null) return;
    _isLoadingProductVariants = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _variantService.getVariantsForProduct(
        authProvider.token!,
        productId,
      );
      if (response['meta']['success'] == true) {
        final List<dynamic> variantData = response['data'] ?? [];
        _variantsForProduct =
            variantData.map((data) => VariantModel.fromJson(data)).toList();
      } else {
        _errorMessage = response['meta']['message'];
        _variantsForProduct = []; // Kosongkan jika error
      }
    } catch (e) {
      _errorMessage = e.toString();
      _variantsForProduct = []; // Kosongkan jika error
    }
    _isLoadingProductVariants = false;
    notifyListeners();
  }

  // Override addVariant agar bisa me-refresh halaman detail
  Future<Map<String, dynamic>> addVariant(Map<String, String> fields) async {
    if (authProvider.token == null) {
      return {'success': false, 'message': 'Authentication token not found.'};
    }

    _isLoading = true; // Bisa diganti dengan _isSubmitting jika ada
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _variantService.addVariant(
        authProvider.token!,
        fields,
      );

      if (response['meta'] != null && response['meta']['success'] == true) {
        // HAPUS PANGGILAN REFRESH DARI SINI
        _isLoading = false;
        notifyListeners();
        return {'success': true};
      } else {
        _errorMessage =
            response['meta']?['message'] ?? 'Failed to add variant.';
        final errorData = response['data']?['error'];
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'errors': errorData};
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }

  Future<Map<String, dynamic>> updateVariant(
    int variantId,
    Map<String, String> fields,
  ) async {
    if (authProvider.token == null) {
      return {'success': false, 'message': 'Authentication token not found.'};
    }

    _isLoading = true; // Bisa pakai state loading spesifik jika perlu
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _variantService.updateVariant(
        authProvider.token!,
        variantId,
        fields,
      );

      if (response['meta'] != null && response['meta']['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return {'success': true}; // Kembalikan sinyal sukses
      } else {
        _errorMessage =
            response['meta']?['message'] ?? 'Failed to update variant.';
        final errorData = response['data']?['error'];
        _isLoading = false;
        notifyListeners();
        return {'success': false, 'errors': errorData};
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': _errorMessage};
    }
  }
}
