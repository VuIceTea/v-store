import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:provider/provider.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/utils/price_formatter.dart';
import 'package:v_store/widgets/appdrawer.dart';
import 'package:v_store/widgets/header.dart';
import 'package:v_store/providers/category_notifier.dart';

class WishlistProduct extends StatefulWidget {
  const WishlistProduct({super.key});

  @override
  _WishlistProductState createState() => _WishlistProductState();
}

class _WishlistProductState extends State<WishlistProduct> {
  ProductService productService = ProductService();
  Future? futureProducts;
  final ScrollController _productsScrollController = ScrollController();
  List<Product> _allProducts = [];
  List<Product> _sortedProducts = [];

  String _selectedSortOption = 'Mặc định';
  final List<String> _sortOptions = [
    'Mặc định',
    'Giá: Thấp đến Cao',
    'Giá: Cao đến Thấp',
    'Tên: A đến Z',
    'Tên: Z đến A',
    'Đánh giá: Cao đến Thấp',
    'Đánh giá: Thấp đến Cao',
    'Phổ biến nhất',
    'Giảm giá: Cao đến Thấp',
  ];

  final List<String> _selectedCategories = [];
  final List<String> _categories = [
    'Làm Đẹp',
    'Thời Trang',
    'Trẻ Em',
    'Nam',
    'Nữ',
  ];

  double _minPrice = 0;
  double _maxPrice = 200;
  RangeValues _priceRange = RangeValues(0, 200);

  double _minRating = 0;
  bool _showDiscountOnly = false;
  bool _showAvailableOnly = true;
  final bool _isGridView = true;

  bool _showSortOptions = false;
  bool _showFilterOptions = false;

