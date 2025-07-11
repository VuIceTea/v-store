import 'package:flutter/material.dart';

class CategoryNotifier extends ChangeNotifier {
  String? _selectedCategory;

  String? get selectedCategory => _selectedCategory;

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearSelectedCategory() {
    _selectedCategory = null;
    notifyListeners();
  }
}
