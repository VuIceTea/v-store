class Categories {
  String categoryId;
  String name;
  String imageUrl;

  Categories({
    required this.categoryId,
    required this.name,
    required this.imageUrl,
  });

  factory Categories.fromJson(Map<String, dynamic> json) {
    return Categories(
      categoryId: json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'categoryId': categoryId, 'name': name, 'imageUrl': imageUrl};
  }
}
