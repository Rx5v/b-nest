// lib/models/transaction_detail_model.dart
import 'package:admin_batik/models/transaction_detail_image_model.dart';

class TransactionDetailModel {
  final int id;
  final String productName;
  final String productDescription;
  final String category;
  final String batikType;
  final String variantSize;
  final int quantity;
  final num price;
  final List<TransactionDetailImageModel> images;

  TransactionDetailModel({
    required this.id,
    required this.productName,
    required this.productDescription,
    required this.category,
    required this.batikType,
    required this.variantSize,
    required this.quantity,
    required this.price,
    required this.images,
  });

  factory TransactionDetailModel.fromJson(Map<String, dynamic> json) {
    var imageList =
        (json['images'] as List<dynamic>?)
            ?.map(
              (i) => TransactionDetailImageModel.fromJson(
                i as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];

    return TransactionDetailModel(
      id: json['id'],
      productName: json['prd_name'],
      productDescription: json['prd_description'],
      category: json['prd_category'],
      batikType: json['prd_batik_type'],
      variantSize: json['prd_variant_size'],
      quantity: json['quantity'],
      price: json['price'],
      images: imageList,
    );
  }
}
