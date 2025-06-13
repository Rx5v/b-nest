// lib/models/transaction_model.dart
import 'package:admin_batik/models/transaction_detail_model.dart';
// Jika Anda ingin menampilkan info user, Anda perlu model User
// import 'package:admin_batik/models/user_model.dart';

class TransactionModel {
  final int id;
  final String code;
  final int userId;
  final DateTime transactionDate;
  final String type;
  final num shippingCost;
  final int totalItems;
  final num totalPrice;
  final String? customerNotes;
  final String? adminNotes;
  final String shippingLocation;
  final String? imagePayment;
  final num amountPaid;
  final num changeReturned;
  final String methodDelivery;
  final String orderStatus;
  final String paymentStatus;
  final List<TransactionDetailModel> details;
  // Tambahkan field user jika API mengirimkannya dan Anda punya UserModel
  // final UserModel? user;

  TransactionModel({
    required this.id,
    required this.code,
    required this.userId,
    required this.transactionDate,
    required this.type,
    required this.shippingCost,
    required this.totalItems,
    required this.totalPrice,
    this.customerNotes,
    this.adminNotes,
    required this.shippingLocation,
    this.imagePayment,
    required this.amountPaid,
    required this.changeReturned,
    required this.methodDelivery,
    required this.orderStatus,
    required this.paymentStatus,
    required this.details,
    // this.user,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    var detailList =
        (json['details'] as List<dynamic>?)
            ?.map(
              (d) => TransactionDetailModel.fromJson(d as Map<String, dynamic>),
            )
            .toList() ??
        [];

    return TransactionModel(
      id: json['id'],
      code: json['code'],
      userId: json['user_id'],
      transactionDate: DateTime.parse(json['transaction_date']),
      type: json['type'],
      shippingCost: json['shipping_cost'],
      totalItems: json['total_items'],
      totalPrice: json['total_price'],
      customerNotes: json['customer_notes'],
      adminNotes: json['admin_notes'],
      shippingLocation: json['shipping_location'],
      imagePayment: json['image_payment'],
      amountPaid: json['amount_paid'],
      changeReturned: json['change_returned'],
      methodDelivery: json['method_delivery'],
      orderStatus: json['order_status'],
      paymentStatus: json['payment_status'],
      details: detailList,
      // user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
