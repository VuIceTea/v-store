import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:v_store/services/vnpay_service.dart';
import 'package:v_store/services/order_service.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/models/cart_item.dart';

class VNPayPaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String orderInfo;
  final List<CartItem> items;
  final bool isFromCart;

  const VNPayPaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.orderInfo,
    required this.items,
    required this.isFromCart,
  });

  @override
  State<VNPayPaymentScreen> createState() => _VNPayPaymentScreenState();
}

class _VNPayPaymentScreenState extends State<VNPayPaymentScreen> {
  final CartService _cartService = CartService();

  String? selectedBank;
  bool isProcessing = false;
  String? generatedUrl;

  final List<Map<String, String>> banks = [
    {'code': 'NCB', 'name': 'Ngân hàng NCB'},
    {'code': 'SCB', 'name': 'Ngân hàng SCB'},
    {'code': 'SACOMBANK', 'name': 'Ngân hàng SacomBank'},
    {'code': 'EXIMBANK', 'name': 'Ngân hàng EximBank'},
    {'code': 'MSBANK', 'name': 'Ngân hàng MS Bank'},
    {'code': 'NAMABANK', 'name': 'Ngân hàng Nam A Bank'},
    {'code': 'VNMART', 'name': 'Ví VnMart'},
    {'code': 'VIETINBANK', 'name': 'Ngân hàng Vietinbank'},
    {'code': 'VIETCOMBANK', 'name': 'Ngân hàng VCB'},
    {'code': 'HDBANK', 'name': 'Ngân hàng HDBank'},
    {'code': 'DONGABANK', 'name': 'Ngân hàng Dong A'},
    {'code': 'TPBANK', 'name': 'Ngân hàng TPBank'},
    {'code': 'OJB', 'name': 'Ngân hàng OceanBank'},
    {'code': 'BIDV', 'name': 'Ngân hàng BIDV'},
    {'code': 'TECHCOMBANK', 'name': 'Ngân hàng Techcombank'},
    {'code': 'VPBANK', 'name': 'Ngân hàng VPBank'},
    {'code': 'AGRIBANK', 'name': 'Ngân hàng Agribank'},
    {'code': 'MBBANK', 'name': 'Ngân hàng MBBank'},
    {'code': 'ACB', 'name': 'Ngân hàng ACB'},
    {'code': 'OCB', 'name': 'Ngân hàng OCB'},
    {'code': 'SHB', 'name': 'Ngân hàng SHB'},
    {'code': 'IVB', 'name': 'Ngân hàng IVB'},
    {'code': 'VISA', 'name': 'Thanh toán qua VISA/MASTER'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPAY'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin đơn hàng',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Mã đơn hàng: ${widget.orderId}'),
                    Text('Số tiền: ${widget.amount.toStringAsFixed(0)} VND'),
                    Text('Nội dung: ${widget.orderInfo}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Chọn ngân hàng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: ListView.builder(
                itemCount: banks.length,
                itemBuilder: (context, index) {
                  final bank = banks[index];
                  return RadioListTile<String>(
                    title: Text(bank['name']!),
                    value: bank['code']!,
                    groupValue: selectedBank,
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value;
                      });
                    },
                  );
                },
              ),
            ),

            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin thẻ test (Sandbox)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Số thẻ: 9704 0000 0000 0018'),
                    const Text('Tên chủ thẻ: NGUYEN VAN A'),
                    const Text('Ngày hết hạn: 07/15'),
                    const Text('Mật khẩu OTP: 123456'),
                    const SizedBox(height: 8),
                    const Text(
                      'Lưu ý: Đây là thông tin thẻ test cho môi trường sandbox',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessing || selectedBank == null
                        ? null
                        : () => _processPayment(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                              SizedBox(width: 8),
                              Text('Đang xử lý...'),
                            ],
                          )
                        : const Text('Thanh toán'),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isProcessing ? null : () => _simulateSuccess(),
                    child: const Text('Mô phỏng thanh toán thành công (Test)'),
                  ),
                ),

                if (generatedUrl != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyUrl(),
                      icon: const Icon(Icons.copy),
                      label: const Text('Sao chép URL thanh toán'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (selectedBank == null) {
      _showError('Vui lòng chọn ngân hàng');
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final url = VNPayService.createPaymentUrl(
        amount: widget.amount,
        orderInfo: widget.orderInfo,
        orderId: widget.orderId,
        bankCode: selectedBank!,
      );

      setState(() {
        generatedUrl = url;
      });

      print('VNPAY URL Generated: $url');

      final success = await VNPayService.launchPayment(
        amount: widget.amount,
        orderInfo: widget.orderInfo,
        orderId: widget.orderId,
        bankCode: selectedBank!,
      );

      if (success) {
        _showWaitingDialog();
      } else {
        _showLaunchErrorDialog();
      }
    } catch (e) {
      print('Payment error: $e');
      _showError('Lỗi tạo thanh toán: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Future<void> _simulateSuccess() async {
    await _handlePaymentSuccess();
  }

  Future<void> _copyUrl() async {
    if (generatedUrl != null) {
      await Clipboard.setData(ClipboardData(text: generatedUrl!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã sao chép URL thanh toán')),
        );
      }
    }
  }

  void _showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Đang chờ thanh toán'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Vui lòng hoàn tất thanh toán trong trình duyệt và quay lại ứng dụng.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _handlePaymentSuccess(),
            child: const Text('Đã thanh toán thành công'),
          ),
          TextButton(
            onPressed: () => _handlePaymentCancel(),
            child: const Text('Hủy thanh toán'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePaymentSuccess() async {
    try {
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }

      await OrderService.updateOrderStatus(widget.orderId, 'paid');

      if (widget.isFromCart) {
        await _cartService.clearCart();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      print('Error handling payment success: $e');
      _showError('Lỗi cập nhật đơn hàng: $e');
    }
  }

  void _handlePaymentCancel() {
    Navigator.of(context).pop();
    _showError('Thanh toán đã bị hủy');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showLaunchErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Lỗi mở trình duyệt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Không thể mở trình duyệt thanh toán tự động. Điều này có thể xảy ra do:',
            ),
            const SizedBox(height: 8),
            const Text('• Lỗi kết nối với trình duyệt'),
            const Text('• Ứng dụng đang chạy trong chế độ debug'),
            const Text('• Chưa cài đặt trình duyệt web'),
            const SizedBox(height: 16),
            const Text('Vui lòng chọn một trong các tùy chọn sau:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _copyUrl();
            },
            child: const Text('Sao chép URL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _simulateSuccess();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mô phỏng thành công (Test)'),
          ),
        ],
      ),
    );
  }
}
