import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:provider/provider.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:v_store/services/review_service.dart';
import 'package:v_store/services/order_service.dart';
import 'package:v_store/utils/price_formatter.dart';
import 'package:v_store/widgets/appdrawer.dart';
import 'package:v_store/widgets/header.dart';
import 'package:v_store/widgets/product_bottom_navigation.dart';
import 'package:v_store/screens/signin.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final int? currentTabIndex;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.currentTabIndex,
  });

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetailScreen> {
  int selectedImageIndex = 0;
  String selectedSize = '';
  String? selectedColor;
  int quantity = 1;
  bool isExpanded = false;

  ProductService productService = ProductService();
  ReviewService reviewService = ReviewService();
  List<Product> similarProducts = [];
  bool loadingSimilarProducts = true;
  static List<Product>? _cachedProducts;
  static DateTime? _cacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  List<dynamic> _productReviews = [];
  bool _loadingReviews = true;
  bool _hasUserReviewed = false;
  bool _hasUserPurchased = false;
  bool _checkingPurchaseStatus = false;

  CartItem? _pendingDirectPurchase;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontFamily: 'Montserrat'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Đã hiểu',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSimilarProducts();
    _loadReviews();
    _checkUserPurchaseStatus();
  }

  @override
  void dispose() {
    _pendingDirectPurchase = null;
    super.dispose();
  }

  void _loadReviews() async {
    try {
      if (mounted) {
        setState(() {
          _loadingReviews = true;
        });
      }

      print('Loading reviews for product: ${widget.product.productId}');

      try {
        final firestoreReviews = await reviewService.getProductReviews(
          widget.product.productId,
        );
        final hasUserReviewed = await reviewService.hasUserReviewed(
          widget.product.productId,
        );

        if (mounted) {
          setState(() {
            _productReviews = firestoreReviews;
            _hasUserReviewed = hasUserReviewed;
            _loadingReviews = false;

            print('Loaded ${firestoreReviews.length} reviews from Firestore');
            print('User has reviewed: $hasUserReviewed');
          });
        }
      } catch (firestoreError) {
        print('Lỗi tải đánh giá từ Firestore: $firestoreError');
        if (mounted) {
          setState(() {
            _productReviews = widget.product.reviews ?? [];
            _hasUserReviewed = false;
            _loadingReviews = false;
          });
        }
      }
    } catch (e) {
      print('Lỗi tải đánh giá: $e');
      if (mounted) {
        setState(() {
          _productReviews = widget.product.reviews ?? [];
          _loadingReviews = false;
          _hasUserReviewed = false;
        });
      }
    }
  }

  void _checkUserPurchaseStatus() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) {
      if (mounted) {
        setState(() {
          _hasUserPurchased = false;
          _checkingPurchaseStatus = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _checkingPurchaseStatus = true;
        });
      }

      final hasPurchased = await OrderService.hasUserPurchasedProduct(
        currentUser.uid,
        widget.product.productId,
      );

      if (mounted) {
        setState(() {
          _hasUserPurchased = hasPurchased;
          _checkingPurchaseStatus = false;
        });
      }

      print(
        'User purchase status for ${widget.product.productId}: $hasPurchased',
      );
    } catch (e) {
      print('Lỗi kiểm tra trạng thái mua hàng: $e');
      if (mounted) {
        setState(() {
          _hasUserPurchased = false;
          _checkingPurchaseStatus = false;
        });
      }
    }
  }

  void _loadSimilarProducts() async {
    try {
      List<Product> allProducts;

      final now = DateTime.now();
      final isCacheValid =
          _cachedProducts != null &&
          _cacheTime != null &&
          now.difference(_cacheTime!).compareTo(_cacheValidDuration) < 0;

      if (isCacheValid) {
        allProducts = _cachedProducts!;
      } else {
        allProducts = await productService.getProducts();
        _cachedProducts = allProducts;
        _cacheTime = now;
      }

      final similar = allProducts
          .where((product) {
            return product.category.categoryId ==
                    widget.product.category.categoryId &&
                product.productId != widget.product.productId;
          })
          .take(5)
          .toList();

      if (mounted) {
        setState(() {
          similarProducts = similar;
          loadingSimilarProducts = false;
        });
      }
    } catch (e) {
      print('Lỗi tải sản phẩm tương tự: $e');
      if (mounted) {
        setState(() {
          loadingSimilarProducts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final discountedPrice =
        widget.product.discount != null && widget.product.discount! > 0
        ? widget.product.price * (1 - widget.product.discount! / 100)
        : widget.product.price;

    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 50),
            color: Color(0xFFF5F5F5),
            child: Header(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 400,
                    color: Colors.grey[50],
                    child: Stack(
                      children: [
                        PageView.builder(
                          onPageChanged: (index) {
                            setState(() {
                              selectedImageIndex = index;
                            });
                          },
                          itemCount: widget.product.images?.length ?? 1,
                          itemBuilder: (context, index) {
                            final imageUrl =
                                widget.product.images?[index] ??
                                widget.product.imageUrl;
                            return Container(
                              margin: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                        size: 80,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        Positioned(
                          top: 40,
                          left: 20,
                          child: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.arrow_back_ios_new, size: 18),
                              padding: EdgeInsets.only(left: 4),
                            ),
                          ),
                        ),

                        if (widget.product.images != null &&
                            widget.product.images!.length > 1)
                          Positioned(
                            bottom: 20,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.product.images!.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectedImageIndex == index
                                        ? Colors.black
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Product Information Section
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.product.category.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 12),

                        Row(
                          children: [
                            StarRating(
                              rating: widget.product.rating ?? 0.0,
                              size: 20.0,
                              color: Colors.amber,
                              borderColor: Colors.grey,
                            ),
                            SizedBox(width: 8),
                            Text(
                              widget.product.rating?.toStringAsFixed(1) ??
                                  '0.0',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '(${widget.product.reviewCount ?? 0} đánh giá)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Price section
                        Row(
                          children: [
                            Text(
                              _formatPrice(discountedPrice),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.redAccent,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            if (widget.product.discount != null &&
                                widget.product.discount! > 0) ...[
                              SizedBox(width: 12),
                              Text(
                                _formatPrice(widget.product.price),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '-${widget.product.discount!.toInt()}%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 20),

                        // Size selection
                        if (widget.product.sizes != null &&
                            widget.product.sizes!.isNotEmpty) ...[
                          Text(
                            'Kích cỡ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: widget.product.sizes!.map((size) {
                              final isSelected = selectedSize == size;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSize = size;
                                  });
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      size,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                        ],

                        // Color selection
                        if (widget.product.colors != null &&
                            widget.product.colors!.isNotEmpty) ...[
                          Text(
                            'Màu sắc',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: widget.product.colors!.map((color) {
                              final isSelected = selectedColor == color;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _getColorFromName(color),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.grey[300]!,
                                      width: isSelected ? 3 : 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                        ],

                        Row(
                          children: [
                            Text(
                              'Số lượng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: quantity > 1
                                        ? () {
                                            setState(() {
                                              quantity--;
                                            });
                                          }
                                        : null,
                                    icon: Icon(Icons.remove),
                                    constraints: BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      '$quantity',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        quantity++;
                                      });
                                    },
                                    icon: Icon(Icons.add),
                                    constraints: BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mô tả sản phẩm',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: Text(
                            widget.product.description ?? 'Không có mô tả.',
                            maxLines: isExpanded ? null : 3,
                            overflow: isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.5,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Delivery info
                        _buildInfoRow(
                          Icons.local_shipping,
                          'Miễn phí vận chuyển',
                          'Đơn hàng trên 200.000đ',
                        ),
                        SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.refresh,
                          'Chính sách đổi trả',
                          'Đổi trả trong 30 ngày',
                        ),
                        SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () {
                                  bool requiresSize =
                                      widget.product.sizes != null &&
                                      widget.product.sizes!.isNotEmpty;
                                  bool requiresColor =
                                      widget.product.colors != null &&
                                      widget.product.colors!.isNotEmpty;

                                  if (requiresSize && selectedSize.isEmpty) {
                                    _showErrorDialog('Chưa chọn kích cỡ');
                                    return;
                                  }

                                  if (requiresColor && selectedColor == null) {
                                    _showErrorDialog('Chưa chọn màu sắc');
                                    return;
                                  }

                                  final cartService = Provider.of<CartService>(
                                    context,
                                    listen: false,
                                  );
                                  cartService.addToCart(
                                    widget.product,
                                    quantity: quantity,
                                    size: selectedSize,
                                    color: selectedColor,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đã thêm vào giỏ hàng!'),
                                      backgroundColor: Colors.green,
                                      action: SnackBarAction(
                                        label: 'Xem giỏ hàng',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/cart');
                                        },
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Thêm vào giỏ hàng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  bool requiresSize =
                                      widget.product.sizes != null &&
                                      widget.product.sizes!.isNotEmpty;
                                  bool requiresColor =
                                      widget.product.colors != null &&
                                      widget.product.colors!.isNotEmpty;

                                  if (requiresSize && selectedSize.isEmpty) {
                                    _showErrorDialog('Chưa chọn kích cỡ');
                                    return;
                                  }

                                  if (requiresColor && selectedColor == null) {
                                    _showErrorDialog('Chưa chọn màu sắc');
                                    return;
                                  }

                                  final currentUser = AuthService.currentUser;
                                  if (currentUser == null) {
                                    _pendingDirectPurchase = CartItem(
                                      product: widget.product,
                                      quantity: quantity,
                                      selectedSize: selectedSize,
                                      selectedColor: selectedColor,
                                    );

                                    await _showLoginRequiredDialog();
                                    return;
                                  }

                                  final directPurchaseItem = CartItem(
                                    product: widget.product,
                                    quantity: quantity,
                                    selectedSize: selectedSize,
                                    selectedColor: selectedColor,
                                  );

                                  Navigator.pushNamed(
                                    context,
                                    '/checkout',
                                    arguments: [directPurchaseItem],
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  'Mua ngay',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(Icons.compare_arrows, 'So sánh'),
                            _buildActionButton(Icons.share, 'Chia sẻ'),
                            _buildActionButton(
                              Icons.help_outline,
                              'Đặt câu hỏi',
                            ),
                          ],
                        ),
                        SizedBox(height: 32),

                        // Reviews section
                        _buildReviewsSection(),
                        SizedBox(height: 32),

                        // Similar items section
                        Text(
                          'Có thể bạn cũng thích',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          height: 320,
                          child: loadingSimilarProducts
                              ? Center(child: CircularProgressIndicator())
                              : similarProducts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shopping_bag_outlined,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Không tìm thấy sản phẩm tương tự',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontFamily: 'Montserrat',
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  itemCount: similarProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = similarProducts[index];
                                    final discountedPrice =
                                        product.discount != null &&
                                            product.discount! > 0
                                        ? product.price *
                                              (1 - product.discount! / 100)
                                        : product.price;

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductDetailScreen(
                                                  product: product,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 160,
                                        margin: EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.1,
                                              ),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 140,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                      top: Radius.circular(12),
                                                    ),
                                                child: Stack(
                                                  children: [
                                                    Image.network(
                                                      product.imageUrl,
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Container(
                                                              color: Colors
                                                                  .grey[200],
                                                              child: Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                size: 40,
                                                                color: Colors
                                                                    .grey[400],
                                                              ),
                                                            );
                                                          },
                                                    ),
                                                    if (product.discount !=
                                                            null &&
                                                        product.discount! > 0)
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 6,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            '-${product.discount!.toInt()}%',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Product Details
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      product.name,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontFamily:
                                                            'Montserrat',
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 6),

                                                    // Rating
                                                    Row(
                                                      children: [
                                                        StarRating(
                                                          rating:
                                                              product.rating ??
                                                              0.0,
                                                          size: 14.0,
                                                          color: Colors.amber,
                                                          borderColor:
                                                              Colors.grey,
                                                        ),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            '(${product.reviewCount ?? 0})',
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[600],
                                                              fontFamily:
                                                                  'Montserrat',
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),

                                                    // Price section
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _formatPrice(
                                                            discountedPrice,
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .redAccent,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontFamily:
                                                                'Montserrat',
                                                          ),
                                                        ),
                                                        if (product.discount !=
                                                                null &&
                                                            product.discount! >
                                                                0)
                                                          Text(
                                                            _formatPrice(
                                                              product.price,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors
                                                                  .grey[500],
                                                              decoration:
                                                                  TextDecoration
                                                                      .lineThrough,
                                                              fontFamily:
                                                                  'Montserrat',
                                                            ),
                                                          ),
                                                      ],
                                                    ),

                                                    Spacer(),

                                                    SizedBox(
                                                      width: double.infinity,
                                                      height: 32,
                                                      child: Consumer<CartService>(
                                                        builder:
                                                            (
                                                              context,
                                                              cartService,
                                                              child,
                                                            ) {
                                                              final isInCart =
                                                                  cartService
                                                                      .isInCart(
                                                                        product
                                                                            .productId,
                                                                      );
                                                              return ElevatedButton(
                                                                onPressed: () {
                                                                  if (isInCart) {
                                                                    Navigator.pushNamed(
                                                                      context,
                                                                      '/cart',
                                                                    );
                                                                  } else {
                                                                    String?
                                                                    defaultSize;
                                                                    String?
                                                                    defaultColor;

                                                                    if (product.sizes !=
                                                                            null &&
                                                                        product
                                                                            .sizes!
                                                                            .isNotEmpty) {
                                                                      defaultSize = product
                                                                          .sizes!
                                                                          .first;
                                                                    }
                                                                    if (product.colors !=
                                                                            null &&
                                                                        product
                                                                            .colors!
                                                                            .isNotEmpty) {
                                                                      defaultColor = product
                                                                          .colors!
                                                                          .first;
                                                                    }

                                                                    cartService.addToCart(
                                                                      product,
                                                                      size:
                                                                          defaultSize,
                                                                      color:
                                                                          defaultColor,
                                                                    );
                                                                    ScaffoldMessenger.of(
                                                                      context,
                                                                    ).showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text(
                                                                              'Đã thêm ${product.name} vào giỏ hàng!',
                                                                            ),
                                                                        backgroundColor:
                                                                            Colors.green,
                                                                        duration: Duration(
                                                                          seconds:
                                                                              2,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      isInCart
                                                                      ? Colors
                                                                            .grey[600]
                                                                      : Colors
                                                                            .black,
                                                                  padding:
                                                                      EdgeInsets.symmetric(
                                                                        vertical:
                                                                            0,
                                                                      ),
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          8,
                                                                        ),
                                                                  ),
                                                                ),
                                                                child: Text(
                                                                  isInCart
                                                                      ? 'Xem giỏ'
                                                                      : 'Thêm vào giỏ',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontFamily:
                                                                        'Montserrat',
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProductBottomNavigation(
        currentTabIndex: widget.currentTabIndex,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, size: 24, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'purple':
        return Colors.purple;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey[300]!;
    }
  }

  Widget _buildReviewsSection() {
    if (_loadingReviews) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_productReviews.isEmpty) {
      return _buildNoReviewsSection();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewSummary(),
        const SizedBox(height: 16),
        _buildReviewsList(),
      ],
    );
  }

  Widget _buildNoReviewsSection() {
    final currentUser = AuthService.currentUser;
    final canWriteReview =
        currentUser != null && _hasUserPurchased && !_hasUserReviewed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá sản phẩm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 12),
              Text(
                'Chưa có đánh giá nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  fontFamily: 'Montserrat',
                ),
              ),
              SizedBox(height: 8),
              Text(
                canWriteReview
                    ? 'Hãy là người đầu tiên đánh giá sản phẩm này'
                    : currentUser == null
                    ? 'Đăng nhập và mua sản phẩm để viết đánh giá'
                    : !_hasUserPurchased
                    ? 'Mua sản phẩm để có thể viết đánh giá'
                    : 'Bạn đã viết đánh giá cho sản phẩm này',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              if (canWriteReview)
                ElevatedButton(
                  onPressed: () {
                    _showReviewDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Viết đánh giá',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                )
              else if (currentUser == null)
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Đăng nhập để đánh giá',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSummary() {
    double averageRating = widget.product.rating ?? 0.0;
    if (averageRating == 0.0 && _productReviews.isNotEmpty) {
      double sum = _productReviews.fold(
        0.0,
        (sum, review) => sum + review.rating,
      );
      averageRating = sum / _productReviews.length;
    }

    final totalReviews = _productReviews.length;

    Map<int, int> ratingCount = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var review in _productReviews) {
      int rating = review.rating.round();
      if (rating >= 1 && rating <= 5) {
        ratingCount[rating] = ratingCount[rating]! + 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá sản phẩm',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 4),
                    StarRating(
                      rating: averageRating,
                      size: 20,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$totalReviews đánh giá',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    for (int star = 5; star >= 1; star--)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Text(
                              '$star',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.star, size: 12, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: totalReviews > 0
                                    ? (ratingCount[star]! / totalReviews)
                                    : 0.0,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.orange,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '${ratingCount[star]}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList() {
    final displayedReviews = _productReviews.take(3).toList();

    final currentUser = AuthService.currentUser;
    final canWriteReview =
        currentUser != null && _hasUserPurchased && !_hasUserReviewed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Nhận xét từ khách hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            Wrap(
              children: [
                if (_productReviews.length > 3)
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Xem tất cả đánh giá - Sẽ sớm được cập nhật!',
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    child: Text(
                      'Xem tất cả (${_productReviews.length})',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (canWriteReview)
                  TextButton(
                    onPressed: () => _showReviewDialog(),
                    child: Text(
                      'Viết đánh giá',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (currentUser == null)
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signin');
                    },
                    child: Text(
                      'Đăng nhập để đánh giá',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (!_hasUserPurchased)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cần mua để đánh giá',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12),
        ...displayedReviews.map((review) => _buildReviewItem(review)),
      ],
    );
  }

  Widget _buildReviewItem(review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[100],
                child:
                    review.userAvatar != null &&
                        review.userAvatar!.isNotEmpty &&
                        !review.userAvatar!.contains('w=100&h=100&fit=crop') &&
                        !review.userAvatar!.contains(
                          'photo-1517841903204-33b7b0c15939',
                        )
                    ? ClipOval(
                        child: Image.network(
                          review.userAvatar!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.blue[100],
                              child: Text(
                                review.userName.isNotEmpty
                                    ? review.userName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.blue[100],
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue[700],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Đã mua',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        StarRating(
                          rating: review.rating,
                          size: 14,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Text(
                          review.date != null
                              ? _formatReviewDate(review.date!)
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.content != null && review.content!.isNotEmpty) ...[
            SizedBox(height: 12),
            Text(
              review.content!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
          if (review.images != null && review.images!.isNotEmpty) ...[
            SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(right: 8),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        review.images![index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                              size: 24,
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _showReviewDialog() async {
    final currentUser = AuthService.currentUser;

    if (currentUser == null) {
      _showErrorDialog('Bạn cần đăng nhập để viết đánh giá sản phẩm.');
      return;
    }

    if (!_hasUserPurchased) {
      _showErrorDialog(
        'Bạn cần mua sản phẩm này trước khi có thể viết đánh giá.',
      );
      return;
    }

    if (_hasUserReviewed) {
      _showErrorDialog('Bạn đã viết đánh giá cho sản phẩm này rồi.');
      return;
    }

    double rating = 5.0;
    String content = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Đánh giá sản phẩm',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.product.imageUrl,
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
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Montserrat',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Đánh giá của bạn:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StarRating(
                          rating: rating,
                          size: 30,
                          color: Colors.orange,
                          allowHalfRating: false,
                          onRatingChanged: (newRating) {
                            setState(() {
                              rating = newRating;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getRatingText(rating),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Nhận xét (tùy chọn):',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      maxLines: 4,
                      onChanged: (value) {
                        content = value;
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Chia sẻ trải nghiệm của bạn về sản phẩm này...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      style: const TextStyle(fontFamily: 'Montserrat'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () => _submitReview(rating, content),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Gửi đánh giá',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getRatingText(double rating) {
    switch (rating.round()) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Rất tốt';
      default:
        return '';
    }
  }

  Future<void> _submitReview(double rating, String content) async {
    try {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang gửi đánh giá...'),
          backgroundColor: Colors.blue,
        ),
      );

      await reviewService.addReview(
        productId: widget.product.productId,
        rating: rating,
        content: content.trim().isNotEmpty
            ? content.trim()
            : 'Người dùng chưa để lại nhận xét',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      _loadReviews();
      _checkUserPurchaseStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá của bạn đã được gửi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gửi đánh giá: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatPrice(double price) {
    return PriceFormatter.format(price);
  }

  Future<void> _showLoginRequiredDialog() async {
    await showGeneralDialog(
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
                        Icons.shopping_cart_outlined,
                        size: 40,
                        color: Color.fromRGBO(253, 110, 135, 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Cần đăng nhập để mua hàng',
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
                      'Vui lòng đăng nhập để tiếp tục đặt hàng sản phẩm này',
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
                              _pendingDirectPurchase = null;
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
                                    AuthService.currentUser != null &&
                                    _pendingDirectPurchase != null) {
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );

                                  if (mounted && context.mounted) {
                                    try {
                                      Navigator.pushNamed(
                                        context,
                                        '/checkout',
                                        arguments: [_pendingDirectPurchase!],
                                      );

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Đăng nhập thành công! Tiếp tục đặt hàng.',
                                            style: TextStyle(
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );

                                      _pendingDirectPurchase = null;
                                    } catch (e) {
                                      print('Error navigating to checkout: $e');
                                      _pendingDirectPurchase = null;
                                    }
                                  }
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