  @override
  void initState() {
    super.initState();
    futureProducts = productService.getProducts();
    _loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final categoryNotifier = Provider.of<CategoryNotifier>(context);
    final selectedCategory = categoryNotifier.selectedCategory;

    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      if (!_selectedCategories.contains(selectedCategory)) {
        _selectedCategories.clear();
        _selectedCategories.add(selectedCategory);
        _applySortAndFilter();
      }
    }
  }

  void _loadProducts() async {
    try {
      final products = await productService.getProducts();
      setState(() {
        _allProducts = products;
        _sortedProducts = List.from(products);

        if (products.isNotEmpty) {
          _minPrice = products
              .map((p) => p.price)
              .reduce((a, b) => a < b ? a : b);
          _maxPrice = products
              .map((p) => p.price)
              .reduce((a, b) => a > b ? a : b);
          _priceRange = RangeValues(_minPrice, _maxPrice);
        }

        if (_selectedCategories.isNotEmpty) {
          _applySortAndFilter();
        }
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _applySortAndFilter() {
    List<Product> filteredProducts = List.from(_allProducts);

    if (_selectedCategories.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return _selectedCategories.contains(product.category.name);
      }).toList();
    }

    filteredProducts = filteredProducts.where((product) {
      return product.price >= _priceRange.start &&
          product.price <= _priceRange.end;
    }).toList();

    filteredProducts = filteredProducts.where((product) {
      return (product.rating ?? 0) >= _minRating;
    }).toList();

    if (_showDiscountOnly) {
      filteredProducts = filteredProducts.where((product) {
        return product.discount != null && product.discount! > 0;
      }).toList();
    }

    if (_showAvailableOnly) {
      filteredProducts = filteredProducts.where((product) {
        return product.isAvailable == true;
      }).toList();
    }

    switch (_selectedSortOption) {
      case 'Giá: Thấp đến Cao':
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Giá: Cao đến Thấp':
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Tên: A đến Z':
        filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Tên: Z đến A':
        filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'Đánh giá: Cao đến Thấp':
        filteredProducts.sort(
          (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
        );
        break;
      case 'Đánh giá: Thấp đến Cao':
        filteredProducts.sort(
          (a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0),
        );
        break;
      case 'Phổ biến nhất':
        filteredProducts.sort(
          (a, b) => (b.reviewCount ?? 0).compareTo(a.reviewCount ?? 0),
        );
        break;
      case 'Giảm giá: Cao đến Thấp':
        filteredProducts.sort(
          (a, b) => (b.discount ?? 0).compareTo(a.discount ?? 0),
        );
        break;
      case 'Mặc định':
      default:
        break;
    }

    setState(() {
      _sortedProducts = filteredProducts;
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedSortOption = 'Mặc định';
      _selectedCategories.clear();
      _priceRange = RangeValues(_minPrice, _maxPrice);
      _minRating = 0;
      _showDiscountOnly = false;
      _showAvailableOnly = true;
      _showSortOptions = false;
      _showFilterOptions = false;
    });
    _applySortAndFilter();
  }

  @override
  void dispose() {
    _productsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          //Header
          Container(
            color: Color(0xFFF5F5F5),
            padding: EdgeInsets.only(top: 50.0),
            child: Header(),
          ),

          Consumer<CategoryNotifier>(
            builder: (context, categoryNotifier, child) {
              final selectedCategory = categoryNotifier.selectedCategory;
              if (selectedCategory == null || selectedCategory.isEmpty) {
                return SizedBox.shrink();
              }

              return Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 163, 179, 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: Color.fromRGBO(255, 163, 179, 1),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.filter_alt,
                      color: Color.fromRGBO(255, 163, 179, 1),
                      size: 20.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Đang lọc theo: $selectedCategory',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(255, 163, 179, 1),
                      ),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategories.remove(selectedCategory);
                        });
                        categoryNotifier.clearSelectedCategory();
                        _applySortAndFilter();
                      },
                      child: Icon(
                        Icons.close,
                        color: Color.fromRGBO(255, 163, 179, 1),
                        size: 18.0,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Sort and Filter Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_sortedProducts.length} Sản phẩm',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showSortOptions = !_showSortOptions;
                          _showFilterOptions = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _showSortOptions
                            ? Color.fromRGBO(255, 163, 179, 1)
                            : Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size(0, 0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Sắp xếp',
                            style: TextStyle(
                              color: _showSortOptions
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.swap_vert_rounded,
                            size: 18,
                            color: _showSortOptions
                                ? Colors.white
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showFilterOptions = !_showFilterOptions;
                          _showSortOptions = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _showFilterOptions
                            ? Color.fromRGBO(255, 163, 179, 1)
                            : Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: Size(0, 0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bộ lọc',
                            style: TextStyle(
                              color: _showFilterOptions
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 13,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.filter_alt_outlined,
                            size: 18,
                            color: _showFilterOptions
                                ? Colors.white
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                    if (_selectedCategories.isNotEmpty ||
                        _showDiscountOnly ||
                        _selectedSortOption != 'Mặc định' ||
                        _minRating > 0 ||
                        _priceRange.start != _minPrice ||
                        _priceRange.end != _maxPrice)
                      IconButton(
                        onPressed: _resetFilters,
                        icon: Icon(
                          Icons.clear,
                          color: Color.fromRGBO(255, 163, 179, 1),
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Sort Options Panel
          if (_showSortOptions)
            Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sắp xếp theo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((option) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSortOption = option;
                            _showSortOptions = false;
                          });
                          _applySortAndFilter();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _selectedSortOption == option
                                ? Color.fromRGBO(255, 163, 179, 1)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              color: _selectedSortOption == option
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Filter Options Panel
          if (_showFilterOptions)
            Container(
              color: Colors.white,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lọc theo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 12),

                  Text(
                    'Danh mục',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((category) {
                      return FilterChip(
                        label: Text(category),
                        selected: _selectedCategories.contains(category),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(category);
                            } else {
                              _selectedCategories.remove(category);
                            }
                          });
                          _applySortAndFilter();
                        },
                        selectedColor: Color.fromRGBO(255, 163, 179, 0.3),
                        checkmarkColor: Color.fromRGBO(255, 163, 179, 1),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12),

                  // Price Range
                  Text(
                    'Khoảng giá: ${PriceFormatter.format(_priceRange.start)} - ${PriceFormatter.format(_priceRange.end)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: _minPrice,
                    max: _maxPrice,
                    divisions: 20,
                    activeColor: Color.fromRGBO(255, 163, 179, 1),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                    onChangeEnd: (RangeValues values) {
                      _applySortAndFilter();
                    },
                  ),
                  SizedBox(height: 12),

                  // Quick Filters
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Đang Giảm Giá',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          value: _showDiscountOnly,
                          activeColor: Color.fromRGBO(255, 163, 179, 1),
                          onChanged: (bool? value) {
                            setState(() {
                              _showDiscountOnly = value ?? false;
                            });
                            _applySortAndFilter();
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: Text(
                            'Còn Hàng',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          value: _showAvailableOnly,
                          activeColor: Color.fromRGBO(255, 163, 179, 1),
                          onChanged: (bool? value) {
                            setState(() {
                              _showAvailableOnly = value ?? true;
                            });
                            _applySortAndFilter();
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          SizedBox(height: 20),
          Expanded(child: _renderListProducts()),
        ],
      ),
    );
  }

  Widget _renderListProducts() {
    if (_allProducts.isEmpty) {
      return FutureBuilder(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('Không có sản phẩm nào!'));
          }
          return Center(child: CircularProgressIndicator());
        },
      );
    }

    if (_sortedProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không tìm thấy sản phẩm phù hợp',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Montserrat',
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 163, 179, 1),
              ),
              child: Text('Xóa bộ lọc', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _productsScrollController,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _sortedProducts.length,
      itemBuilder: (context, index) {
        final product = _sortedProducts[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product-details',
              arguments: {'product': product, 'currentTabIndex': 1},
            );
          },
          child: Card(
            elevation: 2,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),

                // Product Details
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.0),
                          Row(
                            children: [
                              Text(
                                product.discount != null &&
                                        product.discount! > 0
                                    ? PriceFormatter.formatWithDiscount(
                                        product.price,
                                        product.discount!,
                                      )
                                    : PriceFormatter.format(product.price),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w600,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.0),
                          if (product.discount != null &&
                              product.discount! > 0) ...[
                            Row(
                              children: [
                                Text(
                                  PriceFormatter.format(product.price),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.0),
                          ],

                          // Rating Section
                          Row(
                            children: [
                              StarRating(
                                rating: product.rating ?? 0.0,
                                size: 15.0,
                                color: Colors.amber,
                                borderColor: Colors.grey,
                              ),
                              SizedBox(width: 4.0),
                              Text(
                                '(${product.reviewCount ?? 0})',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
