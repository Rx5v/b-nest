// lib/models/product_image_model.dart

class ProductImageModel {
  final int id;
  final int productId;
  final int sortOrder;
  final String imagePath; // Path relatif gambar, e.g., "products/BTK005/..."
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductImageModel({
    required this.id,
    required this.productId,
    required this.sortOrder,
    required this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      sortOrder: json['sort_order'] as int,
      imagePath: json['image'] as String, // Kunci di JSON adalah 'image'
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Helper untuk mendapatkan URL lengkap
  // Asumsi: URL storage sama dengan base URL API + '/storage/'
  String get fullImageUrl {
    const String storageBaseUrl =
        'http://10.0.2.2:8000/storage'; // Sesuaikan jika berbeda
    return '$storageBaseUrl/$imagePath';
  }
}
