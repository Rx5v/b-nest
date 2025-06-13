// lib/models/transaction_detail_image_model.dart
class TransactionDetailImageModel {
  final int id;
  final String imagePath;

  TransactionDetailImageModel({required this.id, required this.imagePath});

  factory TransactionDetailImageModel.fromJson(Map<String, dynamic> json) {
    return TransactionDetailImageModel(
      id: json['id'],
      imagePath: json['image'],
    );
  }

  String get fullImageUrl {
    const String storageBaseUrl = 'http://10.0.2.2:8000/storage';
    return '$storageBaseUrl/$imagePath';
  }
}
