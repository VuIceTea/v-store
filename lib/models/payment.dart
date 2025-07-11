import 'package:cloud_firestore/cloud_firestore.dart';
import 'vietnamese_bank.dart';

class Payment {
  String paymentId;
  String orderId;
  double amount;
  String paymentMethod;
  String status;
  DateTime paymentDate;

  String? transactionId;
  String? gatewayResponse;
  DateTime? createdAt;
  DateTime? updatedAt;

  BankTransferInfo? bankTransferInfo;
  BankAccountInfo? customerBankAccount;

  Payment({
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
    this.transactionId,
    this.gatewayResponse,
    this.createdAt,
    this.updatedAt,
    this.bankTransferInfo,
    this.customerBankAccount,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'] as String,
      orderId: json['orderId'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      transactionId: json['transactionId'] as String?,
      gatewayResponse: json['gatewayResponse'] as String?,
      bankTransferInfo: json['bankTransferInfo'] != null
          ? BankTransferInfo.fromJson(json['bankTransferInfo'])
          : null,
      customerBankAccount: json['customerBankAccount'] != null
          ? BankAccountInfo.fromJson(json['customerBankAccount'])
          : null,
    );
  }

  factory Payment.fromFirestore(Map<String, dynamic> data) {
    return Payment(
      paymentId: data['paymentId'] ?? '',
      orderId: data['orderId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? '',
      paymentDate:
          (data['paymentDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionId: data['transactionId'],
      gatewayResponse: data['gatewayResponse'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      bankTransferInfo: data['bankTransferInfo'] != null
          ? BankTransferInfo.fromJson(data['bankTransferInfo'])
          : null,
      customerBankAccount: data['customerBankAccount'] != null
          ? BankAccountInfo.fromJson(data['customerBankAccount'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'paymentDate': paymentDate.toIso8601String(),
      'transactionId': transactionId,
      'gatewayResponse': gatewayResponse,
      'bankTransferInfo': bankTransferInfo?.toJson(),
      'customerBankAccount': customerBankAccount?.toJson(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'transactionId': transactionId,
      'gatewayResponse': gatewayResponse,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'bankTransferInfo': bankTransferInfo?.toJson(),
      'customerBankAccount': customerBankAccount?.toJson(),
    };
  }

  bool get isBankTransfer => paymentMethod == 'bank_transfer';
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  String get paymentMethodDisplayName {
    switch (paymentMethod) {
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'credit_card':
        return 'Thẻ tín dụng';
      case 'debit_card':
        return 'Thẻ ghi nợ';
      case 'e_wallet':
        return 'Ví điện tử';
      default:
        return paymentMethod;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'processing':
        return 'Đang xử lý';
      case 'completed':
        return 'Đã thanh toán';
      case 'failed':
        return 'Thất bại';
      case 'cancelled':
        return 'Đã hủy';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return status;
    }
  }

  Payment copyWith({
    String? paymentId,
    String? orderId,
    double? amount,
    String? paymentMethod,
    String? status,
    DateTime? paymentDate,
    String? transactionId,
    String? gatewayResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    BankTransferInfo? bankTransferInfo,
    BankAccountInfo? customerBankAccount,
  }) {
    return Payment(
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      paymentDate: paymentDate ?? this.paymentDate,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      bankTransferInfo: bankTransferInfo ?? this.bankTransferInfo,
      customerBankAccount: customerBankAccount ?? this.customerBankAccount,
    );
  }

  @override
  String toString() =>
      'Payment{paymentId: $paymentId, orderId: $orderId, amount: $amount, paymentMethod: $paymentMethod, status: $status}';
}
