// lib/models/product_model.dart

import 'package:admin_batik/models/product_image.dart';

class ProductModel {
  final int id;
  final String code;
  final String name;
  final String description;
  final num price;
  final String category;
  final String batikType;
  final String status;
  final int stock;
  final int? createdBy;
  final int? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ProductImageModel> images; // Ubah tipe data di sini
  final List<dynamic> variants;

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
    required this.images, // Diperbarui
    required this.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Helper untuk parsing list of image objects
    List<ProductImageModel> parseImages(dynamic imageList) {
      if (imageList is List) {
        return imageList
            .map(
              (data) =>
                  ProductImageModel.fromJson(data as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    }

    return ProductModel(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as num,
      category: json['category'] as String,
      batikType: json['batik_type'] as String,
      status: json['status'] as String,
      stock: json['stock'] as int,
      createdBy: json['created_by'] as int?,
      updatedBy: json['updated_by'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      images: parseImages(json['images']), // Diperbarui
      variants: json['variants'] as List<dynamic>? ?? [],
    );
  }

  double get priceAsDouble => price.toDouble();
}
