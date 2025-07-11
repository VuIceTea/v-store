import '../models/vietnamese_bank.dart';

class VietnameseBankService {
  static final VietnameseBankService _instance =
      VietnameseBankService._internal();
  factory VietnameseBankService() => _instance;
  VietnameseBankService._internal();

  static const List<VietnameseBank> _banks = [
    VietnameseBank(
      id: 'bidv',
      name: 'Ngân hàng Đầu tư và Phát triển Việt Nam',
      shortName: 'BIDV',
      logoUrl: 'assets/banks/bidv.png',
      color: '#1976D2',
    ),

    VietnameseBank(
      id: 'vcb',
      name: 'Ngân hàng Ngoại thương Việt Nam',
      shortName: 'Vietcombank',
      logoUrl: 'assets/banks/vcb.png',
      color: '#0D7377',
    ),

    VietnameseBank(
      id: 'ctg',
      name: 'Ngân hàng Công thương Việt Nam',
      shortName: 'VietinBank',
      logoUrl: 'assets/banks/vietinbank.png',
      color: '#FF6B35',
    ),

    VietnameseBank(
      id: 'agr',
      name: 'Ngân hàng Nông nghiệp và Phát triển Nông thôn',
      shortName: 'Agribank',
      logoUrl: 'assets/banks/agribank.png',
      color: '#00AA44',
    ),

    VietnameseBank(
      id: 'acb',
      name: 'Ngân hàng Á Châu',
      shortName: 'ACB',
      logoUrl: 'assets/banks/acb.png',
      color: '#1565C0',
    ),

    VietnameseBank(
      id: 'tcb',
      name: 'Ngân hàng Kỹ thương Việt Nam',
      shortName: 'Techcombank',
      logoUrl: 'assets/banks/techcombank.png',
      color: '#00BCD4',
    ),

    VietnameseBank(
      id: 'mb',
      name: 'Ngân hàng Quân đội',
      shortName: 'MBBank',
      logoUrl: 'assets/banks/mbbank.png',
      color: '#673AB7',
    ),

    VietnameseBank(
      id: 'vpb',
      name: 'Ngân hàng Việt Nam Thịnh vượng',
      shortName: 'VPBank',
      logoUrl: 'assets/banks/vpbank.png',
      color: '#4CAF50',
    ),

    VietnameseBank(
      id: 'tpb',
      name: 'Ngân hàng Tiên Phong',
      shortName: 'TPBank',
      logoUrl: 'assets/banks/tpbank.png',
      color: '#FF5722',
    ),

    VietnameseBank(
      id: 'shb',
      name: 'Ngân hàng Sài Gòn - Hà Nội',
      shortName: 'SHB',
      logoUrl: 'assets/banks/shb.png',
      color: '#E91E63',
    ),

    VietnameseBank(
      id: 'stb',
      name: 'Ngân hàng Sài Gòn Thương tín',
      shortName: 'Sacombank',
      logoUrl: 'assets/banks/sacombank.png',
      color: '#9C27B0',
    ),

    VietnameseBank(
      id: 'hsbc',
      name: 'Ngân hàng TNHH MTV HSBC (Việt Nam)',
      shortName: 'HSBC',
      logoUrl: 'assets/banks/hsbc.png',
      color: '#DC143C',
    ),

    VietnameseBank(
      id: 'sc',
      name: 'Ngân hàng TNHH MTV Standard Chartered (Việt Nam)',
      shortName: 'Standard Chartered',
      logoUrl: 'assets/banks/scb.png',
      color: '#0F4C75',
    ),

    VietnameseBank(
      id: 'citi',
      name: 'Ngân hàng Citibank Việt Nam',
      shortName: 'Citibank',
      logoUrl: 'assets/banks/citibank.png',
      color: '#003F7F',
    ),

    VietnameseBank(
      id: 'dab',
      name: 'Ngân hàng Đông Á',
      shortName: 'DongA Bank',
      logoUrl: 'assets/banks/dongabank.png',
      color: '#FF9800',
    ),

    VietnameseBank(
      id: 'exb',
      name: 'Ngân hàng Xuất Nhập khẩu Việt Nam',
      shortName: 'Eximbank',
      logoUrl: 'assets/banks/eximbank.png',
      color: '#795548',
    ),

    VietnameseBank(
      id: 'hdb',
      name: 'Ngân hàng Phát triển Thành phố Hồ Chí Minh',
      shortName: 'HDBank',
      logoUrl: 'assets/banks/hdbank.png',
      color: '#F44336',
    ),

    VietnameseBank(
      id: 'lpb',
      name: 'Ngân hàng Bưu điện Liên Việt',
      shortName: 'LienVietPostBank',
      logoUrl: 'assets/banks/lienvietpostbank.png',
      color: '#FF5722',
    ),

    VietnameseBank(
      id: 'msb',
      name: 'Ngân hàng Hàng hải Việt Nam',
      shortName: 'MSB',
      logoUrl: 'assets/banks/msb.png',
      color: '#009688',
    ),

    VietnameseBank(
      id: 'nab',
      name: 'Ngân hàng Nam Á',
      shortName: 'Nam A Bank',
      logoUrl: 'assets/banks/namabank.png',
      color: '#607D8B',
    ),

    VietnameseBank(
      id: 'ncb',
      name: 'Ngân hàng Quốc dân',
      shortName: 'NCB',
      logoUrl: 'assets/banks/ncb.png',
      color: '#3F51B5',
    ),

    VietnameseBank(
      id: 'ocb',
      name: 'Ngân hàng Phương Đông',
      shortName: 'OCB',
      logoUrl: 'assets/banks/ocb.png',
      color: '#8BC34A',
    ),

    VietnameseBank(
      id: 'pvcb',
      name: 'Ngân hàng Đại chúng Việt Nam',
      shortName: 'PVcomBank',
      logoUrl: 'assets/banks/pvcombank.png',
      color: '#CDDC39',
    ),

    VietnameseBank(
      id: 'seab',
      name: 'Ngân hàng Đông Nam Á',
      shortName: 'SeABank',
      logoUrl: 'assets/banks/seabank.png',
      color: '#2196F3',
    ),

    VietnameseBank(
      id: 'vib',
      name: 'Ngân hàng Quốc tế Việt Nam',
      shortName: 'VIB',
      logoUrl: 'assets/banks/vib.png',
      color: '#FF6F00',
    ),

    VietnameseBank(
      id: 'vab',
      name: 'Ngân hàng Việt Á',
      shortName: 'VietABank',
      logoUrl: 'assets/banks/vietabank.png',
      color: '#FFC107',
    ),

    VietnameseBank(
      id: 'vietbank',
      name: 'Ngân hàng Việt Nam Thương tín',
      shortName: 'VietBank',
      logoUrl: 'assets/banks/vietbank.png',
      color: '#00BCD4',
    ),

    VietnameseBank(
      id: 'vcapital',
      name: 'Ngân hàng Bản Việt',
      shortName: 'VietCapital Bank',
      logoUrl: 'assets/banks/vietcapitalbank.png',
      color: '#4CAF50',
    ),
  ];

