import 'cart_item.dart';

class Order {
  String id;
  String userId;
  List<CartItem> items;
  double totalAmount;
  DateTime orderDate;
  String status;
  Map<String, dynamic> deliveryDetails;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.deliveryDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => {
        'productId': item.productId,
        'name': item.name,
        'price': item.price,
        'quantity': item.quantity,
        'imageUrl': item.imageUrl,
      }).toList(),
      'totalAmount': totalAmount,
      'orderDate': orderDate,
      'status': status,
      'deliveryDetails': deliveryDetails,
    };
  }
}