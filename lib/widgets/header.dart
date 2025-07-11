import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:v_store/screens/signin.dart';
import 'package:v_store/screens/user_profile.dart';
import 'package:v_store/widgets/slide_right_route.dart';
import 'package:v_store/services/auth_service.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Header extends StatefulWidget {
  final VoidCallback? onSearchTap;

  const Header({super.key, this.onSearchTap});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

  List<Product> _allProducts = [];
  List<Product> _searchResults = [];
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;
  bool _showSearchResults = false;

  final List<String> _popularKeywords = [
    'áo thun',
    'quần jean',
    'giày sneaker',
    'váy đầm',
    'túi xách',
    'điện thoại',
    'laptop',
    'tai nghe',
    'đồng hồ',
    'mỹ phẩm',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts();
      setState(() {
        _allProducts = products;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _searchResults = [];
        _showSuggestions = false;
        _showSearchResults = false;
      });
      return;
    }

    final suggestions = <String>{};

    for (final keyword in _popularKeywords) {
      if (keyword.toLowerCase().contains(query)) {
        suggestions.add(keyword);
      }
    }

    for (final product in _allProducts) {
      if (product.name.toLowerCase().contains(query)) {
        suggestions.add(product.name);
      }
    }

    setState(() {
      _searchSuggestions = suggestions.take(5).toList();
      _showSuggestions = suggestions.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xFFF5F5F5)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu, size: 26.0),
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.all(8),
                  ),
                ),
              ),
              GestureDetector(
                onDoubleTap: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đang tải lại dữ liệu sản phẩm...'),
                      backgroundColor: Colors.blue,
                    ),
                  );

                  try {
                    final productService = ProductService();
                    await productService.clearAndReloadProducts();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Đã tải lại dữ liệu thành công! Vui lòng khởi động lại app.',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: Image.asset(
                  'assets/logos/v_store_logo.png',
                  height: 40.0,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<CartService>(
                    builder: (context, cartService, child) {
                      return Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/cart');
                            },
                            icon: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 28.0,
                            ),
                          ),
                          if (cartService.totalItems > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${cartService.totalItems > 99 ? '99+' : cartService.totalItems}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  StreamBuilder<User?>(
                    stream: AuthService.authStateChanges,
                    builder: (context, snapshot) {
                      final User? user = snapshot.data;
                      final bool isLoggedIn = user != null;

                      return IconButton(
                        onPressed: () {
                          if (isLoggedIn) {
                            Navigator.push(
                              context,
                              SlideRightRoute(
                                page: const UserProfileScreen(
                                  showBackButton: true,
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              SlideRightRoute(page: SignInScreen()),
                            );
                          }
                        },
                        icon: CircleAvatar(
                          radius: 23.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: isLoggedIn && user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : AssetImage(
                                      'assets/images/homeImgs/default_avt.png',
                                    )
                                    as ImageProvider,
                          child:
                              isLoggedIn &&
                                  user.photoURL == null &&
                                  (user.displayName?.isEmpty ?? true)
                              ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey[600],
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GestureDetector(
              onTap: () {
                if (widget.onSearchTap != null) {
                  widget.onSearchTap!();
                } else {
                  Navigator.pushNamed(context, '/search');
                }
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.search,
                        color: Color.fromRGBO(187, 187, 187, 1),
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Tìm kiếm sản phẩm...',
                        style: TextStyle(
                          color: Color.fromRGBO(187, 187, 187, 1),
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.mic_none,
                        color: Color.fromRGBO(187, 187, 187, 1),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
