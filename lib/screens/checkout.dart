import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/services/order_service.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:v_store/services/address_service.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/utils/price_formatter.dart';
import 'package:v_store/screens/vnpay_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem>? directPurchaseItems;
  final bool isFromCart;

  const CheckoutScreen({
    super.key,
    this.directPurchaseItems,
    this.isFromCart = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedPaymentMethod = 'cod';
  String selectedAddress = 'default';

  Map<String, Map<String, String>> addresses = {};
  bool _addressesLoaded = false;

  final TextEditingController _discountController = TextEditingController();
  double discountAmount = 0.0;
  String? appliedDiscountCode;
  bool isDiscountLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    try {
      final loadedAddresses = await AddressService.getAddresses();
      final defaultAddressKey = await AddressService.getDefaultAddressKey();

      setState(() {
        addresses = loadedAddresses;
        selectedAddress = defaultAddressKey;
        _addressesLoaded = true;
      });
    } catch (e) {
      print('Error loading addresses: $e');
      setState(() {
        _addressesLoaded = true;
      });
    }
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
        title: Text(
          widget.isFromCart
              ? 'Thanh toán giỏ hàng'
              : (widget.directPurchaseItems != null
                    ? 'Thanh toán - Mua ngay'
                    : 'Thanh toán'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          final List<CartItem> itemsToCheckout =
              widget.directPurchaseItems ?? cartService.getSelectedItems();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAddressSection(),
                      _buildOrderItemsSection(itemsToCheckout),
                      _buildPaymentMethodSection(),
                      _buildDiscountCodeSection(),
                      _buildOrderSummarySection(itemsToCheckout),
                    ],
                  ),
                ),
              ),
              _buildBottomCheckout(itemsToCheckout),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressSection() {
    if (!_addressesLoaded) {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (addresses.isEmpty) {
      return Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Chưa có địa chỉ giao hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _showAddNewAddressDialog,
              icon: const Icon(Icons.add),
              label: const Text('Thêm địa chỉ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    final currentAddress = addresses[selectedAddress];
    if (currentAddress == null) {
      selectedAddress = addresses.keys.first;
      return _buildAddressSection();
    }

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ nhận hàng',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showAddressDialog();
                },
                child: const Text(
                  'Thay đổi',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currentAddress['name']!,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(currentAddress['phone']!, style: const TextStyle(fontSize: 14)),
          Text(
            currentAddress['address']!,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Chọn địa chỉ giao hàng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...addresses.entries.map((entry) {
                      final addressKey = entry.key;
                      final address = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: _buildAddressOption(
                          address['title']!,
                          address['name']!,
                          address['phone']!,
                          address['address']!,
                          isSelected: selectedAddress == addressKey,
                          onTap: () {
                            setState(() {
                              selectedAddress = addressKey;
                            });
                            Navigator.pop(context);
                          },
                          addressKey: addressKey,
                          showSetDefaultButton: true,
                          onSetDefault: () async {
                            await AddressService.setDefaultAddress(addressKey);
                            await _loadAddresses();
                            setDialogState(() {});
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddNewAddressDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm địa chỉ mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAddressOption(
    String title,
    String name,
    String phone,
    String address, {
    required bool isSelected,
    required VoidCallback onTap,
    String? addressKey,
    bool showSetDefaultButton = false,
    VoidCallback? onSetDefault,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.orange, size: 20)
                else
                  const Icon(
                    Icons.radio_button_unchecked,
                    color: Colors.grey,
                    size: 20,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (showSetDefaultButton && onSetDefault != null && !isSelected)
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    onPressed: onSetDefault,
                    tooltip: 'Đặt làm mặc định',
                  ),
                if (addressKey != null &&
                    addressKey != 'default' &&
                    addressKey != 'company')
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _showDeleteAddressDialog(addressKey),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(phone, style: const TextStyle(fontSize: 14)),
            Text(address, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showAddNewAddressDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressDetailController = TextEditingController();
    bool setAsDefault = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Thêm địa chỉ mới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và tên',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: addressDetailController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ chi tiết',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Checkbox(
                            value: setAsDefault,
                            onChanged: (value) {
                              setDialogState(() {
                                setAsDefault = value!;
                              });
                            },
                          ),
                          const Text('Đặt làm địa chỉ mặc định'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        addressDetailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng điền đầy đủ thông tin'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await AddressService.addAddress(
                        title: 'Địa chỉ mới',
                        name: nameController.text,
                        phone: phoneController.text,
                        address: addressDetailController.text,
                        setAsDefault: setAsDefault,
                      );

                      await _loadAddresses();
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Đã thêm địa chỉ mới'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Có lỗi xảy ra khi thêm địa chỉ'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildOrderItemsSection(List<CartItem> items) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.directPurchaseItems != null
                    ? 'V-Store - Mua ngay'
                    : 'V-Store',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chat_bubble_outline, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final discountPrice = item.product.caculateDiscountedPrice();

              return Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (item.selectedSize != null ||
                            item.selectedColor != null)
                          Text(
                            '${item.selectedSize ?? ''} ${item.selectedColor ?? ''}'
                                .trim(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          PriceFormatter.format(discountPrice),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'x${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        PriceFormatter.format(discountPrice * item.quantity),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildPaymentOption(
            'cod',
            'Thanh toán khi nhận hàng (COD)',
            Icons.money,
          ),
          _buildPaymentOption('momo', 'Ví MoMo', Icons.account_balance_wallet),
          _buildPaymentOption(
            'vnpay',
            'Chuyển khoản ngân hàng (VNPAY)',
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: selectedPaymentMethod,
      onChanged: (String? value) {
        setState(() {
          selectedPaymentMethod = value!;
        });
      },
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      activeColor: Colors.orange,
    );
  }

  Widget _buildDiscountCodeSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Mã giảm giá',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _discountController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isDiscountLoading && appliedDiscountCode == null,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                width: 80,
                child: ElevatedButton(
                  onPressed: appliedDiscountCode != null
                      ? _removeDiscountCode
                      : (isDiscountLoading ? null : _applyDiscountCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appliedDiscountCode != null
                        ? Colors.red
                        : Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: isDiscountLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(appliedDiscountCode != null ? 'Bỏ' : 'Áp dụng'),
                ),
              ),
            ],
          ),
          if (appliedDiscountCode != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mã "$appliedDiscountCode" đã được áp dụng',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  Text(
                    '-${PriceFormatter.format(discountAmount)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.product.caculateDiscountedPrice() * item.quantity),
    );
    const shippingFee = 30000.0;
    final actualDiscountAmount = discountAmount > subtotal
        ? subtotal
        : discountAmount;
    final total = subtotal - actualDiscountAmount + shippingFee;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Tạm tính', PriceFormatter.format(subtotal)),
          if (actualDiscountAmount > 0)
            _buildSummaryRow(
              'Giảm giá',
              '-${PriceFormatter.format(actualDiscountAmount)}',
              isDiscount: true,
            ),
          _buildSummaryRow(
            'Phí vận chuyển',
            PriceFormatter.format(shippingFee),
          ),
          const Divider(),
          _buildSummaryRow(
            'Tổng cộng',
            PriceFormatter.format(total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isTotal = false,
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isDiscount ? Colors.green : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: isTotal
                  ? Colors.red
                  : (isDiscount ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.product.caculateDiscountedPrice() * item.quantity),
    );
    const shippingFee = 30000.0;
    final actualDiscountAmount = discountAmount > subtotal
        ? subtotal
        : discountAmount;
    final total = subtotal - actualDiscountAmount + shippingFee;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Tổng thanh toán',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    PriceFormatter.format(total),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _handlePlaceOrder(items),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đặt hàng',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlaceOrder(List<CartItem> items) async {
    final subtotal = items.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.product.caculateDiscountedPrice() * item.quantity),
    );
    const shippingFee = 30000.0;
    final actualDiscountAmount = discountAmount > subtotal
        ? subtotal
        : discountAmount;
    final total = subtotal - actualDiscountAmount + shippingFee;

    final currentAddress = addresses[selectedAddress]!;

    if (selectedPaymentMethod == 'vnpay') {
      try {
        final orderId = await OrderService.saveOrder(
          items: items,
          paymentMethod: selectedPaymentMethod,
          deliveryAddress: currentAddress,
          subtotal: subtotal,
          shippingFee: shippingFee,
          discountAmount: actualDiscountAmount,
          total: total,
          discountCode: appliedDiscountCode,
          userId: AuthService.currentUser?.uid,
        );

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VNPayPaymentScreen(
              orderId: orderId,
              amount: total,
              orderInfo: 'Thanh toán đơn hàng #$orderId',
              items: items,
              isFromCart: widget.isFromCart,
            ),
          ),
        );

        if (result == true) {
          await OrderService.updateOrderStatus(orderId, 'paid');

          await _clearCartItems(items);

          _showSuccessDialog(orderId, total);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán không thành công'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang xử lý đơn hàng...'),
          ],
        ),
      ),
    );

    try {
      final orderId = await OrderService.saveOrder(
        items: items,
        paymentMethod: selectedPaymentMethod,
        deliveryAddress: currentAddress,
        subtotal: subtotal,
        shippingFee: shippingFee,
        discountAmount: actualDiscountAmount,
        total: total,
        discountCode: appliedDiscountCode,
        userId: AuthService.currentUser?.uid,
      );

      Navigator.pop(context);

      await _clearCartItems(items);

      _showSuccessDialog(orderId, total);
    } catch (e) {
      Navigator.pop(context);
      _showOrderErrorDialog(e, items);
    }
  }

  Future<void> _clearCartItems(List<CartItem> items) async {
    final cartService = Provider.of<CartService>(context, listen: false);

    if (widget.directPurchaseItems == null) {
      cartService.removeSelectedItems();
    } else if (widget.isFromCart) {
      for (final item in widget.directPurchaseItems!) {
        await cartService.removeFromCart(
          item.product.productId,
          size: item.selectedSize?.isEmpty == true ? null : item.selectedSize,
          color: item.selectedColor,
        );
      }
    }
  }

  void _showSuccessDialog(String orderId, double total) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đặt hàng thành công!',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mã đơn hàng: $orderId'),
            const SizedBox(height: 8),
            Text('Tổng thanh toán: ${PriceFormatter.format(total)}'),
            const SizedBox(height: 8),
            const Text(
              'Đơn hàng của bạn đã được xử lý thành công. Chúng tôi sẽ liên hệ với bạn sớm nhất để xác nhận và giao hàng.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  void _showOrderErrorDialog(dynamic e, List<CartItem> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Lỗi đặt hàng'),
          ],
        ),
        content: Text(
          'Có lỗi xảy ra khi xử lý đơn hàng của bạn:\n$e\n\nVui lòng thử lại sau.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handlePlaceOrder(items);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _applyDiscountCode() async {
    final code = _discountController.text.trim();
    if (code.isEmpty) return;

    setState(() {
      isDiscountLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    Map<String, double> discountCodes = {
      'WELCOME10': 0.1,

      'SAVE20K': 20000,
      'NEWUSER': 0.15,
      'SALE30': 30000,
    };

    if (discountCodes.containsKey(code.toUpperCase())) {
      final discountValue = discountCodes[code.toUpperCase()]!;

      setState(() {
        appliedDiscountCode = code.toUpperCase();

        if (discountValue < 1) {
          final subtotal = _calculateSubtotal();
          discountAmount = subtotal * discountValue;
        } else {
          discountAmount = discountValue;
        }

        isDiscountLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã giảm giá "$code" đã được áp dụng thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() {
        isDiscountLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mã giảm giá không hợp lệ hoặc đã hết hạn'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeDiscountCode() {
    setState(() {
      appliedDiscountCode = null;
      discountAmount = 0.0;
      _discountController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã bỏ mã giảm giá'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  double _calculateSubtotal() {
    if (widget.directPurchaseItems != null) {
      return widget.directPurchaseItems!.fold<double>(
        0.0,
        (sum, item) =>
            sum + (item.product.caculateDiscountedPrice() * item.quantity),
      );
    } else {
      final cartService = Provider.of<CartService>(context, listen: false);
      final items = cartService.getSelectedItems();
      return items.fold<double>(
        0.0,
        (sum, item) =>
            sum + (item.product.caculateDiscountedPrice() * item.quantity),
      );
    }
  }

  void _showDeleteAddressDialog(String addressKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa địa chỉ'),
          content: Text(
            'Bạn có chắc muốn xóa địa chỉ "${addresses[addressKey]!['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await AddressService.deleteAddress(addressKey);

                  await _loadAddresses();

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa địa chỉ'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Có lỗi xảy ra khi xóa địa chỉ'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }
}
