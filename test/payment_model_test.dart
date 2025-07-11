import 'package:flutter_test/flutter_test.dart';
import 'package:v_store/models/payment.dart';

void main() {
  group('Payment Model Tests', () {
    test('Payment model should create instance correctly', () {
      // Arrange
      final payment = Payment(
        paymentId: 'PAY_123456789',
        orderId: 'ORD_987654321',
        amount: 100000.0,
        paymentMethod: 'momo',
        status: 'completed',
        paymentDate: DateTime.now(),
        transactionId: 'TXN_111222333',
        gatewayResponse: 'Success',
      );

      // Assert
      expect(payment.paymentId, 'PAY_123456789');
      expect(payment.orderId, 'ORD_987654321');
      expect(payment.amount, 100000.0);
      expect(payment.paymentMethod, 'momo');
      expect(payment.status, 'completed');
      expect(payment.transactionId, 'TXN_111222333');
      expect(payment.gatewayResponse, 'Success');
    });

    test('Payment should convert to/from Firestore correctly', () {
      // Arrange
      final payment = Payment(
        paymentId: 'PAY_123456789',
        orderId: 'ORD_987654321',
        amount: 100000.0,
        paymentMethod: 'momo',
        status: 'completed',
        paymentDate: DateTime(2025, 1, 1, 12, 0, 0),
        transactionId: 'TXN_111222333',
        gatewayResponse: 'Success',
      );

      // Act
      final firestoreData = payment.toFirestore();

      // Assert
      expect(firestoreData['paymentId'], 'PAY_123456789');
      expect(firestoreData['orderId'], 'ORD_987654321');
      expect(firestoreData['amount'], 100000.0);
      expect(firestoreData['paymentMethod'], 'momo');
      expect(firestoreData['status'], 'completed');
      expect(firestoreData['transactionId'], 'TXN_111222333');
      expect(firestoreData['gatewayResponse'], 'Success');
    });

    test('Payment should convert to/from JSON correctly', () {
      // Arrange
      final payment = Payment(
        paymentId: 'PAY_123456789',
        orderId: 'ORD_987654321',
        amount: 100000.0,
        paymentMethod: 'momo',
        status: 'completed',
        paymentDate: DateTime(2025, 1, 1, 12, 0, 0),
        transactionId: 'TXN_111222333',
        gatewayResponse: 'Success',
      );

      // Act
      final json = payment.toJson();
      final reconstructed = Payment.fromJson(json);

      // Assert
      expect(reconstructed.paymentId, payment.paymentId);
      expect(reconstructed.orderId, payment.orderId);
      expect(reconstructed.amount, payment.amount);
      expect(reconstructed.paymentMethod, payment.paymentMethod);
      expect(reconstructed.status, payment.status);
      expect(reconstructed.transactionId, payment.transactionId);
      expect(reconstructed.gatewayResponse, payment.gatewayResponse);
      expect(
        reconstructed.paymentDate.toIso8601String(),
        payment.paymentDate.toIso8601String(),
      );
    });
  });
}
