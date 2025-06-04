// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import 'package:admin_batik/models/product_model.dart';
import 'package:admin_batik/services/product_service.dart';
import 'package:admin_batik/providers/auth_provider.dart';

class ProductProvider with ChangeNotifier {
  final AuthProvider authProvider;
  final ProductService _productService =
      ProductService(); // Inisialisasi di sini

  List<ProductModel> _products = [];
  bool _isLoading = false; // Untuk fetching list
  bool _isAddingProduct = false; // Untuk status add product
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  int _totalProducts = 0;

  ProductProvider(this.authProvider);

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get isAddingProduct => _isAddingProduct; // Getter untuk status add
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

    _isAddingProduct = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      final response = await _productService.addProduct(
        authProvider.token!,
        productData,
      );
      if (response['meta']['success'] == true) {
        // Produk berhasil ditambahkan
        // Refresh daftar produk untuk menampilkan produk baru
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

    _isAddingProduct = false;
    notifyListeners();
    return success;
  }
}
