// lib/models/variant_model.dart
import 'package:admin_batik/models/product_model.dart';

class VariantModel {
  final int id;
  final int productId;
  final String size;
  final int? length;
  final int? width;
  final String? material;
  final String? collarType;
  final String? sleeveType;
  final int stock;
  final ProductModel? product; // Untuk menampilkan info produk di list

  VariantModel({
    required this.id,
    required this.productId,
    required this.size,
    this.length,
    this.width,
    this.material,
    this.collarType,
    this.sleeveType,
    required this.stock,
    this.product,
  });

  // Asumsi struktur JSON dari API GET /product-variants
  factory VariantModel.fromJson(Map<String, dynamic> json) {
    return VariantModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      size: json['size'] as String,
      length: json['length'] as int,
      width: json['width'] as int?,
      material: json['material'] as String?,
      collarType: json['collar_type'] as String?,
      sleeveType: json['sleeve_type'] as String?,
      stock: json['stock'] as int,
      // Jika API menyertakan data produk, kita bisa langsung parse
      product:
          json['product'] != null
              ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
              : null,
    );
  }
}
