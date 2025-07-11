import 'package:flutter/material.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/utils/price_formatter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();

  List<Product> _allProducts = [];
  List<Product> _searchResults = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  final List<String> _popularKeywords = [
    'áo thun',
    'quần jean',
    'giày sneaker',
    'váy đầm',
    'túi xách',
    'đầm maxi',
    'áo sơ mi',
    'son dưỡng',
    'đồng hồ',
    'mỹ phẩm',
    'son môi',
    'kem dưỡng',
    'áo khoác',
    'quần short',
    'sandal',
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
      _searchSuggestions = suggestions.take(8).toList();
      _showSuggestions = suggestions.isNotEmpty;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
    });

    final results = _allProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          (product.description?.toLowerCase().contains(query.toLowerCase()) ??
              false);
    }).toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Widget _buildSuggestionItem(String suggestion) {
    return ListTile(
      leading: Icon(Icons.search, color: Colors.grey[600], size: 20),
      title: Text(suggestion, style: TextStyle(fontSize: 14)),
      trailing: Icon(Icons.north_west, color: Colors.grey[400], size: 16),
      onTap: () {
        _searchController.text = suggestion;
        _performSearch(suggestion);
      },
    );
  }

  Widget _buildPopularKeywords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Tìm kiếm phổ biến',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularKeywords.take(10).map((keyword) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = keyword;
                  _performSearch(keyword);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    keyword,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[200],
                child: Icon(Icons.image, color: Colors.grey),
              );
            },
          ),
        ),
        title: Text(
          product.name,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              product.discount != null && product.discount! > 0
                  ? PriceFormatter.formatWithDiscount(
                      product.price,
                      product.discount,
                    )
                  : PriceFormatter.format(product.price),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            if (product.discount != null && product.discount! > 0)
              Row(
                children: [
                  Text(
                    PriceFormatter.format(product.price),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '-${product.discount!.toInt()}%',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/product-details',
            arguments: {'product': product, 'currentTabIndex': 2},
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667eea),
                Color(0xFF764ba2),
                Color.fromARGB(255, 91, 57, 95),
              ],
            ),
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              isDense: true,

              hintText: 'Tìm kiếm sản phẩm...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _showSuggestions = false;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_showSuggestions)
            Container(
              color: Colors.white,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchSuggestions.length,
                itemBuilder: (context, index) {
                  return _buildSuggestionItem(_searchSuggestions[index]);
                },
              ),
            ),

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _searchResults.isNotEmpty
                ? ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(_searchResults[index]);
                    },
                  )
                : _searchController.text.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không tìm thấy sản phẩm nào',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Thử tìm kiếm với từ khóa khác',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        _buildPopularKeywords(),
                        SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tìm kiếm sản phẩm yêu thích',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Hàng triệu sản phẩm đang chờ bạn khám phá',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
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
    );
  }
}
