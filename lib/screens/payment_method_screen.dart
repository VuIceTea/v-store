import 'package:flutter/material.dart';
import '../services/vietnamese_bank_service.dart';
import '../services/real_bank_payment_service.dart';
import '../utils/price_formatter.dart';
import 'bank_transfer_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;
  final VoidCallback? onPaymentSuccess;

  const PaymentMethodScreen({
    super.key,
    required this.totalAmount,
    required this.orderId,
    this.onPaymentSuccess,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String? selectedPaymentMethod;
  final bankService = VietnameseBankService();

  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'bank_transfer',
      name: 'Chuyển khoản ngân hàng',
      description: 'Chuyển khoản thủ công qua Internet Banking',
      icon: Icons.account_balance,
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'momo',
      name: 'Ví MoMo',
      description: 'Thanh toán qua ứng dụng MoMo',
      icon: Icons.account_balance_wallet,
      color: Colors.pink,
      isRecommended: true,
    ),
    PaymentMethod(
      id: 'vnpay',
      name: 'VNPay',
      description: 'Thanh toán qua VNPay Gateway',
      icon: Icons.payment,
      color: Colors.blue,
    ),
    PaymentMethod(
      id: 'zalopay',
      name: 'ZaloPay',
      description: 'Thanh toán qua ví ZaloPay',
      icon: Icons.account_balance_wallet,
      color: Colors.blue[700]!,
    ),
    PaymentMethod(
      id: 'internet_banking',
      name: 'Internet Banking',
      description: 'Thanh toán trực tiếp qua ngân hàng online',
      icon: Icons.computer,
      color: Colors.green,
    ),
    PaymentMethod(
      id: 'cod',
      name: 'Thanh toán khi nhận hàng (COD)',
      description: 'Thanh toán bằng tiền mặt khi nhận hàng',
      icon: Icons.money,
      color: Colors.orange,
    ),
    PaymentMethod(
      id: 'credit_card',
      name: 'Thẻ tín dụng/ghi nợ',
      description: 'Visa, Mastercard, JCB',
      icon: Icons.credit_card,
      color: Colors.purple,
      isComingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chọn phương thức thanh toán',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Column(
        children: [
          // Order summary
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mã đơn hàng: ${widget.orderId}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      PriceFormatter.format(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Payment methods
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return _buildPaymentMethodCard(method);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: selectedPaymentMethod != null ? _handlePayment : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Tiếp tục thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    final isSelected = selectedPaymentMethod == method.id;
    final isDisabled = method.isComingSoon;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  setState(() {
                    selectedPaymentMethod = method.id;
                  });
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? Colors.grey[300]
                        : method.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    method.icon,
                    color: isDisabled ? Colors.grey : method.color,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Payment method info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              method.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDisabled ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                          if (method.isRecommended && !isDisabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Khuyến nghị',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (method.isComingSoon)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Sắp ra mắt',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDisabled ? Colors.grey : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: isSelected ? Colors.blue : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePayment() {
    if (selectedPaymentMethod == null) return;

    switch (selectedPaymentMethod) {
      case 'bank_transfer':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BankTransferScreen(
              totalAmount: widget.totalAmount,
              orderId: widget.orderId,
              onPaymentSuccess: widget.onPaymentSuccess,
            ),
          ),
        );
        break;

      case 'cod':
        _handleCODPayment();
        break;

      case 'momo':
        _handleMoMoPayment();
        break;

      case 'vnpay':
        _handleVNPayPayment();
        break;

      case 'zalopay':
        _handleZaloPayPayment();
        break;

      case 'internet_banking':
        _handleInternetBankingPayment();
        break;

      default:
        _showComingSoonDialog();
        break;
    }
  }

  void _handleCODPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận thanh toán'),
        content: const Text(
          'Bạn đã chọn thanh toán khi nhận hàng (COD). Đơn hàng sẽ được xử lý và giao đến địa chỉ của bạn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processCODOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  void _processCODOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Đặt hàng thành công! Đơn hàng sẽ được giao trong 2-3 ngày làm việc.',
        ),
        backgroundColor: Colors.green,
      ),
    );

    widget.onPaymentSuccess?.call();

    // Navigate back
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Sắp ra mắt'),
        content: const Text(
          'Phương thức thanh toán này sẽ được hỗ trợ trong thời gian tới. Vui lòng chọn phương thức khác.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _handleMoMoPayment() async {
    try {
      final paymentUrl = await RealBankPaymentService.createMoMoPayment(
        amount: widget.totalAmount,
        orderId: widget.orderId,
        orderInfo: 'Thanh toán đơn hàng ${widget.orderId}',
      );

      _showPaymentUrlDialog('MoMo', paymentUrl);
    } catch (e) {
      _showErrorDialog('Không thể tạo thanh toán MoMo: $e');
    }
  }

  void _handleVNPayPayment() {
    try {
      final paymentUrl = RealBankPaymentService.createVNPayPayment(
        amount: widget.totalAmount,
        orderId: widget.orderId,
        orderInfo: 'Thanh toán đơn hàng ${widget.orderId}',
      );

      _showPaymentUrlDialog('VNPay', paymentUrl);
    } catch (e) {
      _showErrorDialog('Không thể tạo thanh toán VNPay: $e');
    }
  }

  void _handleZaloPayPayment() async {
    try {
      final paymentUrl = await RealBankPaymentService.createZaloPayPayment(
        amount: widget.totalAmount,
        orderId: widget.orderId,
        description: 'Thanh toán đơn hàng ${widget.orderId}',
      );

      _showPaymentUrlDialog('ZaloPay', paymentUrl);
    } catch (e) {
      _showErrorDialog('Không thể tạo thanh toán ZaloPay: $e');
    }
  }

  void _handleInternetBankingPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngân hàng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBankOption('VCB', 'Vietcombank'),
              _buildBankOption('BIDV', 'BIDV'),
              _buildBankOption('CTG', 'VietinBank'),
              _buildBankOption('AGR', 'Agribank'),
              _buildBankOption('ACB', 'ACB'),
              _buildBankOption('TCB', 'Techcombank'),
              _buildBankOption('MB', 'MBBank'),
              _buildBankOption('VPB', 'VPBank'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankOption(String bankCode, String bankName) {
    return ListTile(
      title: Text(bankName),
      onTap: () {
        Navigator.pop(context);
        try {
          final paymentUrl =
              RealBankPaymentService.createInternetBankingPayment(
                amount: widget.totalAmount,
                orderId: widget.orderId,
                bankCode: bankCode,
              );
          _showPaymentUrlDialog('Internet Banking - $bankName', paymentUrl);
        } catch (e) {
          _showErrorDialog('Không thể tạo thanh toán Internet Banking: $e');
        }
      },
    );
  }

  void _showPaymentUrlDialog(String method, String paymentUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thanh toán $method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('URL thanh toán đã được tạo:'),
            const SizedBox(height: 8),
            SelectableText(paymentUrl, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            const Text(
              'Trong ứng dụng thật, URL này sẽ tự động mở ứng dụng ngân hàng/ví điện tử.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onPaymentSuccess?.call();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text('Giả lập thanh toán thành công'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool isRecommended;
  final bool isComingSoon;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.isRecommended = false,
    this.isComingSoon = false,
  });
}
