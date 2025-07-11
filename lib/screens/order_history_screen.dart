import 'package:flutter/material.dart';
import 'package:v_store/models/order.dart';
import 'package:v_store/models/order_item.dart';
import 'package:v_store/services/order_service.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:v_store/utils/price_formatter.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _orders = [];
  bool _isLoading = true;
  String _currentStatus = 'all';

  final List<Map<String, String>> _statusTabs = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'pending', 'label': 'Chờ xác nhận'},
    {'key': 'confirmed', 'label': 'Đã xác nhận'},
    {'key': 'shipping', 'label': 'Đang giao'},
    {'key': 'delivered', 'label': 'Đã giao'},
    {'key': 'cancelled', 'label': 'Đã hủy'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final orders = await OrderService.getUserOrdersByUserId(user.uid);
        if (mounted && context.mounted) {
          setState(() {
            _orders = orders;
            _isLoading = false;
          });
        }
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
                content: Text('Lỗi tải đơn hàng: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  List<Order> _getFilteredOrders() {
    if (_currentStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => order.status == _currentStatus).toList();
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
          'Đơn hàng của tôi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          onTap: (index) {
            if (mounted) {
              setState(() {
                _currentStatus = _statusTabs[index]['key']!;
              });
            }
          },
          tabs: _statusTabs.map((tab) {
            return Tab(text: tab['label'], height: 40);
          }).toList(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(onRefresh: _loadOrders, child: _buildOrdersList()),
    );
  }

  Widget _buildOrdersList() {
    final filteredOrders = _getFilteredOrders();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _currentStatus == 'all'
                  ? 'Chưa có đơn hàng nào'
                  : 'Không có đơn hàng ${_getStatusLabel(_currentStatus)}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(order.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Products
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.take(2).map((item) => _buildOrderItem(item)),
                if (order.items.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'và ${order.items.length - 2} sản phẩm khác',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng cộng:',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      Text(
                        PriceFormatter.format(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(253, 110, 135, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (order.status == 'pending') ...[
                  OutlinedButton(
                    onPressed: () => _cancelOrder(order),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Hủy đơn',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 4),
                  ElevatedButton(
                    onPressed: () => _viewOrderDetail(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(253, 110, 135, 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ] else
                  ElevatedButton(
                    onPressed: () => _viewOrderDetail(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(253, 110, 135, 1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Chi tiết',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              item.productImage,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
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
                  maxLines: 1,
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
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item.quantity}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Text(
                PriceFormatter.format(item.discountedPrice),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
        return 'Đang giao';
      case 'delivered':
        return 'Đã giao';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return 'Không xác định';
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

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hủy đơn hàng'),
          content: const Text('Bạn có chắc chắn muốn hủy đơn hàng này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await OrderService.updateOrderStatus(order.id, 'cancelled');
                  await _loadOrders();
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

  void _viewOrderDetail(Order order) {
    Navigator.pushNamed(context, '/order-detail', arguments: order.id);
  }
}