  static const BankAccountInfo storeAccount = BankAccountInfo(
    bankId: 'vcb',
    accountNumber: '1234567890',
    accountHolderName: 'CONG TY TNHH V-STORE',
    branch: 'Chi nhánh Hà Nội',
    swiftCode: 'BFTVVNVX',
  );

  List<VietnameseBank> getAllBanks() {
    return _banks.where((bank) => bank.isActive).toList();
  }

  List<VietnameseBank> getPopularBanks() {
    final popularBankIds = [
      'vcb',
      'bidv',
      'ctg',
      'agr',
      'acb',
      'tcb',
      'mb',
      'vpb',
    ];
    return _banks
        .where((bank) => bank.isActive && popularBankIds.contains(bank.id))
        .toList();
  }

  VietnameseBank? getBankById(String id) {
    try {
      return _banks.firstWhere((bank) => bank.id == id);
    } catch (e) {
      return null;
    }
  }

  List<VietnameseBank> searchBanks(String query) {
    if (query.isEmpty) return getAllBanks();

    final lowercaseQuery = query.toLowerCase();
    return _banks
        .where(
          (bank) =>
              bank.isActive &&
              (bank.name.toLowerCase().contains(lowercaseQuery) ||
                  bank.shortName.toLowerCase().contains(lowercaseQuery)),
        )
        .toList();
  }

  BankAccountInfo getStoreAccount() {
    return storeAccount;
  }

  String generateTransferContent(String orderId) {
    return 'VStore $orderId';
  }

  BankTransferInfo createBankTransfer({
    required String orderId,
    required double amount,
    String currency = 'VND',
  }) {
    return BankTransferInfo(
      orderId: orderId,
      amount: amount,
      currency: currency,
      recipientAccount: storeAccount,
      transferContent: generateTransferContent(orderId),
      createdAt: DateTime.now(),
      status: BankTransferStatus.pending,
    );
  }

  bool isValidAccountNumber(String accountNumber) {
    return RegExp(r'^\d{8,20}$').hasMatch(accountNumber);
  }

  bool isValidAccountHolderName(String name) {
    return name.trim().isNotEmpty &&
        name.trim().length >= 2 &&
        name.trim().length <= 100 &&
        RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(name.trim());
  }

  String? validateBankAccount(BankAccountInfo account) {
    if (account.bankId.isEmpty) {
      return 'Vui lòng chọn ngân hàng';
    }

    if (!isValidAccountNumber(account.accountNumber)) {
      return 'Số tài khoản không hợp lệ (8-20 chữ số)';
    }

    if (!isValidAccountHolderName(account.accountHolderName)) {
      return 'Tên chủ tài khoản không hợp lệ';
    }

    return null;
  }
}
