import 'package:flutter/material.dart';
import 'package:v_store/models/order.dart';
import 'package:v_store/models/order_item.dart';
import 'package:v_store/services/order_service.dart';
import 'package:v_store/utils/price_formatter.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final order = await OrderService.getOrderByIdAsObject(widget.orderId);
      if (mounted && context.mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && context.mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (mounted && context.mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi tải thông tin đơn hàng: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(253, 110, 135, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
          ? const Center(
              child: Text(
                'Không tìm thấy thông tin đơn hàng',
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderStatus(),
                  const SizedBox(height: 12),
                  _buildOrderInfo(),
                  const SizedBox(height: 12),
                  _buildDeliveryAddress(),
                  const SizedBox(height: 12),
                  _buildOrderItems(),
                  const SizedBox(height: 12),
                  _buildPaymentSummary(),
                  const SizedBox(height: 20),
                  if (_order!.status == 'pending') _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(_order!.status),
            size: 48,
            color: _getStatusColor(_order!.status),
          ),
          const SizedBox(height: 8),
          Text(
            _getStatusLabel(_order!.status),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(_order!.status),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStatusDescription(_order!.status),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Mã đơn hàng', _order!.orderId),
          _buildInfoRow(
            'Ngày đặt hàng',
            _order!.orderDate != null
                ? '${_order!.orderDate!.day}/${_order!.orderDate!.month}/${_order!.orderDate!.year}'
                : 'N/A',
          ),
          _buildInfoRow(
            'Phương thức thanh toán',
            _getPaymentMethodLabel(_order!.paymentMethod),
          ),
          _buildInfoRow(
            'Trạng thái thanh toán',
            _getPaymentStatusLabel(_order!.paymentStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Địa chỉ giao hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _order!.deliveryAddress.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order!.deliveryAddress.phone,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order!.deliveryAddress.address,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm (${_order!.items.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _order!.items.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final item = _order!.items[index];
              return _buildOrderItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.productImage,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: const Icon(Icons.image, color: Colors.grey),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (item.selectedColor != null)
                    Text(
                      'Màu: ${item.selectedColor}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (item.selectedColor != null && item.selectedSize != null)
                    Text(
                      ' • ',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  if (item.selectedSize != null)
                    Text(
                      'Size: ${item.selectedSize}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    PriceFormatter.format(item.discountedPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(253, 110, 135, 1),
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPaymentRow(
            'Tạm tính',
            PriceFormatter.format(_order!.pricing.subtotal),
          ),
          _buildPaymentRow(
            'Phí vận chuyển',
            PriceFormatter.format(_order!.pricing.shippingFee),
          ),
          if (_order!.pricing.discountAmount > 0)
            _buildPaymentRow(
              'Giảm giá',
              '-${PriceFormatter.format(_order!.pricing.discountAmount)}',
              color: Colors.green,
            ),
          const Divider(),
          _buildPaymentRow(
            'Tổng cộng',
            PriceFormatter.format(_order!.pricing.total),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _cancelOrder(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Hủy đơn hàng',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _contactSupport(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(253, 110, 135, 1),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Liên hệ hỗ trợ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    String value, {
    Color? color,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: color ?? (isTotal ? Colors.black : Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color:
                    color ??
                    (isTotal ? Color.fromRGBO(253, 110, 135, 1) : Colors.black),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'shipping':
        return 'Đang giao hàng';
      case 'delivered':
        return 'Đã giao hàng';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'Đơn hàng đang chờ được xác nhận từ cửa hàng';
      case 'confirmed':
        return 'Đơn hàng đã được xác nhận và đang chuẩn bị';
      case 'shipping':
        return 'Đơn hàng đang trên đường giao đến bạn';
      case 'delivered':
        return 'Đơn hàng đã được giao thành công';
      case 'cancelled':
        return 'Đơn hàng đã bị hủy';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'shipping':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipping':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentMethodLabel(String method) {
    switch (method) {
      case 'cod':
        return 'Thanh toán khi nhận hàng';
      case 'bank_transfer':
        return 'Chuyển khoản ngân hàng';
      case 'momo':
        return 'Ví MoMo';
      case 'vnpay':
        return 'VNPay';
      case 'zalopay':
        return 'ZaloPay';
      default:
        return method;
    }
  }

  String _getPaymentStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'completed':
        return 'Hoàn thành';
      case 'failed':
        return 'Thất bại';
      default:
        return status;
    }
  }

  void _cancelOrder() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy đơn hàng'),
          content: const Text(
            'Bạn có chắc chắn muốn hủy đơn hàng này không? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await OrderService.updateOrderStatus(
                    _order!.orderId,
                    'cancelled',
                  );
                  await _loadOrderDetail();
                  if (mounted && context.mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã hủy đơn hàng thành công'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  }
                } catch (e) {
                  if (mounted && context.mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lỗi hủy đơn hàng: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    });
                  }
                }
              },
              child: const Text('Hủy đơn', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Liên hệ hỗ trợ'),
          content: const Text(
            'Vui lòng liên hệ hotline: 1900-xxxx hoặc email: support@vstore.com để được hỗ trợ.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }
}
