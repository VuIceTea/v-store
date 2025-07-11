import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/utils/price_formatter.dart';
import 'package:v_store/screens/signin.dart';
import 'package:v_store/screens/checkout.dart';

class CartPageScreen extends StatefulWidget {
  const CartPageScreen({super.key});

  @override
  State<CartPageScreen> createState() => _CartPageScreenState();
}

class _CartPageScreenState extends State<CartPageScreen> {
  bool _showSimilarProducts = false;
  List<Product> _similarProducts = [];
  bool _loadingSimilarProducts = false;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
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
        title: Consumer<CartService>(
          builder: (context, cartService, child) {
            return Text(
              'Giỏ hàng (${cartService.totalItems})',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        actions: [
          Consumer<CartService>(
            builder: (context, cartService, child) {
              if (cartService.cartItems.isEmpty) return Container();
              return TextButton(
                onPressed: () => _showClearCartDialog(cartService),
                child: const Text(
                  'Xóa tất cả',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartService>(
        builder: (context, cartService, child) {
          if (cartService.cartItems.isEmpty) {
            if (_showSimilarProducts) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _showSimilarProducts = false;
                  _similarProducts.clear();
                });
              });
            }
            return _buildEmptyCart();
          }

          return Column(
            children: [
              _buildSelectAllSection(cartService),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cartService.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartService.cartItems[index];
                    return _buildCartItem(item, cartService);
                  },
                ),
              ),
              if (cartService.cartItems.isNotEmpty && _showSimilarProducts)
                _buildSuggestedProducts(),
              _buildBottomCheckout(cartService),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thêm sản phẩm vào giỏ hàng',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/main', arguments: 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Mua sắm ngay',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectAllSection(CartService cartService) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (cartService.isAllSelected) {
                cartService.deselectAllItems();
              } else {
                cartService.selectAllItems();
              }
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: cartService.isAllSelected
                      ? Colors.orange
                      : Colors.grey,
                  width: 2,
                ),
                color: cartService.isAllSelected
                    ? Colors.orange
                    : Colors.transparent,
              ),
              child: cartService.isAllSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tất cả',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          if (cartService.selectedItemIds.isNotEmpty)
            TextButton(
              onPressed: () => _showDeleteSelectedDialog(cartService),
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartService cartService) {
    final variantId =
        '${item.product.productId}|${item.selectedSize ?? ''}|${item.selectedColor ?? ''}';
    final isSelected = cartService.selectedItemIds.contains(variantId);
    final discountPrice = item.product.caculateDiscountedPrice();
    final hasDiscount =
        item.product.discount != null && item.product.discount! > 0;

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => cartService.toggleItemSelection(
              item.product.productId,
              size: item.selectedSize?.isEmpty == true
                  ? null
                  : item.selectedSize,
              color: item.selectedColor,
            ),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.orange : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.orange : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // Product details
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

                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Size selector
                    if (item.product.sizes != null &&
                        item.product.sizes!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Size: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showVariantSelector(
                              context,
                              item,
                              cartService,
                              'size',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.selectedSize ?? 'Chọn',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: item.selectedSize != null
                                          ? Colors.black87
                                          : Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Color selector
                    if (item.product.colors != null &&
                        item.product.colors!.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Màu: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showVariantSelector(
                              context,
                              item,
                              cartService,
                              'color',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (item.selectedColor != null) ...[
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: _getColorFromName(
                                          item.selectedColor!,
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                        ),
                                      ),
                                    ),
                                  ],
                                  Flexible(
                                    child: Text(
                                      item.selectedColor ?? 'Chọn',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: item.selectedColor != null
                                            ? Colors.black87
                                            : Colors.grey[500],
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    Text(
                      _formatPrice(discountPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        _formatPrice(item.product.price),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Quantity controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildQuantityButton(
                          icon: Icons.remove,
                          onTap: () {
                            try {
                              if (item.quantity > 1) {
                                cartService.updateQuantity(
                                  item.product.productId,
                                  item.quantity - 1,
                                  size: item.selectedSize?.isEmpty == true
                                      ? null
                                      : item.selectedSize,
                                  color: item.selectedColor,
                                );
                              } else {
                                _onProductRemoved(
                                  item.product,
                                  cartService,
                                  item.selectedSize,
                                  item.selectedColor,
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi khi cập nhật số lượng: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                        Container(
                          width: 50,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        _buildQuantityButton(
                          icon: Icons.add,
                          onTap: () {
                            try {
                              cartService.updateQuantity(
                                item.product.productId,
                                item.quantity + 1,
                                size: item.selectedSize?.isEmpty == true
                                    ? null
                                    : item.selectedSize,
                                color: item.selectedColor,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lỗi khi cập nhật số lượng: $e',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    // Delete button
                    GestureDetector(
                      onTap: () => _showDeleteItemDialog(item, cartService),
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[50],
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildSuggestedProducts() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Có thể bạn cũng thích',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showSimilarProducts = false;
                    _similarProducts.clear();
                  });
                },
                icon: const Icon(Icons.close, size: 20),
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: _loadingSimilarProducts
                ? const Center(child: CircularProgressIndicator())
                : _similarProducts.isEmpty
                ? const Center(
                    child: Text(
                      'Không có sản phẩm tương tự',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _similarProducts.length,
                    itemBuilder: (context, index) {
                      final product = _similarProducts[index];
                      final discountedPrice = product.caculateDiscountedPrice();
                      final hasDiscount =
                          product.discount != null && product.discount! > 0;

                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product image
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              child: Image.network(
                                product.imageUrl,
                                width: 140,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 140,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Product details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Product name
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Price section
                                    if (hasDiscount) ...[
                                      Text(
                                        _formatPrice(discountedPrice),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red,
                                        ),
                                      ),
                                      Text(
                                        _formatPrice(product.price),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ] else
                                      Text(
                                        _formatPrice(product.price),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.red,
                                        ),
                                      ),

                                    const Spacer(),

                                    // Add to cart button
                                    SizedBox(
                                      width: double.infinity,
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            _addSimilarProductToCart(product),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Thêm vào giỏ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout(CartService cartService) {
    if (cartService.cartItems.isEmpty) {
      return Container();
    }

    final selectedItems = cartService.getSelectedItems();
    if (selectedItems.isEmpty) {
      return Container();
    }

    final subtotal = selectedItems.fold<double>(
      0.0,
      (sum, item) =>
          sum + (item.product.caculateDiscountedPrice() * item.quantity),
    );

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Row(
          children: [
            // Total price section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tổng cộng (${selectedItems.length} sản phẩm)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    PriceFormatter.format(subtotal),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Checkout button
            ElevatedButton(
              onPressed: () => _handleCheckout(selectedItems, subtotal),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Mua hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout(List<CartItem> selectedItems, double subtotal) async {
    // Check if user is logged in
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      _showLoginRequiredDialog();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          directPurchaseItems: selectedItems,
          isFromCart: true,
        ),
      ),
    );
  }

  Future<void> _onProductRemoved(
    Product removedProduct,
    CartService cartService, [
    String? size,
    String? color,
  ]) async {
    await cartService.updateQuantity(
      removedProduct.productId,
      0,
      size: size?.isEmpty == true ? null : size,
      color: color,
    );

    await _loadSimilarProducts(removedProduct);
  }

  Future<void> _loadSimilarProducts(Product removedProduct) async {
    if (!mounted) return;

    setState(() {
      _loadingSimilarProducts = true;
      _showSimilarProducts = true;
    });

    try {
      final allProducts = await _productService.getProducts();

      final similar = allProducts
          .where((product) {
            return product.category.categoryId ==
                    removedProduct.category.categoryId &&
                product.productId != removedProduct.productId;
          })
          .take(5)
          .toList();

      if (mounted) {
        setState(() {
          _similarProducts = similar;
          _loadingSimilarProducts = false;
        });
      }
    } catch (e) {
      print('Error loading similar products: $e');
      if (mounted) {
        setState(() {
          _loadingSimilarProducts = false;
        });
      }
    }
  }

  Future<void> _addSimilarProductToCart(Product product) async {
    final cartService = Provider.of<CartService>(context, listen: false);

    try {
      String? defaultSize;
      String? defaultColor;

      if (product.sizes != null && product.sizes!.isNotEmpty) {
        const preferredSizes = ['M', 'L', 'S', 'XL'];
        for (String size in preferredSizes) {
          if (product.sizes!.contains(size)) {
            defaultSize = size;
            break;
          }
        }
        defaultSize ??= product.sizes!.first;
      }

      if (product.colors != null && product.colors!.isNotEmpty) {
        defaultColor = product.colors!.first;
      }

      await cartService.addToCart(
        product,
        quantity: 1,
        size: defaultSize,
        color: defaultColor,
      );

      if (mounted) {
        String variantInfo = '';
        if (defaultSize != null || defaultColor != null) {
          List<String> variants = [];
          if (defaultColor != null) variants.add('Màu: $defaultColor');
          if (defaultSize != null) variants.add('Size: $defaultSize');
          variantInfo = ' (${variants.join(', ')})';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${product.name}"$variantInfo vào giỏ hàng'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi thêm sản phẩm: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showClearCartDialog(CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả sản phẩm'),
        content: const Text(
          'Bạn có chắc muốn xóa tất cả sản phẩm trong giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              cartService.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteSelectedDialog(CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm đã chọn'),
        content: Text(
          'Bạn có chắc muốn xóa ${cartService.selectedItemIds.length} sản phẩm đã chọn?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              cartService.removeSelectedItems();
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(CartItem item, CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text(
          'Bạn có chắc muốn xóa "${item.product.name}" khỏi giỏ hàng?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _loadSimilarProducts(item.product);
              await cartService.removeFromCart(
                item.product.productId,
                size: item.selectedSize?.isEmpty == true
                    ? null
                    : item.selectedSize,
                color: item.selectedColor,
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showVariantSelector(
    BuildContext context,
    CartItem item,
    CartService cartService,
    String variantType,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image_not_supported),
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
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPrice(item.product.caculateDiscountedPrice()),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Variant selection title
              Text(
                variantType == 'size' ? 'Chọn Size' : 'Chọn Màu',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Variant options
              if (variantType == 'size') ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: item.product.sizes!.map((size) {
                    final isSelected = item.selectedSize == size;
                    return GestureDetector(
                      onTap: () {
                        try {
                          cartService.updateItemVariant(
                            item.product.productId,
                            newSize: size,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã đổi size thành $size'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi đổi size: $e'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: item.product.colors!.map((color) {
                    final isSelected = item.selectedColor == color;
                    return GestureDetector(
                      onTap: () {
                        try {
                          cartService.updateItemVariant(
                            item.product.productId,
                            newColor: color,
                          );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã đổi màu thành $color'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Lỗi khi đổi màu: $e'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.orange : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Colors.orange
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: _getColorFromName(color),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            Text(
                              color,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 20),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatPrice(double price) {
    return PriceFormatter.format(price);
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
      case 'đỏ':
        return Colors.red;
      case 'blue':
      case 'xanh dương':
        return Colors.blue;
      case 'green':
      case 'xanh lá':
        return Colors.green;
      case 'yellow':
      case 'vàng':
        return Colors.yellow;
      case 'orange':
      case 'cam':
        return Colors.orange;
      case 'purple':
      case 'tím':
        return Colors.purple;
      case 'pink':
      case 'hồng':
        return Colors.pink;
      case 'brown':
      case 'nâu':
        return Colors.brown;
      case 'black':
      case 'đen':
        return Colors.black;
      case 'white':
      case 'trắng':
        return Colors.white;
      case 'grey':
      case 'gray':
      case 'xám':
        return Colors.grey;
      case 'navy':
      case 'xanh navy':
        return Colors.indigo;
      case 'beige':
      case 'be':
        return const Color(0xFFF5F5DC);
      case 'khaki':
        return const Color(0xFFF0E68C);
      case 'maroon':
      case 'đỏ đậm':
        return const Color(0xFF800000);
      default:
        return Colors.grey[400]!;
    }
  }

  void _showLoginRequiredDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey[50]!],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(253, 110, 135, 0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        size: 40,
                        color: Color.fromRGBO(253, 110, 135, 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bạn chưa đăng nhập',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF2D3436),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Vui lòng đăng nhập để tiếp tục mua hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        color: Color(0xFF636E72),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Color.fromRGBO(253, 110, 135, 1),
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Hủy',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                color: Color.fromRGBO(253, 110, 135, 1),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [
                                  Color.fromRGBO(253, 110, 135, 1),
                                  Color.fromRGBO(253, 110, 135, 0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromRGBO(
                                    253,
                                    110,
                                    135,
                                    0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
                                  ),
                                );

                                if (mounted &&
                                    AuthService.currentUser != null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đăng nhập thành công! Bạn có thể tiếp tục mua hàng.',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Đăng nhập ngay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
