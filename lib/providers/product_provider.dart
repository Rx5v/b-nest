// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/services/product_service.dart';
import 'package:admin_batik/providers/auth_provider.dart';

class ProductProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  bool _isLoading = false; // Untuk fetching list
  bool _isSubmitting = false; // Untuk status add/update product
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalProducts = 0;

  ProductProvider(this.authProvider);

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting; // Mengganti isAddingProduct
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get lastPage => _lastPage;
  bool get hasMoreProducts => _currentPage < _lastPage;

  Future<void> fetchProducts({bool refresh = false}) async {
    // ... (method fetchProducts yang sudah ada)
    if (authProvider.token == null) {
      _errorMessage = "Authentication token not found.";
      notifyListeners();
      return;
    }
    if (refresh) {
      _currentPage = 1;
      _products = [];
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _productService.getProducts(
        authProvider.token!,
        page: _currentPage,
      );
      if (response['meta']['success'] == true && response['data'] != null) {
        final List<dynamic> productDataList = response['data']['data'] ?? [];
        final List<ProductModel> fetchedProducts =
            productDataList
                .map(
                  (data) => ProductModel.fromJson(data as Map<String, dynamic>),
                )
                .toList();
        if (refresh) {
          _products = fetchedProducts;
        } else {
          _products.addAll(fetchedProducts);
        }
        _currentPage = response['data']['current_page'] ?? _currentPage;
        _lastPage = response['data']['last_page'] ?? _lastPage;
        _totalProducts = response['data']['total'] ?? _totalProducts;
      } else {
        _errorMessage =
            response['meta']['message'] ?? 'Failed to load products data.';
      }
    } catch (e) {
      _errorMessage = 'An error occurred while fetching products: $e';
      print(_errorMessage);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    // ... (method loadMoreProducts yang sudah ada)
    if (hasMoreProducts && !_isLoading) {
      _currentPage++;
      await fetchProducts();
    }
  }

  Future<bool> addProduct(Map<String, dynamic> productData) async {
    if (authProvider.token == null) {
      _errorMessage = "Authentication token not found.";
      notifyListeners();
      return false;
    }
    _isSubmitting = true; // Menggunakan _isSubmitting
    _errorMessage = null;
    notifyListeners();
    bool success = false;
    try {
      final response = await _productService.addProduct(
        authProvider.token!,
        productData,
      );
      if (response['meta']['success'] == true) {
        await fetchProducts(refresh: true);
        success = true;
      } else {
        _errorMessage = response['meta']['message'] ?? 'Failed to add product.';
        success = false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while adding product: $e';
      print(_errorMessage);
      success = false;
    }
    _isSubmitting = false; // Menggunakan _isSubmitting
    notifyListeners();
    return success;
  }

  Future<bool> updateProduct(
    int productId,
    Map<String, dynamic> productData,
  ) async {
    if (authProvider.token == null) {
      _errorMessage = "Authentication token not found.";
      notifyListeners();
      return false;
    }

    _isSubmitting = true; // Menggunakan _isSubmitting
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      final response = await _productService.updateProduct(
        authProvider.token!,
        productId,
        productData,
      );
      if (response['meta']['success'] == true) {
        // Produk berhasil diupdate
        // Refresh daftar produk untuk menampilkan perubahan
        await fetchProducts(refresh: true);
        success = true;
      } else {
        _errorMessage =
            response['meta']['message'] ?? 'Failed to update product.';
        success = false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while updating product: $e';
      print(_errorMessage);
      success = false;
    }

    _isSubmitting = false; // Menggunakan _isSubmitting
    notifyListeners();
    return success;
  }
}
