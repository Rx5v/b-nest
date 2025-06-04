// lib/models/product_model.dart

class ProductModel {
  final int id;
  final String code; // Sebelumnya productCode
  final String name;
  final String description;
  final num price; // API mengembalikan angka, bisa int atau double
  final String category; // Langsung string dari API
  final String batikType; // Sebelumnya subCategory, dari API 'batik_type'
  final String status; // Langsung string dari API, e.g., "Tersedia"
  final int stock;
  final int? createdBy; // Nullable
  final int? updatedBy; // Nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>
  images; // Berdasarkan API, ini list. Kita asumsikan list of URLs (string)
  final List<dynamic>
  variants; // Tipe data 'dynamic' karena strukturnya belum diketahui dari contoh

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.batikType,
    required this.status,
    required this.stock,
    this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk parsing list of strings untuk images
    List<String> parseImages(dynamic imageList) {
      if (imageList is List) {
        return imageList
            .map((e) => e.toString())
            .toList(); // Asumsikan tiap elemen adalah URL (String)
      }
      return [];
    }

    return ProductModel(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price:
          json['price']
              as num, // Biarkan sebagai num, bisa di-convert ke double jika perlu
      category: json['category'] as String,
      batikType: json['batik_type'] as String,
      status: json['status'] as String, // e.g. "Tersedia"
      stock: json['stock'] as int,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      images: parseImages(json['images']),
      variants:
          json['variants'] as List<dynamic>? ??
          [], // Jika null, jadikan list kosong
    );
  }

  // toJson bisa disesuaikan jika Anda perlu mengirim objek ProductModel kembali ke API
  // Untuk saat ini, fokus utama adalah fromJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'batik_type': batikType,
      'status': status,
      'stock': stock,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'images': images,
      'variants': variants,
    };
  }

  // Helper getter untuk UI, jika ingin tetap menggunakan 'availabilityStatus'
  // atau untuk logika berdasarkan 'status' string.
  String get availabilityStatusForUI {
    // Anda bisa menambahkan logika di sini jika 'status' dari API
    // perlu di-map ke string yang berbeda untuk UI.
    // Contoh sederhana:
    return status; // Langsung gunakan string status dari API
  }

  // Helper getter untuk harga sebagai double
  double get priceAsDouble => price.toDouble();
}
