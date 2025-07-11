import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:provider/provider.dart';
import 'package:v_store/models/category.dart';
import 'package:v_store/models/slider_model.dart';
import 'package:v_store/services/product_service.dart';
import 'package:v_store/services/category_service.dart';
import 'package:v_store/services/cart_service.dart';
import 'package:v_store/utils/price_formatter.dart';
import 'package:v_store/widgets/appdrawer.dart';
import 'package:v_store/widgets/header.dart';
import 'package:v_store/screens/product_sort.dart';
import 'package:v_store/screens/main_screen.dart';
import 'package:v_store/providers/category_notifier.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:intl/intl.dart';
import 'package:v_store/widgets/slide_right_route.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  final CarouselSliderController _sliderControllerCategories =
      CarouselSliderController();
  int _selectedBannerIndex = 0;
  final CarouselSliderController _sliderControllerBanner =
      CarouselSliderController();
  CollectionReference products = FirebaseFirestore.instance.collection(
    'products',
  );
  ProductService productService = ProductService();
  CategoryService categoryService = CategoryService();

  Future? _productsFuture;
  Future? _categoriesFuture;
  int numberStart = 0;
  int selectedProductIndex = 0;

  final ScrollController _categoriesScrollController = ScrollController();
  final ScrollController _productsScrollController = ScrollController();
  final ScrollController _trendingScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productsFuture = productService.getProducts();
    _initializeCategories();
  }

  void _initializeCategories() async {
    try {
      await categoryService.initializeCategories();
      _categoriesFuture = categoryService.getCategories();
      setState(() {});
    } catch (e) {
      print('Error initializing categories: $e');
    }
  }

  @override
  void dispose() {
    _categoriesScrollController.dispose();
    _productsScrollController.dispose();
    _trendingScrollController.dispose();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = productService.getProducts();
    });
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = categoryService.getCategories();
    });
  }

  final List<SliderModel> _slideItems = [
    SliderModel(
      id: "1",
      images: 'assets/images/sliders/banner_1.png',
      title: 'Giảm giá 40-50%',
      description: 'Sản phẩm mới nhất',
    ),
    SliderModel(
      id: "2",
      images: 'assets/images/sliders/banner_2.webp',
      title: '',
      description: '',
    ),
    SliderModel(
      id: "3",
      images: 'assets/images/sliders/banner_3.jpeg',
      title: '',
      description: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: Color(0xFFF5F5F5),
            padding: EdgeInsets.only(top: 50.0),
            child: Header(),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _refreshProducts();
                _refreshCategories();
                await Future.delayed(Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tính Năng',
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
                                    Navigator.push(
                                      context,
                                      SlideRightRoute(
                                        page: ProductSortScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: Size(0, 0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Sắp xếp',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.swap_vert_rounded,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductSortScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    minimumSize: Size(0, 0),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Text(
                                        'Lọc',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.filter_alt_outlined,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20.0),

                      //categories
                      Container(
                        width: double.infinity,
                        height: 120.0,
                        color: Colors.white,
                        child: FutureBuilder<List<Categories>>(
                          future:
                              _categoriesFuture as Future<List<Categories>>?,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Error loading categories: ${snapshot.error}',
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.data == null ||
                                snapshot.data!.isEmpty) {
                              return Center(
                                child: Text('Không có danh mục nào!'),
                              );
                            }

                            final categories = snapshot.data!;

                            return ListView.builder(
                              controller: _categoriesScrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Đang tìm sản phẩm "${categories[index].name}"...',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        duration: Duration(milliseconds: 1500),
                                        backgroundColor: Color.fromRGBO(
                                          255,
                                          163,
                                          179,
                                          1,
                                        ),
                                      ),
                                    );

                                    await Future.delayed(
                                      Duration(milliseconds: 200),
                                    );

                                    Provider.of<CategoryNotifier>(
                                      context,
                                      listen: false,
                                    ).setSelectedCategory(
                                      categories[index].name,
                                    );

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MainScreen(initialTab: 1),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4.0,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 75.0,
                                          height: 75.0,
                                          decoration: BoxDecoration(
                                            color:
                                                _selectedCategoryIndex == index
                                                ? Color.fromRGBO(
                                                    255,
                                                    163,
                                                    179,
                                                    1,
                                                  )
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              37.5,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _selectedCategoryIndex ==
                                                      index
                                                  ? Color.fromRGBO(
                                                      255,
                                                      163,
                                                      179,
                                                      1,
                                                    )
                                                  : Colors.transparent,
                                              width: 2.0,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              37.5,
                                            ),
                                            child: Image.asset(
                                              categories[index].imageUrl,
                                              height: 75.0,
                                              width: 75.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.0),
                                        Text(
                                          categories[index].name,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight:
                                                _selectedCategoryIndex == index
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color:
                                                _selectedCategoryIndex == index
                                                ? Color.fromRGBO(
                                                    255,
                                                    163,
                                                    179,
                                                    1,
                                                  )
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 20),

                      //banner slider
                      Column(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              height: 200,
                              autoPlay: true,
                              enlargeCenterPage: false,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _selectedBannerIndex = index;
                                });
                              },
                            ),
                            items: _slideItems
                                .map(
                                  (item) => SizedBox(
                                    width: double.infinity,
                                    child: Stack(
                                      children: [
                                        Image.asset(
                                          item.getImages()!,
                                          fit: BoxFit.cover,
                                          height: 200,
                                          width: double.infinity,
                                        ),
                                        Positioned(
                                          top: 40,
                                          left: 20,
                                          child: Text(
                                            item.getTitle()!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontSize: 26,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 80,
                                          left: 20,
                                          child: Text(
                                            item.getDescription()!,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Montserrat',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 140,
                                          left: 20,
                                          child: OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: Color.fromRGBO(
                                                254,
                                                145,
                                                164,
                                                1,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              minimumSize: Size(0, 0),
                                              side: BorderSide(
                                                color: Colors.white,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Mua ngay',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          SizedBox(height: 15),

                          // Banner indicator dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_slideItems.length, (
                              index,
                            ) {
                              return AnimatedContainer(
                                curve: Curves.bounceInOut,
                                duration: Duration(milliseconds: 300),
                                margin: EdgeInsets.only(right: 5),
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: _selectedBannerIndex == index
                                      ? Color.fromRGBO(255, 163, 179, 1)
                                      : Color.fromRGBO(
                                          168,
                                          168,
                                          169,
                                          1,
                                        ).withOpacity(.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.0),
                      Container(
                        color: Color.fromRGBO(67, 146, 249, 1),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ưu đãi trong ngày',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/homeImgs/clock_icon.png',
                                      fit: BoxFit.cover,
                                      height: 25.0,
                                      width: 25.0,
                                    ),
                                    SizedBox(width: 5.0),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SlideCountdown(
                                          duration: Duration(
                                            hours: 23,
                                            minutes: 55,
                                            seconds: 20,
                                          ),
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                          separatorStyle: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(
                                              0,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'đếm ngược',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(
                                  67,
                                  146,
                                  249,
                                  1,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size(0, 0),
                                side: BorderSide(color: Colors.white),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      //Deal of the Day Products - Horizontal Scroll
                      SizedBox(height: 20.0),
                      _renderListProducts(
                        startIndex: 0,
                        maxItems: 5,
                        scrollController: _productsScrollController,
                      ),

                      SizedBox(height: 20.0),
                      Stack(
                        children: [
                          Image.asset(
                            'assets/images/homeImgs/banner.webp',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 200.0,
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      Container(
                        color: Color.fromRGBO(253, 110, 135, 1),
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sản phẩm xu hướng',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color: Colors.white,
                                      size: 25.0,
                                    ),
                                    SizedBox(width: 5.0),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Ngày hôm nay',
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 5.0),
                                        DateFormat('dd/MM/yy')
                                                .format(DateTime.now())
                                                .toString()
                                                .isNotEmpty
                                            ? Text(
                                                DateFormat('dd/MM/yy')
                                                    .format(DateTime.now())
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                'N/A',
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Color.fromRGBO(
                                  253,
                                  110,
                                  135,
                                  1,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                minimumSize: Size(0, 0),
                                side: BorderSide(color: Colors.white),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Xem tất cả',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Trending Products List
                      SizedBox(height: 20.0),
                      _renderListProducts(
                        startIndex: 5,
                        maxItems: 6,
                        scrollController: _trendingScrollController,
                      ),

                      SizedBox(height: 40.0),
                      Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/homeImgs/summersalebanner.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200.0,
                            ),
                            SizedBox(height: 5.0),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hàng mới về',
                                    style: TextStyle(
                                      fontSize: 23.0,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Bộ sưu tập mùa hè 2025',
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Color.fromRGBO(
                                            248,
                                            55,
                                            88,
                                            1,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          minimumSize: Size(0, 0),
                                        ),
                                        onPressed: () {},
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Xem tất cả',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.0),
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Sponserd',
                          style: TextStyle(
                            fontSize: 23.0,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Column(
                        children: [
                          Image.asset(
                            'assets/images/homeImgs/shoepromo.png',
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    'Giảm giá đến 50%',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.black,
                                  size: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 30.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _renderListProducts({
    int startIndex = 0,
    int maxItems = 5,
    ScrollController? scrollController,
  }) {
    final controller = scrollController ?? _productsScrollController;
    return Stack(
      children: [
        FutureBuilder(
          future: _productsFuture,
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
            return SizedBox(
              height: 330.0,
              child: ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                itemCount: () {
                  final totalProducts = snapshot.data!.length;
                  final availableProducts = totalProducts - startIndex;
                  if (availableProducts <= 0) return 0;
                  return availableProducts > maxItems
                      ? maxItems
                      : availableProducts;
                }(),
                itemBuilder: (context, index) {
                  final actualIndex = startIndex + index;
                  if (actualIndex >= snapshot.data!.length) {
                    return SizedBox.shrink();
                  }
                  final product = snapshot.data![actualIndex];
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                height: 140.0,
                                width: double.infinity,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.0),

                                    SizedBox(height: 2.0),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.discount != null &&
                                                  product.discount! > 0
                                              ? PriceFormatter.formatWithDiscount(
                                                  product.price,
                                                  product.discount,
                                                )
                                              : PriceFormatter.format(
                                                  product.price,
                                                ),
                                          style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        if (product.discount != null &&
                                            product.discount! > 0)
                                          Row(
                                            children: [
                                              Text(
                                                PriceFormatter.format(
                                                  product.price,
                                                ),
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 1,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  '-${product.discount!.toInt()}%',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),

                                    SizedBox(height: 2.0),
                                    Row(
                                      children: [
                                        StarRating(
                                          rating: product.rating ?? 0.0,
                                          size: 18.0,
                                          color: Colors.amber,
                                          borderColor: Colors.grey,
                                        ),
                                        SizedBox(width: 4.0),
                                        Text(
                                          '(${product.reviewCount ?? 0})',
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Consumer<CartService>(
                                      builder: (context, cartService, child) {
                                        return SizedBox(
                                          width: double.infinity,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              try {
                                                await cartService.addToCart(
                                                  product,
                                                );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Đã thêm "${product.name}" vào giỏ hàng',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                      milliseconds: 1500,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Lỗi khi thêm sản phẩm vào giỏ hàng',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Montserrat',
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    duration: Duration(
                                                      milliseconds: 1500,
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              padding: EdgeInsets.symmetric(
                                                vertical: 6,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.shopping_cart_outlined,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Thêm vào giỏ',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        Positioned(
          right: 0,
          top: 100,
          child: Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black54,
                size: 20.0,
              ),
              onPressed: () {
                if (controller.hasClients) {
                  final double maxScroll = controller.position.maxScrollExtent;
                  final double currentScroll = controller.offset;
                  final double scrollAmount = 210.0;

                  double targetScroll = currentScroll + scrollAmount;

                  if (targetScroll > maxScroll) {
                    targetScroll = maxScroll;
                  }

                  controller.animateTo(
                    targetScroll,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
