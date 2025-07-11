import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/vietnamese_bank.dart';
import '../services/vietnamese_bank_service.dart';
import '../utils/price_formatter.dart';
import 'bank_selection_screen.dart';

class BankTransferScreen extends StatefulWidget {
  final double totalAmount;
  final String orderId;
  final VoidCallback? onPaymentSuccess;

  const BankTransferScreen({
    super.key,
    required this.totalAmount,
    required this.orderId,
    this.onPaymentSuccess,
  });

  @override
  State<BankTransferScreen> createState() => _BankTransferScreenState();
}

class _BankTransferScreenState extends State<BankTransferScreen> {
  final bankService = VietnameseBankService();
  late BankTransferInfo transferInfo;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    transferInfo = bankService.createBankTransfer(
      orderId: widget.orderId,
      amount: widget.totalAmount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeAccount = bankService.getStoreAccount();
    final recipientBank = bankService.getBankById(storeAccount.bankId);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Chuyển khoản ngân hàng',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            _buildInstructionCard(),

            const SizedBox(height: 16),

            // Recipient bank info
            _buildRecipientBankCard(recipientBank, storeAccount),

            const SizedBox(height: 16),

            // Transfer details
            _buildTransferDetailsCard(),

            const SizedBox(height: 16),

            // Customer bank selection
            _buildCustomerBankCard(),

            const SizedBox(height: 24),

            // Confirm transfer button
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Hướng dẫn chuyển khoản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '1. Sao chép thông tin tài khoản bên dưới\n'
            '2. Mở ứng dụng ngân hàng của bạn\n'
            '3. Chuyển khoản với đúng số tiền và nội dung\n'
            '4. Quay lại đây và xác nhận đã chuyển khoản',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientBankCard(
    VietnameseBank? bank,
    BankAccountInfo account,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin tài khoản nhận',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Bank name
          _buildCopyableField(
            label: 'Ngân hàng',
            value: bank?.name ?? 'Vietcombank',
            icon: Icons.account_balance,
          ),

          const SizedBox(height: 12),

          // Account number
          _buildCopyableField(
            label: 'Số tài khoản',
            value: account.accountNumber,
            icon: Icons.credit_card,
            isHighlighted: true,
          ),

          const SizedBox(height: 12),

          // Account holder name
          _buildCopyableField(
            label: 'Tên chủ tài khoản',
            value: account.accountHolderName,
            icon: Icons.person,
          ),

          if (account.branch != null) ...[
            const SizedBox(height: 12),
            _buildCopyableField(
              label: 'Chi nhánh',
              value: account.branch!,
              icon: Icons.location_on,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransferDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết chuyển khoản',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Amount
          _buildCopyableField(
            label: 'Số tiền',
            value: PriceFormatter.format(transferInfo.amount),
            icon: Icons.attach_money,
            isHighlighted: true,
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 12),

          // Transfer content
          _buildCopyableField(
            label: 'Nội dung chuyển khoản',
            value: transferInfo.transferContent,
            icon: Icons.message,
            isHighlighted: true,
            subtitle:
                'Vui lòng ghi đúng nội dung để đơn hàng được xử lý nhanh chóng',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerBankCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chuyển khoản từ ngân hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Material(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: _selectCustomerBank,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Chọn ngân hàng của bạn',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableField({
    required String label,
    required String value,
    required IconData icon,
    bool isHighlighted = false,
    TextStyle? valueStyle,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? Border.all(color: Colors.blue[200]!) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _copyToClipboard(value, label),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 14, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Sao chép',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style:
                valueStyle ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isProcessing ? null : _confirmTransfer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Đang xử lý...'),
                ],
              )
            : const Text(
                'Tôi đã chuyển khoản',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectCustomerBank() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankSelectionScreen(
          onBankSelected: (bank) {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _confirmTransfer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Xác nhận chuyển khoản'),
        content: const Text(
          'Bạn đã thực hiện chuyển khoản với đúng số tiền và nội dung chuyển khoản?\n\n'
          'Đơn hàng sẽ được xử lý sau khi chúng tôi xác nhận được giao dịch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chưa chuyển'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processTransferConfirmation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Đã chuyển khoản'),
          ),
        ],
      ),
    );
  }

  void _processTransferConfirmation() {
    setState(() {
      isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Đã nhận thông tin chuyển khoản!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng ${widget.orderId} sẽ được xử lý sau khi chúng tôi xác nhận giao dịch. '
                  'Thời gian xác nhận thường trong vòng 1-2 giờ làm việc.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onPaymentSuccess?.call();
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Hoàn tất'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }
}
