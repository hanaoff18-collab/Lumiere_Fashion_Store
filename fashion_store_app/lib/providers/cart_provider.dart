import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  
  int get itemCount => _items.length;
  
  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.price * item.quantity;
    }
    return total;
  }

  void addToCart(Product product) {
    int existingIndex = _items.indexWhere((item) => item.productId == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: product.id,
        name: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl,
      ));
    }
    notifyListeners();
  }

  void removeFromCart(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    int index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0 && newQuantity > 0) {
      _items[index].quantity = newQuantity;
      notifyListeners();
    } else if (newQuantity == 0) {
      removeFromCart(itemId);
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}