import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_store/services/vnpay_service.dart';
import 'package:v_store/services/order_service.dart';
import 'package:v_store/config/vnpay_config.dart';
import 'package:v_store/utils/price_formatter.dart';
import 'package:url_launcher/url_launcher.dart';

class VNPayPaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;
  final Map<String, dynamic> orderData;
  final VoidCallback? onPaymentSuccess;

  const VNPayPaymentScreen({
    super.key,
    required this.totalAmount,
    required this.orderId,
    required this.orderData,
    this.onPaymentSuccess,
  });

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  String? selectedBankCode;
  bool isProcessing = false;

  final List<Map<String, String>> supportedBanks = [
    {
      'code': '',
      'name': 'Cổng thanh toán VNPAY (Tất cả ngân hàng)',
      'icon': '💳',
    },
    {'code': 'NCB', 'name': 'Ngân hàng Quốc dân NCB', 'icon': '🏦'},
    {'code': 'AGRIBANK', 'name': 'Ngân hàng Agribank', 'icon': '🌱'},
    {'code': 'SCB', 'name': 'Ngân hàng Sài Gòn SCB', 'icon': '🏙️'},
    {'code': 'SACOMBANK', 'name': 'Ngân hàng Sacombank', 'icon': '💼'},
    {'code': 'EXIMBANK', 'name': 'Ngân hàng EximBank', 'icon': '🚢'},
    {'code': 'MSBANK', 'name': 'Ngân hàng Maritime Bank', 'icon': '⚓'},
    {'code': 'NAMABANK', 'name': 'Ngân hàng Nam A Bank', 'icon': '🏢'},
    {'code': 'VNMART', 'name': 'Ví điện tử VnMart', 'icon': '📱'},
    {'code': 'VIETINBANK', 'name': 'Ngân hàng Vietinbank', 'icon': '🇻🇳'},
    {'code': 'VIETCOMBANK', 'name': 'Ngân hàng Vietcombank', 'icon': '🏛️'},
    {'code': 'HDBANK', 'name': 'Ngân hàng HDBank', 'icon': '💎'},
    {'code': 'DONGABANK', 'name': 'Ngân hàng Đông Á', 'icon': '🌏'},
    {'code': 'TPBANK', 'name': 'Ngân hàng TPBank', 'icon': '🎯'},
    {'code': 'OJB', 'name': 'Ngân hàng OceanBank', 'icon': '🌊'},
    {'code': 'BIDV', 'name': 'Ngân hàng BIDV', 'icon': '🏦'},
    {'code': 'TECHCOMBANK', 'name': 'Ngân hàng Techcombank', 'icon': '🔧'},
    {'code': 'VPBANK', 'name': 'Ngân hàng VPBank', 'icon': '🚀'},
    {'code': 'MBBANK', 'name': 'Ngân hàng MBBank', 'icon': '📊'},
    {'code': 'ACB', 'name': 'Ngân hàng ACB', 'icon': '⭐'},
    {'code': 'OCB', 'name': 'Ngân hàng OCB', 'icon': '🏆'},
    {'code': 'IVB', 'name': 'Ngân hàng IVB', 'icon': '💫'},
    {'code': 'VISA', 'name': 'Thẻ thanh toán quốc tế', 'icon': '💳'},
  ];

  @override
  void initState() {
    super.initState();
    selectedBankCode = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thanh toán VNPAY',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin đơn hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mã đơn hàng:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      widget.orderId.substring(0, 8),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      PriceFormatter.format(widget.totalAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/vnpay_logo.png',
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.payment,
                              color: Colors.blue,
                              size: 20,
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Chọn ngân hàng thanh toán',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: supportedBanks.length,
                      itemBuilder: (context, index) {
                        final bank = supportedBanks[index];
                        final isSelected = selectedBankCode == bank['code'];

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.blue[50]
                                  : Colors.grey[100],
                              child: Text(
                                bank['icon']!,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              bank['name']!,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.black,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                  )
                                : const Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.grey,
                                  ),
                            onTap: () {
                              setState(() {
                                selectedBankCode = bank['code'];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.orange[50],
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Thông tin thẻ test (Sandbox)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Ngân hàng: ${VNPayConfig.testCard['bankCode']}'),
                Text('Số thẻ: ${VNPayConfig.testCard['cardNumber']}'),
                Text('Chủ thẻ: ${VNPayConfig.testCard['cardHolder']}'),
                Text('MM/YY: ${VNPayConfig.testCard['issueDate']}'),
                Text('OTP: ${VNPayConfig.testCard['otp']}'),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Đang xử lý...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Thanh toán ngay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final orderInfo = 'Thanh toan don hang ${widget.orderId}';

      print('🔄 Processing VNPAY payment...');
      print('💰 Amount: ${widget.totalAmount}');
      print('🏦 Bank Code: $selectedBankCode');
      print('📄 Order Info: $orderInfo');

      final success = await VNPayService.launchPayment(
        amount: widget.totalAmount,
        orderInfo: orderInfo,
        orderId: widget.orderId,
        bankCode: selectedBankCode?.isEmpty == true ? null : selectedBankCode,
      );

      if (success) {
        print('✅ Payment launched successfully');
        _showPaymentWaitingDialog();
      } else {
        print('❌ Payment launch failed');
        _showErrorDialog(
          'Không thể mở cổng thanh toán VNPAY.\n\nVui lòng kiểm tra:\n• Kết nối internet\n• Trình duyệt web\n• Thử lại sau',
        );
      }
    } catch (e) {
      print('❌ Payment processing error: $e');
      _showErrorDialog('Lỗi xử lý thanh toán: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  void _showPaymentWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.payment, color: Colors.blue, size: 24),
            const SizedBox(width: 8),
            const Text('Đang thanh toán'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng hoàn tất thanh toán trên trang VNPAY và quay lại ứng dụng.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sử dụng thông tin thẻ test được cung cấp để thanh toán.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _simulatePaymentReturn();
            },
            child: const Text('Giả lập thanh toán thành công'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _simulatePaymentReturn() async {
    Navigator.pop(context);

    final mockReturnParams = {
      'vnp_ResponseCode': '00',
      'vnp_TransactionStatus': '00',
      'vnp_TxnRef': DateTime.now().millisecondsSinceEpoch.toString(),
      'vnp_Amount': (widget.totalAmount * 100).toInt().toString(),
      'vnp_OrderInfo': 'Thanh toan don hang ${widget.orderId}',
      'vnp_PayDate': DateTime.now().toIso8601String(),
      'vnp_TransactionNo': 'TEST_${DateTime.now().millisecondsSinceEpoch}',
      'vnp_BankCode': selectedBankCode ?? 'NCB',
      'vnp_CardType': 'ATM',
    };

    final result = VNPayService.parsePaymentResult(mockReturnParams);

    if (result.isSuccess) {
      await _handlePaymentSuccess(result);
    } else {
      _showErrorDialog('Thanh toán không thành công. Vui lòng thử lại.');
    }
  }

  Future<void> _handlePaymentSuccess(VNPayResult result) async {
    try {
      await OrderService.updateOrderPaymentStatus(
        widget.orderId,
        'paid',
        paymentMethod: 'vnpay',
        paymentData: result.toJson(),
      );

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text('Thanh toán thành công'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã giao dịch: ${result.transactionNo}'),
              const SizedBox(height: 8),
              Text('Số tiền: ${PriceFormatter.format(result.amount)}'),
              const SizedBox(height: 8),
              Text('Ngân hàng: ${result.bankCode}'),
              const SizedBox(height: 8),
              const Text(
                'Đơn hàng của bạn đã được thanh toán thành công và đang được xử lý.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                if (widget.onPaymentSuccess != null) {
                  widget.onPaymentSuccess!();
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('Lỗi cập nhật thông tin thanh toán: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            const Text('Lỗi thanh toán'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _testPaymentUrl() async {
    try {
      final paymentUrl = VNPayService.createPaymentUrl(
        amount: widget.totalAmount,
        orderInfo: 'Test payment',
        orderId: widget.orderId,
        bankCode: selectedBankCode?.isEmpty == true ? null : selectedBankCode,
      );

      print('📋 Generated URL: $paymentUrl');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('VNPAY URL'),
          content: SingleChildScrollView(child: SelectableText(paymentUrl)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final uri = Uri.parse(paymentUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: const Text('Mở trình duyệt'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Error testing URL: $e');
    }
  }

  void _copyPaymentUrl() async {
    try {
      final paymentUrl = VNPayService.createPaymentUrl(
        amount: widget.totalAmount,
        orderInfo: 'Thanh toan don hang ${widget.orderId}',
        orderId: widget.orderId,
        bankCode: selectedBankCode?.isEmpty == true ? null : selectedBankCode,
      );

      await Clipboard.setData(ClipboardData(text: paymentUrl));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép URL thanh toán vào clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Error copying payment URL: $e');
    }
  }
}
