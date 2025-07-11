import 'package:v_store/models/cart_item.dart';
import 'package:v_store/models/customer.dart';

class Cart {
  String cartId;
  Customer customer;
  List<CartItem> items;
  double totalPrice;

  Cart({
    required this.cartId,
    required this.customer,
    required this.items,
    required this.totalPrice,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      cartId: json['cartId'] as String,
      customer: json['customer'] as Customer,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'customer': customer.userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }
}
