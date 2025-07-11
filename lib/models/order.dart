import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/models/order_item.dart';

class Order {
  String orderId;
  String? userId;
  DateTime? orderDate;
  String status;
  String paymentMethod;
  String paymentStatus;

  DeliveryAddress deliveryAddress;
  OrderPricing pricing;
  List<OrderItem> items;

  int itemCount;
  int totalQuantity;
  DateTime? createdAt;
  DateTime? updatedAt;

  String? cancelReason;
  DateTime? cancelledAt;

  Order({
    required this.orderId,
    this.userId,
    this.orderDate,
    this.status = 'pending',
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    required this.deliveryAddress,
    required this.pricing,
    required this.items,
    required this.itemCount,
    required this.totalQuantity,
    this.createdAt,
    this.updatedAt,
    this.cancelReason,
    this.cancelledAt,
  });

  String get id => orderId;
  double get totalAmount => pricing.total;

  factory Order.fromCartItems({
    required List<CartItem> items,
    required String paymentMethod,
    required Map<String, String> deliveryAddressMap,
    required double subtotal,
    required double shippingFee,
    required double discountAmount,
    required double total,
    String? discountCode,
    String? userId,
  }) {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';

    return Order(
      orderId: orderId,
      userId: userId,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'cod' ? 'pending' : 'paid',
      deliveryAddress: DeliveryAddress.fromMap(deliveryAddressMap),
      pricing: OrderPricing(
        subtotal: subtotal,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
        total: total,
        discountCode: discountCode,
      ),
      items: items.map((item) => OrderItem.fromCartItem(item)).toList(),
      itemCount: items.length,
      totalQuantity: items.fold<int>(0, (sum, item) => sum + item.quantity),
    );
  }

  factory Order.fromFirestore(Map<String, dynamic> data) {
    return Order(
      orderId: data['orderId'] ?? '',
      userId: data['userId'],
      orderDate: (data['orderDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? '',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      deliveryAddress: DeliveryAddress.fromMap(
        Map<String, String>.from(data['deliveryAddress'] ?? {}),
      ),
      pricing: OrderPricing.fromMap(
        Map<String, dynamic>.from(data['pricing'] ?? {}),
      ),
      items:
          (data['items'] as List<dynamic>?)
              ?.map(
                (item) => OrderItem.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          [],
      itemCount: data['itemCount'] ?? 0,
      totalQuantity: data['totalQuantity'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      cancelReason: data['cancelReason'],
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderId': orderId,
      if (userId != null) 'userId': userId,
      'orderDate': orderDate != null
          ? Timestamp.fromDate(orderDate!)
          : FieldValue.serverTimestamp(),
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress.toMap(),
      'pricing': pricing.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (cancelReason != null) 'cancelReason': cancelReason,
      if (cancelledAt != null) 'cancelledAt': Timestamp.fromDate(cancelledAt!),
    };
  }
}

class DeliveryAddress {
  String customerName;
  String phone;
  String address;

  DeliveryAddress({
    required this.customerName,
    required this.phone,
    required this.address,
  });

  factory DeliveryAddress.fromMap(Map<String, String> map) {
    return DeliveryAddress(
      customerName: map['name'] ?? map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {'customerName': customerName, 'phone': phone, 'address': address};
  }
}

class OrderPricing {
  double subtotal;
  double shippingFee;
  double discountAmount;
  double total;
  String currency;
  String? discountCode;

  OrderPricing({
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.total,
    this.currency = 'VND',
    this.discountCode,
  });

  factory OrderPricing.fromMap(Map<String, dynamic> map) {
    return OrderPricing(
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      currency: map['currency'] ?? 'VND',
      discountCode: map['discountCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'total': total,
      'currency': currency,
      if (discountCode != null) 'discountCode': discountCode,
    };
  }
}
