import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:v_store/models/payment.dart';
import 'package:v_store/models/order.dart' as order_model;

class PaymentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<String> createPayment({
    required order_model.Order order,
    required String paymentMethod,
    String status = 'completed',
    String? transactionId,
    String? gatewayResponse,
  }) async {
    try {
      final paymentId = 'PAY_${DateTime.now().millisecondsSinceEpoch}';

      final payment = Payment(
        paymentId: paymentId,
        orderId: order.orderId,
        amount: order.pricing.total,
        paymentMethod: paymentMethod,
        status: status,
        paymentDate: DateTime.now(),
        transactionId: transactionId,
        gatewayResponse: gatewayResponse,
      );

      await _firestore
          .collection('payments')
          .doc(paymentId)
          .set(payment.toFirestore());

      print('✅ Payment $paymentId đã được tạo thành công');
      return paymentId;
    } catch (e) {
      print('❌ Lỗi khi tạo payment: $e');
      throw Exception('Không thể tạo payment: $e');
    }
  }

  static Future<void> updatePaymentStatus(
    String paymentId,
    String status,
  ) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Đã cập nhật trạng thái payment $paymentId thành $status');
    } catch (e) {
      print('❌ Lỗi khi cập nhật trạng thái payment: $e');
      throw Exception('Không thể cập nhật trạng thái payment: $e');
    }
  }

  static Future<Payment?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return Payment.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy payment: $e');
      return null;
    }
  }

  static Future<List<Payment>> getPaymentsByOrderId(String orderId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('order.orderId', isEqualTo: orderId)
          .get();

      return snapshot.docs
          .map((doc) => Payment.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy payments cho order $orderId: $e');
      return [];
    }
  }

  static Future<List<Payment>> getPayments({
    int limit = 20,
    String? status,
  }) async {
    try {
      Query query = _firestore
          .collection('payments')
          .orderBy('paymentDate', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => Payment.fromFirestore(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('❌ Lỗi khi lấy danh sách payments: $e');
      return [];
    }
  }

  static Future<void> processRefund(String paymentId, String reason) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': 'refunded',
        'refundReason': reason,
        'refundDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Đã xử lý hoàn tiền cho payment $paymentId');
    } catch (e) {
      print('❌ Lỗi khi xử lý hoàn tiền: $e');
      throw Exception('Không thể xử lý hoàn tiền: $e');
    }
  }

  static Future<Map<String, dynamic>> getPaymentStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection('payments');

      if (startDate != null) {
        query = query.where(
          'paymentDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'paymentDate',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final snapshot = await query.get();
      final payments = snapshot.docs
          .map(
            (doc) => Payment.fromFirestore(doc.data() as Map<String, dynamic>),
          )
          .toList();

      double totalAmount = 0;
      int totalCount = payments.length;
      Map<String, int> methodCounts = {};
      Map<String, int> statusCounts = {};

      for (final payment in payments) {
        totalAmount += payment.amount;
        methodCounts[payment.paymentMethod] =
            (methodCounts[payment.paymentMethod] ?? 0) + 1;
        statusCounts[payment.status] = (statusCounts[payment.status] ?? 0) + 1;
      }

      return {
        'totalAmount': totalAmount,
        'totalCount': totalCount,
        'methodCounts': methodCounts,
        'statusCounts': statusCounts,
        'averageAmount': totalCount > 0 ? totalAmount / totalCount : 0,
      };
    } catch (e) {
      print('❌ Lỗi khi lấy thống kê payments: $e');
      return {};
    }
  }
}
