class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isFeatured;
  final List<String> sizes;
  final List<String> colors;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isFeatured = false,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.colors = const ['Red', 'Blue', 'Black', 'White'],
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    final rawPrice = data['price'];
    final price = rawPrice is num ? rawPrice.toDouble() : 0.0;
    final rawSizes = data['sizes'];
    final rawColors = data['colors'];

    return Product(
      id: id,
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      price: price,
      imageUrl: (data['imageUrl'] ?? '').toString(),
      category: (data['category'] ?? 'General').toString(),
      isFeatured: data['isFeatured'] == true,
      sizes: rawSizes is List
          ? rawSizes.map((e) => e.toString()).toList()
          : const ['S', 'M', 'L', 'XL'],
      colors: rawColors is List
          ? rawColors.map((e) => e.toString()).toList()
          : const ['Black', 'White'],
    );
  }
}