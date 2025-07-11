import 'package:v_store/models/product.dart';

class CartItem {
  Product product;
  int quantity;
  double subtotal;
  String? selectedSize;
  String? selectedColor;

  CartItem({
    required this.product,
    required this.quantity,
    this.selectedSize,
    this.selectedColor,
  }) : subtotal = _calculateSubtotal(product, quantity);

  static double _calculateSubtotal(Product product, int quantity) {
    double effectivePrice = product.price;

    if (product.discount != null && product.discount! > 0) {
      effectivePrice = product.price * (1 - product.discount! / 100);
    }

    return effectivePrice * quantity;
  }

  double get effectivePrice {
    if (product.discount != null && product.discount! > 0) {
      return product.price * (1 - product.discount! / 100);
    }
    return product.price;
  }

  void updateSubtotal() {
    subtotal = effectivePrice * quantity;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedSize: json['selectedSize'] as String?,
      selectedColor: json['selectedColor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'subtotal': subtotal,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }
}
