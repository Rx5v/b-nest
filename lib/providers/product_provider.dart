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
    print(_isLoading);
    notifyListeners();
  }

  Future<void> loadMoreProducts() async {
    // ... (method loadMoreProducts yang sudah ada)
    if (hasMoreProducts && !_isLoading) {
      _currentPage++;
      await fetchProducts();
    }
  }

  Future<bool> addProduct(
    Map<String, String> productFields,
    List<String> imagePaths,
  ) async {
    if (authProvider.token == null) {
      _errorMessage = "Authentication token not found.";
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      final response = await _productService.addProduct(
        authProvider.token!,
        productFields,
        imagePaths,
      );
      if (response['meta']['success'] == true) {
        await fetchProducts(refresh: true);
        success = true;
      } else {
        // Cek jika ada error validasi dari backend
        if (response['data'] != null && response['data'] is Map) {
          print(response['data']);
          final errors = response['data'] as Map<String, dynamic>;
          _errorMessage = errors.values.map((e) => e.join('\n')).join('\n');
        } else {
          _errorMessage =
              response['meta']['message'] ?? 'Failed to add product.';
        }
        success = false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while adding product: $e';
      print(_errorMessage);
      success = false;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> updateProduct(
    int productId,
    Map<String, String> productFields,
    List<String> newImagePaths,
  ) async {
    if (authProvider.token == null) {
      _errorMessage = "Authentication token not found.";
      notifyListeners();
      return false;
    }

    _isSubmitting = true; // Gunakan flag ini untuk loading di UI
    _errorMessage = null;
    notifyListeners();

    bool success = false;
    try {
      final response = await _productService.updateProduct(
        authProvider.token!,
        productId,
        productFields,
        newImagePaths,
      );
      if (response['meta']['success'] == true) {
        // Produk berhasil diupdate
        // Refresh daftar produk untuk menampilkan perubahan
        await fetchProducts(refresh: true);
        success = true;
      } else {
        // ... (penanganan error)
        if (response['data'] != null && response['data'] is Map) {
          final errors = response['data'] as Map<String, dynamic>;
          _errorMessage = errors.values.map((e) => e.join('\n')).join('\n');
        } else {
          _errorMessage =
              response['meta']['message'] ?? 'Failed to update product.';
        }
        success = false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred while updating product: $e';
      print(_errorMessage);
      success = false;
    }

    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  Future<bool> deleteProduct(int productId) async {
    if (authProvider.token == null) {
      _errorMessage = "Authentication token not found.";
      notifyListeners();
      return false;
    }

    // Simpan produk yang akan dihapus, untuk jaga-jaga jika gagal
    final existingProductIndex = _products.indexWhere(
      (prod) => prod.id == productId,
    );
    if (existingProductIndex == -1) return false; // Produk tidak ditemukan

    var existingProduct = _products[existingProductIndex];

    // Hapus dari UI terlebih dahulu untuk respons cepat (Optimistic Deleting)
    _products.removeAt(existingProductIndex);
    notifyListeners();

    try {
      final response = await _productService.deleteProduct(
        authProvider.token!,
        productId,
      );
      if (response['meta']['success'] == true) {
        // Sukses, tidak perlu melakukan apa-apa karena UI sudah diupdate
        return true;
      } else {
        // Jika gagal, kembalikan produk yang dihapus ke list dan tampilkan error
        _errorMessage =
            response['meta']['message'] ?? 'Failed to delete product.';
        _products.insert(existingProductIndex, existingProduct);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _products.insert(
        existingProductIndex,
        existingProduct,
      ); // Kembalikan jika error
      notifyListeners();
      return false;
    }
  }
}
