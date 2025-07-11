class Review {
  String reviewId;
  String productId;
  String userId;
  String userName;
  String? userAvatar;
  String? content;
  double rating;
  DateTime? date;
  List<String>? images;
  bool isVerifiedPurchase;

  Review({
    required this.reviewId,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.content,
    required this.rating,
    this.date,
    this.images,
    this.isVerifiedPurchase = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? 'Anonymous',
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'rating': rating,
      'date': date?.toIso8601String(),
      'images': images,
      'isVerifiedPurchase': isVerifiedPurchase,
    };
  }
}
