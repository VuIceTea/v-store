import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:v_store/models/cart.dart';
import 'package:v_store/models/cart_item.dart';
import 'package:v_store/models/product.dart';
import 'package:v_store/models/customer.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  List<CartItem> _cartItems = [];
  List<String> _selectedItemIds = [];
  final String _storageKey = 'cart_items';
  final String _selectedKey = 'selected_items';

  List<CartItem> get cartItems => _cartItems;
  List<String> get selectedItemIds => _selectedItemIds;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  String _createVariantId(String productId, String? size, String? color) {
    return '$productId|${size ?? ''}|${color ?? ''}';
  }

  String _getVariantId(CartItem item) {
    return _createVariantId(
      item.product.productId,
      (item.selectedSize?.isEmpty ?? true) ? null : item.selectedSize,
      item.selectedColor,
    );
  }

  double get selectedTotalPrice => _cartItems
      .where((item) => _selectedItemIds.contains(_getVariantId(item)))
      .fold(0.0, (sum, item) => sum + item.subtotal);

  int get selectedItemsCount => _cartItems
      .where((item) => _selectedItemIds.contains(_getVariantId(item)))
      .fold(0, (sum, item) => sum + item.quantity);

  bool get isAllSelected =>
      _cartItems.isNotEmpty &&
      _cartItems.every(
        (item) => _selectedItemIds.contains(_getVariantId(item)),
      );

  Future<void> initializeCart() async {
    await _loadCartFromStorage();
    await _loadSelectedItemsFromStorage();
  }

  Future<void> addToCart(
    Product product, {
    int quantity = 1,
    String? size,
    String? color,
  }) async {
    final existingItemIndex = _cartItems.indexWhere(
      (item) =>
          item.product.productId == product.productId &&
          item.selectedSize == (size ?? '') &&
          item.selectedColor == color,
    );

    if (existingItemIndex >= 0) {
      _cartItems[existingItemIndex].quantity += quantity;
      _cartItems[existingItemIndex].updateSubtotal();
    } else {
      final cartItem = CartItem(
        product: product,
        quantity: quantity,
        selectedSize: size ?? '',
        selectedColor: color,
      );
      _cartItems.add(cartItem);
    }

    await _saveCartToStorage();
    notifyListeners();
  }

  Future<void> removeFromCart(
    String productId, {
    String? size,
    String? color,
  }) async {
    _cartItems.removeWhere(
      (item) =>
          item.product.productId == productId &&
          item.selectedSize == (size ?? '') &&
          item.selectedColor == color,
    );

    final variantId = _createVariantId(productId, size, color);
    _selectedItemIds.removeWhere((id) => id == variantId);

    await _saveCartToStorage();
    await _saveSelectedItemsToStorage();
    notifyListeners();
  }

  Future<void> updateQuantity(
    String productId,
    int quantity, {
    String? size,
    String? color,
  }) async {
    if (quantity <= 0) {
      await removeFromCart(productId, size: size, color: color);
      return;
    }

    final itemIndex = _cartItems.indexWhere(
      (item) =>
          item.product.productId == productId &&
          item.selectedSize == (size ?? '') &&
          item.selectedColor == color,
    );

    if (itemIndex >= 0) {
      _cartItems[itemIndex].quantity = quantity;
      _cartItems[itemIndex].updateSubtotal();
      await _saveCartToStorage();
      notifyListeners();
    }
  }

  Future<void> updateItemVariant(
    String productId, {
    String? newSize,
    String? newColor,
  }) async {
    final itemIndex = _cartItems.indexWhere(
      (item) => item.product.productId == productId,
    );

    if (itemIndex >= 0) {
      if (newSize != null) {
        _cartItems[itemIndex].selectedSize = newSize;
      }
      if (newColor != null) {
        _cartItems[itemIndex].selectedColor = newColor;
      }
      await _saveCartToStorage();
      notifyListeners();
    }
  }

  void toggleItemSelection(String productId, {String? size, String? color}) {
    final variantId = _createVariantId(productId, size, color);
    if (_selectedItemIds.contains(variantId)) {
      _selectedItemIds.remove(variantId);
    } else {
      _selectedItemIds.add(variantId);
    }
    _saveSelectedItemsToStorage();
    notifyListeners();
  }

  void selectAllItems() {
    _selectedItemIds = _cartItems.map((item) => _getVariantId(item)).toList();
    _saveSelectedItemsToStorage();
    notifyListeners();
  }

  void deselectAllItems() {
    _selectedItemIds.clear();
    _saveSelectedItemsToStorage();
    notifyListeners();
  }

  Future<void> removeSelectedItems() async {
    _cartItems.removeWhere(
      (item) => _selectedItemIds.contains(_getVariantId(item)),
    );
    _selectedItemIds.clear();
    await _saveCartToStorage();
    await _saveSelectedItemsToStorage();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cartItems.clear();
    _selectedItemIds.clear();
    await _saveCartToStorage();
    await _saveSelectedItemsToStorage();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.product.productId == productId);
  }

  CartItem? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere(
        (item) => item.product.productId == productId,
      );
    } catch (e) {
      return null;
    }
  }

  List<CartItem> getSelectedItems() {
    return _cartItems
        .where((item) => _selectedItemIds.contains(_getVariantId(item)))
        .toList();
  }

  Cart createCheckoutCart(Customer customer) {
    final selectedItems = getSelectedItems();
    final total = selectedItems.fold(0.0, (sum, item) => sum + item.subtotal);

    return Cart(
      cartId: DateTime.now().millisecondsSinceEpoch.toString(),
      customer: customer,
      items: selectedItems,
      totalPrice: total,
    );
  }

  Future<void> _saveCartToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _cartItems.map((item) => item.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(cartJson));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cart to storage: $e');
      }

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        final cartJson = _cartItems.map((item) => item.toJson()).toList();
        await prefs.setString(_storageKey, jsonEncode(cartJson));
      } catch (retryError) {
        if (kDebugMode) {
          print('Retry failed for saving cart: $retryError');
        }
      }
    }
  }

  Future<void> _loadCartFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_storageKey);

      if (cartString != null) {
        final cartJson = jsonDecode(cartString) as List;
        _cartItems = cartJson.map((item) => CartItem.fromJson(item)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart from storage: $e');
      }
      _cartItems = [];

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_storageKey);
      } catch (clearError) {
        if (kDebugMode) {
          print('Error clearing corrupted cart data: $clearError');
        }
      }
    }
  }

  Future<void> _saveSelectedItemsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_selectedKey, _selectedItemIds);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving selected items to storage: $e');
      }

      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setStringList(_selectedKey, _selectedItemIds);
      } catch (retryError) {
        if (kDebugMode) {
          print('Retry failed for saving selected items: $retryError');
        }
      }
    }
  }

  Future<void> _loadSelectedItemsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedItemIds = prefs.getStringList(_selectedKey) ?? [];
    } catch (e) {
      if (kDebugMode) {
        print('Error loading selected items from storage: $e');
      }
      _selectedItemIds = [];
    }
  }
}
