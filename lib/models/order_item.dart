import 'package:v_store/models/cart_item.dart';

class OrderItem {
  String productId;
  String productName;
  String productImage;
  double productPrice;
  double productDiscount;
  double discountedPrice;
  String? selectedSize;
  String? selectedColor;
  int quantity;
  double subtotal;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productPrice,
    this.productDiscount = 0,
    required this.discountedPrice,
    this.selectedSize,
    this.selectedColor,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromCartItem(CartItem cartItem) {
    final discountedPrice = cartItem.product.caculateDiscountedPrice();
    return OrderItem(
      productId: cartItem.product.productId,
      productName: cartItem.product.name,
      productImage: cartItem.product.imageUrl,
      productPrice: cartItem.product.price,
      productDiscount: cartItem.product.discount ?? 0,
      discountedPrice: discountedPrice,
      selectedSize: cartItem.selectedSize,
      selectedColor: cartItem.selectedColor,
      quantity: cartItem.quantity,
      subtotal: discountedPrice * cartItem.quantity,
    );
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      productImage: map['productImage'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      productDiscount: (map['productDiscount'] ?? 0).toDouble(),
      discountedPrice: (map['discountedPrice'] ?? 0).toDouble(),
      selectedSize: map['selectedSize'],
      selectedColor: map['selectedColor'],
      quantity: map['quantity'] ?? 0,
      subtotal: (map['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'productPrice': productPrice,
      'productDiscount': productDiscount,
      'discountedPrice': discountedPrice,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      OrderItem.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
