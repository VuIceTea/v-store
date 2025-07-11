import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/models/order.dart' as order_model;
import 'package:v_store/services/payment_service.dart';

class OrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lưu đơn hàng lên Firestore
  static Future<String> saveOrder({
    required List<CartItem> items,
    required String paymentMethod,
    required Map<String, String> deliveryAddress,
    required double subtotal,
    required double shippingFee,
    required double discountAmount,
    required double total,
    String? discountCode,
    String? userId,
  }) async {
    try {
      // Tạo Order object từ cart items
      final order = order_model.Order.fromCartItems(
        items: items,
        paymentMethod: paymentMethod,
        deliveryAddressMap: deliveryAddress,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discountAmount: discountAmount,
        total: total,
        discountCode: discountCode,
        userId: userId,
      );

      // Lưu vào Firestore sử dụng model
      await _firestore
          .collection('orders')
          .doc(order.orderId)
          .set(order.toFirestore());

      // Tạo payment record nếu thanh toán không phải COD
      if (order.paymentMethod != 'cod') {
        try {
          await PaymentService.createPayment(
            order: order,
            paymentMethod: order.paymentMethod,
            status: 'completed',
          );
        } catch (e) {
          print('⚠️ Không thể tạo payment record: $e');
          // Không ném lỗi vì order đã được lưu thành công
        }
      }

      print('✅ Đơn hàng ${order.orderId} đã được lưu thành công lên Firestore');
      return order.orderId;
    } catch (e) {
      print('❌ Lỗi khi lưu đơn hàng lên Firestore: $e');
      throw Exception('Không thể lưu đơn hàng: $e');
    }
  }

  /// Cập nhật trạng thái đơn hàng
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Đã cập nhật trạng thái đơn hàng $orderId thành $status');
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái đơn hàng: $e');
      throw Exception('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  /// Lấy danh sách đơn hàng của người dùng
  static Future<List<Map<String, dynamic>>> getUserOrders({
    int limit = 20,
    String? lastOrderId,
  }) async {
    try {
      Query query = _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(limit);

      if (lastOrderId != null) {
        final lastDoc = await _firestore
            .collection('orders')
            .doc(lastOrderId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách đơn hàng: $e');
      return [];
    }
  }

  /// Lấy danh sách đơn hàng dưới dạng Order objects
  static Future<List<order_model.Order>> getUserOrdersAsObjects({
    int limit = 20,
    String? lastOrderId,
  }) async {
    try {
      Query query = _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(limit);

      if (lastOrderId != null) {
        final lastDoc = await _firestore
            .collection('orders')
            .doc(lastOrderId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => order_model.Order.fromFirestore(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách đơn hàng: $e');
      return [];
    }
  }

  /// Lấy chi tiết đơn hàng theo ID
  static Future<Map<String, dynamic>?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy chi tiết đơn hàng: $e');
      return null;
    }
  }

  /// Lấy chi tiết đơn hàng theo ID dưới dạng Order object
  static Future<order_model.Order?> getOrderByIdAsObject(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return order_model.Order.fromFirestore(
          doc.data() as Map<String, dynamic>,
        );
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy chi tiết đơn hàng: $e');
      return null;
    }
  }

  /// Hủy đơn hàng
  static Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
        'cancelReason': reason,
        'cancelledAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Đã hủy đơn hàng $orderId');
    } catch (e) {
      print('❌ Lỗi khi hủy đơn hàng: $e');
      throw Exception('Không thể hủy đơn hàng: $e');
    }
  }

  /// Lấy danh sách đơn hàng dưới dạng Order objects cho user cụ thể
  static Future<List<order_model.Order>> getUserOrdersByUserId(
    String userId,
  ) async {
    try {
      // Thử query với sort trước
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => order_model.Order.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách đơn hàng user với sort: $e');
      // Fallback: lấy tất cả orders của user mà không sort, sau đó sort trong code
      try {
        final fallbackSnapshot = await _firestore
            .collection('orders')
            .where('userId', isEqualTo: userId)
            .get();

        final orders = fallbackSnapshot.docs
            .map((doc) => order_model.Order.fromFirestore(doc.data()))
            .toList();

        // Sort trong code thay vì Firestore
        orders.sort((a, b) {
          final dateA = a.createdAt ?? a.orderDate ?? DateTime.now();
          final dateB = b.createdAt ?? b.orderDate ?? DateTime.now();
          return dateB.compareTo(dateA); // Descending order
        });

        return orders;
      } catch (fallbackError) {
        print('❌ Lỗi fallback: $fallbackError');
        return [];
      }
    }
  }

  /// Kiểm tra xem người dùng đã mua sản phẩm hay chưa
  static Future<bool> hasUserPurchasedProduct(
    String userId,
    String productId,
  ) async {
    try {
      // Tìm kiếm các đơn hàng đã hoàn thành của user có chứa sản phẩm này
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', whereIn: ['completed', 'delivered', 'confirmed'])
          .get();

      // Kiểm tra từng đơn hàng xem có chứa sản phẩm không
      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        final items = orderData['items'] as List<dynamic>? ?? [];

        for (var item in items) {
          final itemProductId =
              item['product']?['productId'] ?? item['productId'];
          if (itemProductId == productId) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('❌ Lỗi khi kiểm tra đã mua sản phẩm: $e');
      return false;
    }
  }

  /// Cập nhật trạng thái thanh toán của đơn hàng
  static Future<void> updateOrderPaymentStatus(
    String orderId,
    String paymentStatus, {
    String? paymentMethod,
    Map<String, dynamic>? paymentData,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (paymentMethod != null) {
        updateData['paymentMethod'] = paymentMethod;
      }

      if (paymentData != null) {
        updateData['paymentData'] = paymentData;
      }

      // If payment is successful, also update order status
      if (paymentStatus == 'paid') {
        updateData['status'] = 'confirmed'; // Change from pending to confirmed
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);

      print(
        '✅ Đã cập nhật trạng thái thanh toán đơn hàng $orderId thành $paymentStatus',
      );
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái thanh toán: $e');
      rethrow;
    }
  }
}
