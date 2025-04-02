import '../model/items_model.dart';

class Order {
  final String number; // Order number
  final String status; // Example: "preparing", "completed", "delivered"
  final List<Dish> items; // List of items in the order

  Order({
    required this.number,
    required this.status,
    required this.items,
  });
}
