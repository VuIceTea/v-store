import 'package:flutter_test/flutter_test.dart';
import 'package:v_store/models/order.dart' as order_model;
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/models/category.dart';

void main() {
  group('Order Model Tests', () {
    test('Order.fromCartItems should create valid order', () {
      // Create mock cart item
      final category = Categories(
        categoryId: 'CAT_001',
        name: 'Thời trang',
        imageUrl: 'https://example.com/category.jpg',
      );

      final product = Product(
        productId: 'TEST_001',
        name: 'Test Product',
        category: category,
        price: 100000,
        imageUrl: 'https://example.com/image.jpg',
        stockQuantity: 10,
      );

      final cartItem = CartItem(
        product: product,
        quantity: 2,
        selectedSize: 'L',
        selectedColor: 'Xanh',
      );

      // Create order from cart items
      final order = order_model.Order.fromCartItems(
        items: [cartItem],
        paymentMethod: 'cod',
        deliveryAddressMap: {
          'name': 'Nguyễn Văn A',
          'phone': '0123456789',
          'address': '123 Test Street',
        },
        subtotal: 200000,
        shippingFee: 30000,
        discountAmount: 20000,
        total: 210000,
        discountCode: 'TEST10',
      );

      // Verify order properties
      expect(order.orderId, startsWith('ORD_'));
      expect(order.status, equals('pending'));
      expect(order.paymentMethod, equals('cod'));
      expect(order.paymentStatus, equals('pending'));
      expect(order.deliveryAddress.customerName, equals('Nguyễn Văn A'));
      expect(order.pricing.total, equals(210000));
      expect(order.items.length, equals(1));
      expect(order.itemCount, equals(1));
      expect(order.totalQuantity, equals(2));
    });

    test('Order.toFirestore should create valid Firestore data', () {
      final order = order_model.Order(
        orderId: 'ORD_TEST_123',
        paymentMethod: 'momo',
        deliveryAddress: order_model.DeliveryAddress(
          customerName: 'Test User',
          phone: '0987654321',
          address: 'Test Address',
        ),
        pricing: order_model.OrderPricing(
          subtotal: 500000,
          shippingFee: 0,
          discountAmount: 50000,
          total: 450000,
        ),
        items: [],
        itemCount: 0,
        totalQuantity: 0,
      );

      final firestoreData = order.toFirestore();

      expect(firestoreData['orderId'], equals('ORD_TEST_123'));
      expect(firestoreData['status'], equals('pending'));
      expect(firestoreData['paymentMethod'], equals('momo'));
      expect(
        firestoreData['deliveryAddress']['customerName'],
        equals('Test User'),
      );
      expect(firestoreData['pricing']['total'], equals(450000));
    });

    test('Order.fromFirestore should parse Firestore data correctly', () {
      final firestoreData = {
        'orderId': 'ORD_FIRESTORE_123',
        'status': 'confirmed',
        'paymentMethod': 'bank',
        'paymentStatus': 'paid',
        'deliveryAddress': {
          'customerName': 'Firestore User',
          'phone': '0111222333',
          'address': 'Firestore Address',
        },
        'pricing': {
          'subtotal': 300000.0,
          'shippingFee': 25000.0,
          'discountAmount': 0.0,
          'total': 325000.0,
          'currency': 'VND',
        },
        'items': [],
        'itemCount': 0,
        'totalQuantity': 0,
      };

      final order = order_model.Order.fromFirestore(firestoreData);

      expect(order.orderId, equals('ORD_FIRESTORE_123'));
      expect(order.status, equals('confirmed'));
      expect(order.paymentMethod, equals('bank'));
      expect(order.paymentStatus, equals('paid'));
      expect(order.deliveryAddress.customerName, equals('Firestore User'));
      expect(order.pricing.total, equals(325000));
    });
  });
}
