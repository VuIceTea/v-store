class VietnameseBank {
  final String id;
  final String name;
  final String shortName;
  final String logoUrl;
  final String color;
  final bool isActive;

  const VietnameseBank({
    required this.id,
    required this.name,
    required this.shortName,
    required this.logoUrl,
    required this.color,
    this.isActive = true,
  });

  factory VietnameseBank.fromJson(Map<String, dynamic> json) {
    return VietnameseBank(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      shortName: json['shortName'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      color: json['color'] ?? '#1976d2',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'logoUrl': logoUrl,
      'color': color,
      'isActive': isActive,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietnameseBank &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VietnameseBank{id: $id, name: $name, shortName: $shortName}';
}

class BankAccountInfo {
  final String bankId;
  final String accountNumber;
  final String accountHolderName;
  final String? branch;
  final String? swiftCode;

  const BankAccountInfo({
    required this.bankId,
    required this.accountNumber,
    required this.accountHolderName,
    this.branch,
    this.swiftCode,
  });

  factory BankAccountInfo.fromJson(Map<String, dynamic> json) {
    return BankAccountInfo(
      bankId: json['bankId'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      branch: json['branch'],
      swiftCode: json['swiftCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankId': bankId,
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'branch': branch,
      'swiftCode': swiftCode,
    };
  }

  @override
  String toString() =>
      'BankAccountInfo{bankId: $bankId, accountNumber: $accountNumber, accountHolderName: $accountHolderName}';
}

class BankTransferInfo {
  final String orderId;
  final double amount;
  final String currency;
  final BankAccountInfo recipientAccount;
  final String transferContent;
  final DateTime createdAt;
  final BankTransferStatus status;
  final String? transactionId;
  final String? confirmationCode;
  final DateTime? confirmedAt;
  final String? notes;

  const BankTransferInfo({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.recipientAccount,
    required this.transferContent,
    required this.createdAt,
    required this.status,
    this.transactionId,
    this.confirmationCode,
    this.confirmedAt,
    this.notes,
  });

  factory BankTransferInfo.fromJson(Map<String, dynamic> json) {
    return BankTransferInfo(
      orderId: json['orderId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      recipientAccount: BankAccountInfo.fromJson(
        json['recipientAccount'] ?? {},
      ),
      transferContent: json['transferContent'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      status: BankTransferStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => BankTransferStatus.pending,
      ),
      transactionId: json['transactionId'],
      confirmationCode: json['confirmationCode'],
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['confirmedAt'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'recipientAccount': recipientAccount.toJson(),
      'transferContent': transferContent,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
      'transactionId': transactionId,
      'confirmationCode': confirmationCode,
      'confirmedAt': confirmedAt?.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  BankTransferInfo copyWith({
    String? orderId,
    double? amount,
    String? currency,
    BankAccountInfo? recipientAccount,
    String? transferContent,
    DateTime? createdAt,
    BankTransferStatus? status,
    String? transactionId,
    String? confirmationCode,
    DateTime? confirmedAt,
    String? notes,
  }) {
    return BankTransferInfo(
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      recipientAccount: recipientAccount ?? this.recipientAccount,
      transferContent: transferContent ?? this.transferContent,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() =>
      'BankTransferInfo{orderId: $orderId, amount: $amount, status: $status}';
}

enum BankTransferStatus { pending, processing, confirmed, failed, cancelled }

extension BankTransferStatusExtension on BankTransferStatus {
  String get displayName {
    switch (this) {
      case BankTransferStatus.pending:
        return 'Chờ chuyển khoản';
      case BankTransferStatus.processing:
        return 'Đang xử lý';
      case BankTransferStatus.confirmed:
        return 'Đã xác nhận';
      case BankTransferStatus.failed:
        return 'Thất bại';
      case BankTransferStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String get color {
    switch (this) {
      case BankTransferStatus.pending:
        return '#FF9800';
      case BankTransferStatus.processing:
        return '#2196F3';
      case BankTransferStatus.confirmed:
        return '#4CAF50';
      case BankTransferStatus.failed:
        return '#F44336';
      case BankTransferStatus.cancelled:
        return '#757575';
    }
  }
}
