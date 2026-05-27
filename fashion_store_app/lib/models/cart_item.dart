class CartItem {
  final String id;
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String imageUrl;
  String? selectedSize;
  String? selectedColor;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.selectedSize,
    this.selectedColor,
  });

  double get totalPrice => price * quantity;
}