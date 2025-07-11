import 'package:v_store/models/category.dart';
import 'package:v_store/models/review.dart';

class Product {
  String productId;
  String name;
  Categories category;
  String? description;
  double price;
  String imageUrl;
  int stockQuantity;
  double? rating;
  int? reviewCount;
  List<Review>? reviews;
  bool isAvailable;
  List<String>? tags;
  List<String>? colors;
  List<String>? sizes;
  List<String>? images;
  String? brand;
  String? manufacturer;
  String? origin;
  String? dimensions;
  String? weight;
  String? material;
  String? videoUrl;
  String? barcode;
  String? productType;
  String? returnPolicy;
  double? discount;

  Product({
    required this.productId,
    required this.name,
    required this.category,
    this.description,
    required this.price,
    required this.imageUrl,
    required this.stockQuantity,
    this.rating,
    this.reviewCount,
    this.reviews,
    this.isAvailable = true,
    this.tags,
    this.colors,
    this.sizes,
    this.images,
    this.brand,
    this.manufacturer,
    this.origin,
    this.dimensions,
    this.weight,
    this.material,
    this.videoUrl,
    this.barcode,
    this.productType,
    this.returnPolicy,
    this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category:
          json['category'] != null && json['category'] is Map<String, dynamic>
          ? Categories.fromJson(json['category'] as Map<String, dynamic>)
          : Categories(categoryId: '', name: 'Unknown', imageUrl: ''),
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      stockQuantity: json['stockQuantity'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      reviews: json['reviews'] != null && json['reviews'] is List
          ? (json['reviews'] as List<dynamic>?)
                ?.where((item) => item != null && item is Map<String, dynamic>)
                .map((item) => Review.fromJson(item as Map<String, dynamic>))
                .toList()
          : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      tags: json['tags'] != null && json['tags'] is List
          ? (json['tags'] as List<dynamic>?)
                ?.where((item) => item != null)
                .map((item) => item.toString())
                .toList()
          : null,
      colors: json['colors'] != null && json['colors'] is List
          ? (json['colors'] as List<dynamic>?)
                ?.where((item) => item != null)
                .map((item) => item.toString())
                .toList()
          : null,
      sizes: json['sizes'] != null && json['sizes'] is List
          ? (json['sizes'] as List<dynamic>?)
                ?.where((item) => item != null)
                .map((item) => item.toString())
                .toList()
          : null,
      images: json['images'] != null && json['images'] is List
          ? (json['images'] as List<dynamic>?)
                ?.where((item) => item != null)
                .map((item) => item.toString())
                .toList()
          : null,
      brand: json['brand'] as String?,
      manufacturer: json['manufacturer'] as String?,
      origin: json['origin'] as String?,
      dimensions: json['dimensions'] as String?,
      weight: json['weight'] as String?,
      material: json['material'] as String?,
      videoUrl: json['videoUrl'] as String?,
      barcode: json['barcode'] as String?,
      productType: json['productType'] as String?,
      returnPolicy: json['returnPolicy'] as String?,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'category': category.toJson(),
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'reviews': reviews?.map((review) => review.toJson()).toList(),
      'isAvailable': isAvailable,
      'tags': tags,
      'colors': colors,
      'sizes': sizes,
      'images': images,
      'brand': brand,
      'manufacturer': manufacturer,
      'origin': origin,
      'dimensions': dimensions,
      'weight': weight,
      'material': material,
      'videoUrl': videoUrl,
      'barcode': barcode,
      'productType': productType,
      'returnPolicy': returnPolicy,
      'discount': discount,
    };
  }

  double caculateDiscountedPrice() {
    if (discount != null && discount! > 0) {
      return price - (price * (discount! / 100));
    }
    return price;
  }
}
