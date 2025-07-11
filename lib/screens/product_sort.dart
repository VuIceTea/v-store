import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/utils/price_formatter.dart';

class ProductSortScreen extends StatefulWidget {
  const ProductSortScreen({super.key});

  @override
  State<ProductSortScreen> createState() => _ProductSortScreenState();
}

class _ProductSortScreenState extends State<ProductSortScreen> {
  ProductService productService = ProductService();
  Future<List<Product>>? _productsFuture;
  List<Product> _allProducts = [];
  List<Product> _sortedProducts = [];

  String _selectedSortOption = 'Mặc định';
  final List<String> _sortOptions = [
    'Mặc định',
    'Giá: Thấp đến Cao',
    'Giá: Cao đến Thấp',
    'Tên: A đến Z',
    'Tên: Z đến A',
    'Số sao: Cao đến Thấp',
    'Số sao: Thấp đến Cao',
    'Mới nhất',
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
  double _maxPrice = 2000000;
  RangeValues _priceRange = RangeValues(0, 2000000);

  double _minRating = 0;
  bool _showDiscountOnly = false;
  bool _showAvailableOnly = true;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _productsFuture = productService.getProducts();
    _loadProducts();
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

          if (_minPrice >= _maxPrice) {
            _maxPrice = _minPrice + 1;
          }

          _priceRange = RangeValues(_minPrice, _maxPrice);
        }
      });
      _applySortAndFilter();
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

    // Price filter
    filteredProducts = filteredProducts.where((product) {
      return product.price >= _priceRange.start &&
          product.price <= _priceRange.end;
    }).toList();

    // Rating filter
    filteredProducts = filteredProducts.where((product) {
      return (product.rating ?? 0) >= _minRating;
    }).toList();

    // Discount filter
    if (_showDiscountOnly) {
      filteredProducts = filteredProducts.where((product) {
        return product.discount != null && product.discount! > 0;
      }).toList();
    }

    // Availability filter
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
      case 'Số sao: Cao đến Thấp':
        filteredProducts.sort(
          (a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0),
        );
        break;
      case 'Số sao: Thấp đến Cao':
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
      case 'Mới nhất':
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
    });
    _applySortAndFilter();
  }

  Widget _buildQuickFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Color.fromRGBO(255, 163, 179, 1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Color.fromRGBO(255, 163, 179, 1)
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Lọc và Sắp xếp',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'Làm mới',
              style: TextStyle(
                color: Color.fromRGBO(255, 163, 179, 1),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sort and Filter
          Container(
            color: Colors.white,
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
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSortOption,
                      isExpanded: true,
                      items: _sortOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedSortOption = newValue;
                          });
                          _applySortAndFilter();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Text(
                  '${_sortedProducts.length} kết quả tìm kiếm',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lọc nhanh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickFilterChip(
                        'Đang giảm giá',
                        _showDiscountOnly,
                        () {
                          setState(() {
                            _showDiscountOnly = !_showDiscountOnly;
                          });
                          _applySortAndFilter();
                        },
                      ),
                      SizedBox(width: 8),
                      _buildQuickFilterChip(
                        'Đánh giá cao (4+)',
                        _minRating >= 4,
                        () {
                          setState(() {
                            _minRating = _minRating >= 4 ? 0 : 4;
                          });
                          _applySortAndFilter();
                        },
                      ),
                      SizedBox(width: 8),
                      _buildQuickFilterChip(
                        'Dưới 500k',
                        _priceRange.end <= 500000,
                        () {
                          setState(() {
                            if (_priceRange.end <= 500000) {
                              _priceRange = RangeValues(_minPrice, _maxPrice);
                            } else {
                              double newEnd = 500000.0.clamp(
                                _minPrice,
                                _maxPrice,
                              );
                              double newStart = _minPrice;
                              _priceRange = RangeValues(newStart, newEnd);
                            }
                          });
                          _applySortAndFilter();
                        },
                      ),
                      SizedBox(width: 8),
                      _buildQuickFilterChip(
                        'Cao cấp (1 triệu+)',
                        _priceRange.start >= 1000000,
                        () {
                          setState(() {
                            if (_priceRange.start >= 1000000) {
                              _priceRange = RangeValues(_minPrice, _maxPrice);
                            } else {
                              double newStart = 1000000.0.clamp(
                                _minPrice,
                                _maxPrice,
                              );
                              double newEnd = _maxPrice;
                              if (newStart > newEnd) newStart = newEnd;
                              _priceRange = RangeValues(newStart, newEnd);
                            }
                          });
                          _applySortAndFilter();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters Section
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 8),
            child: ExpansionTile(
              title: Text(
                'Bộ lọc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Montserrat',
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(height: 16),

                      // Price Range
                      Text(
                        'Khoảng giá',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 8),
                      if (_minPrice < _maxPrice && _allProducts.isNotEmpty) ...[
                        RangeSlider(
                          values: RangeValues(
                            _priceRange.start.clamp(_minPrice, _maxPrice),
                            _priceRange.end.clamp(_minPrice, _maxPrice),
                          ),
                          min: _minPrice,
                          max: _maxPrice,
                          divisions: 20,
                          activeColor: Color.fromRGBO(255, 163, 179, 1),
                          labels: RangeLabels(
                            PriceFormatter.format(_priceRange.start),
                            PriceFormatter.format(_priceRange.end),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              double start = values.start.clamp(
                                _minPrice,
                                _maxPrice,
                              );
                              double end = values.end.clamp(
                                _minPrice,
                                _maxPrice,
                              );

                              if (start > end) {
                                double temp = start;
                                start = end;
                                end = temp;
                              }

                              _priceRange = RangeValues(start, end);
                            });
                          },
                          onChangeEnd: (RangeValues values) {
                            _applySortAndFilter();
                          },
                        ),
                        Text(
                          '${PriceFormatter.format(_priceRange.start)} - ${PriceFormatter.format(_priceRange.end)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Text(
                              'Đang tải khoảng giá...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: 16),

                      // Rating
                      Text(
                        'Đánh giá',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 8),
                      Slider(
                        value: _minRating,
                        min: 0,
                        max: 5,
                        divisions: 10,
                        activeColor: Color.fromRGBO(255, 163, 179, 1),
                        label: _minRating.toString(),
                        onChanged: (double value) {
                          setState(() {
                            _minRating = value;
                          });
                        },
                        onChangeEnd: (double value) {
                          _applySortAndFilter();
                        },
                      ),
                      Text(
                        '${_minRating.toStringAsFixed(1)} sao trở lên',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      SizedBox(height: 16),

                      SwitchListTile(
                        title: Text(
                          'Chỉ hiển thị sản phẩm đang giảm giá',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        value: _showDiscountOnly,
                        activeColor: Color.fromRGBO(255, 163, 179, 1),
                        onChanged: (bool value) {
                          setState(() {
                            _showDiscountOnly = value;
                          });
                          _applySortAndFilter();
                        },
                      ),
                      SwitchListTile(
                        title: Text(
                          'Chỉ hiển thị sản phẩm có sẵn',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                        value: _showAvailableOnly,
                        activeColor: Color.fromRGBO(255, 163, 179, 1),
                        onChanged: (bool value) {
                          setState(() {
                            _showAvailableOnly = value;
                          });
                          _applySortAndFilter();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _sortedProducts.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Không tìm thấy sản phẩm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Thử điều chỉnh bộ lọc của bạn',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _isGridView
                ? GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _sortedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _sortedProducts[index];
                      return _buildProductCard(product);
                    },
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _sortedProducts.length,
                    itemBuilder: (context, index) {
                      final product = _sortedProducts[index];
                      return _buildProductListItem(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-details',
          arguments: {'product': product, 'currentTabIndex': 0},
        );
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 40,
                          ),
                        );
                      },
                    ),
                    // Discount badge
                    if (product.discount != null && product.discount! > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discount!.toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
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
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Flexible(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 2),

                    // Category
                    Text(
                      product.category.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 2),

                    // Price
                    Flexible(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              product.discount != null && product.discount! > 0
                                  ? PriceFormatter.format(
                                      product.price *
                                          (1 - product.discount! / 100),
                                    )
                                  : PriceFormatter.format(product.price),
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          if (product.discount != null &&
                              product.discount! > 0) ...[
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                PriceFormatter.format(product.price),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 2),

                    // Rating
                    Flexible(
                      child: Row(
                        children: [
                          StarRating(
                            rating: product.rating ?? 0.0,
                            size: 16.0,
                            color: Colors.amber,
                            borderColor: Colors.grey,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '(${product.reviewCount ?? 0})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
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
  }

  Widget _buildProductListItem(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-details',
          arguments: {'product': product, 'currentTabIndex': 0},
        );
      },
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade400,
                            size: 30,
                          ),
                        );
                      },
                    ),
                    // Discount badge
                    if (product.discount != null && product.discount! > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discount!.toInt()}%',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),

                    // Category
                    Text(
                      product.category.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    SizedBox(height: 4),

                    // Description
                    Text(
                      product.description ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Montserrat',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // Price and Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.discount != null && product.discount! > 0
                                  ? PriceFormatter.format(
                                      product.price *
                                          (1 - product.discount! / 100),
                                    )
                                  : PriceFormatter.format(product.price),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                            if (product.discount != null &&
                                product.discount! > 0)
                              Text(
                                PriceFormatter.format(product.price),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),

                        // Rating
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StarRating(
                                  rating: product.rating ?? 0.0,
                                  size: 14.0,
                                  color: Colors.amber,
                                  borderColor: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  product.rating?.toStringAsFixed(1) ?? '0.0',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '(${product.reviewCount ?? 0} đánh giá)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
