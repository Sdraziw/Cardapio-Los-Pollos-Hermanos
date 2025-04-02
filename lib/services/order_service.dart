import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/items_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

final getIt = GetIt.instance;

class OrderService {
  String errorMessage = '';
  static const String historyKey = 'orders';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int counter = 0;
  final List<Dish> _orders = [];
  List<Dish> get orders => _orders;

  static void setup() {
    getIt.registerLazySingleton<OrderService>(() => OrderService());
  }

  Future<String> verifyOrGenerateOrderNumber() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if there is an order with status "preparing"
    final ordersRef = firestore.collection('orders');
    final querySnapshot = await ordersRef
        .where('email', isEqualTo: user.email)
        .where('status', isEqualTo: 'preparing')
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // If there is an order with status "preparing", return the order number
      return querySnapshot.docs.first.id;
    } else {
      // If there is no "preparing" order, generate a new order number
      final orderNumberRef = firestore.collection('config').doc('orderNumber');
      final orderNumberSnapshot = await orderNumberRef.get();
      int orderNumber = orderNumberSnapshot.exists
          ? orderNumberSnapshot.data()!['value'] + 1
          : 1;
      await orderNumberRef.set({'value': orderNumber});

      // Create a new order with status "preparing"
      await ordersRef.doc(orderNumber.toString()).set({
        'email': user.email,
        'status': 'preparing',
        'date': FieldValue.serverTimestamp(),
      });

      return orderNumber.toString();
    }
  }

  Future<int> fetchCartItemCount() async {
  final user = auth.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final orderNumber = await verifyOrGenerateOrderNumber();
  final orderRef = firestore.collection('orders').doc(orderNumber);
  final itemsSnapshot = await orderRef.collection('items').get();

  Map<String, int> groupedItems = {};

  for (var doc in itemsSnapshot.docs) {
    final data = doc.data();
    final itemName = data['name'] ?? ''; 
    final quantity = (data['quantity'] ?? 0) as int;

    if (groupedItems.containsKey(itemName)) {
      groupedItems[itemName] = groupedItems[itemName]! + quantity;
    } else {
      groupedItems[itemName] = quantity;
    }
  }

  // O número total de grupos (itens únicos) no carrinho
  int totalUniqueItems = groupedItems.length;

  return totalUniqueItems;
}

  Future<String> updateOrderStatus(
      BuildContext context, String orderNumber, String status) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final orderRef = firestore.collection('orders').doc(orderNumber);
      final orderDoc = await orderRef.get();

      if (!orderDoc.exists) {
        _showSnackBar(context, 'Order not found. #$status', Colors.red);
        return '0';
      }

      final orderData = orderDoc.data();
      if (orderData == null || orderData['email'] != user.email) {
        _showSnackBar(context, 'Error updating order status. #$status',
            Colors.red);
        return '0';
      }

      await orderRef.update({
        'status': status,
        'updateDate': FieldValue.serverTimestamp(),
        'orderNumber': orderData['orderNumber'],
        'creationDate': orderData['creationDate'],
        'email': user.email,
      });

      return status;
    } catch (e) {
      _showSnackBar(
          context, 'Error updating order status. #$status', Colors.red);
      return '0';
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    if (counter == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: color.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(5.0),
          content: Text(
            message,
            style: TextStyle(fontSize: 10),
          ),
        ),
      );
    }
  }

  void addDishToOrder(Dish dish) {
    _orders.add(dish);
  }

  Future<bool> checkItemAdded(String itemName, String orderNumber) async {
    final orderRef = firestore.collection('orders').doc(orderNumber);
    final itemDoc = await orderRef.collection('items').doc(itemName).get();
    return itemDoc.exists;
  }

  Future<void> addToOrder(
      Dish dish, int quantity, BuildContext context) async {
    final user = auth.currentUser;
    if (user == null) {
      _showSnackBar(context, 'User not authenticated', Colors.red);
      return;
    }

    _showSnackBar(context, 'User authenticated: ${user.email}', Colors.green);

    try {
      final orderNumber = await verifyOrGenerateOrderNumber();
      _showSnackBar(
          context, 'Generated order number: $orderNumber', Colors.green);

      final orderRef = firestore.collection('orders').doc(orderNumber);
      final orderSnapshot = await orderRef.get();

      if (!orderSnapshot.exists) {
        _showSnackBar(context,
            'Creating new order for user: ${user.email}', Colors.green);
        await orderRef.set({
          'uid': user.uid,
          'email': user.email,
          'status': 'preparing',
          'date_time': FieldValue.serverTimestamp(),
          'orderNumber': orderNumber,
        });
      } else {
        _showSnackBar(
            context,
            'Existing order found for user: ${user.uid}',
            Colors.green);
      }

      final itemsRef = orderRef.collection('items');

      bool itemAdded = await checkItemAdded(dish.name, orderNumber);

      if (itemAdded) {
        _showSnackBar(
            context, 'This item has been added to the order.', Colors.green);
      } else {
        _showSnackBar(context, 'This item was not in the order.', Colors.green);
      }

      if (!itemAdded) {
        _showSnackBar(context, 'Adding new item to the order', Colors.green);
        await itemsRef.doc(dish.name).set({
          'item_id': dish.id,
          'name': dish.name,
          'description': dish.description,
          'price': dish.price,
          'image': dish.image,
          'summary': dish.summary,
          'quantity': quantity,
          'packageItem': dish.packageItem,
          'coupon': dish.coupon,
          'category': dish.category,
          'creationDate': FieldValue.serverTimestamp(),
        });
        _showSnackBar(
            context, 'Item ${dish.name} successfully added', Colors.green);
      } else {
        _showSnackBar(
            context, 'Updating quantity of existing item', Colors.green);
        DocumentSnapshot doc = await itemsRef.doc(dish.name).get();
        int currentQuantity = doc['quantity'];
        await doc.reference
            .update({'quantity': currentQuantity + quantity});
        _showSnackBar(
            context, 'Item quantity successfully updated', Colors.green);
        counter = 1;
      }
    } catch (e) {
      _showSnackBar(
          context, 'Error adding item to order: $e', Colors.red);
    }
  }

  Future<void> applyPromoCode(
      BuildContext context, String code) async {
    bool snack2024 = true;
    bool dessert2024 = true;
    Dish? freeDish;

    if ((code == 'DESSERT2024') && dessert2024 == true) {
      dessert2024 = false;
      freeDish = Dish(
        id: 'dessert2024',
        name: "🎃👻DESSERT2024 🍦- Negresco Ice Cream",
        price: 0.0,
        image: "lib/images/ice-cream.webp",
        description:
            "Negresco Ice Cream is made with condensed milk, milk, Negresco cookies, vanilla essence, eggs, sugar, and cream. Simple and delicious! 🍦",
        summary: 'Stuffed Cone and Vanilla Dough',
        quantity: 1,
        packageItem: 'to pick up at the counter',
        coupon: true,
        category: 'Desserts',
      );
      await addToOrder(freeDish, 1, context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Text('Promo code applied successfully!'),
        ),
      );
    } else if ((code == 'SNACK2024') && snack2024 == true) {
      snack2024 = false;
      freeDish = Dish(
        id: 'snack2024',
        name: "🎃👻SNACK2024 🍔- Special Burger",
        price: 0.0,
        image: 'lib/images/promo_image.png',
        description: "Burger bun, Crispy Chicken, Barbecue Sauce",
        summary: 'Big Burger | 200g 🍔',
        quantity: 1,
        packageItem: 'to pick up at the counter',
        coupon: true,
        category: 'Snacks',
      );
      await addToOrder(freeDish, 1, context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Text('Promo code applied successfully!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          content: Text('Invalid or expired promo code.'),
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchOrderItemsByStatus(String orderNumber, String status) async {
    try {
      print('Fetching items for orderNumber: $orderNumber with status: $status');
      final querySnapshot = await firestore
          .collection('orders')
          .doc(orderNumber)
          .collection('items')
          .get();

      print('Query result: ${querySnapshot.docs.map((doc) => doc.data())}');
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }

  Future<void> removeFromOrder(Dish dish) async {
    // Implement the logic to remove the dish from the order
    // For example, update the database or local storage
    print('Removing ${dish.name} from the order...');
  }

  Future<List<Map<String, dynamic>>> getCompletedOrders() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Fetch completed orders from Firestore
      final querySnapshot = await firestore
          .collection('orders')
          .where('email', isEqualTo: user.email)
          .where('status', isEqualTo: 'completed') // Assuming 'completed' is the status for completed orders
          .get();

      // Map the documents to a list of maps
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching completed orders: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getCompletedOrderItemsStream() {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Stream to fetch completed order items from Firestore
    return firestore
        .collection('orders')
        .where('email', isEqualTo: user.email)
        .where('status', isEqualTo: 'completed') // Assuming 'completed' is the status for completed orders
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'orderNumber': doc.id,
          'name': data['name'] ?? '',
          'description': data['description'] ?? '',
          'price': (data['price'] as num?)?.toDouble() ?? 0.0,
          'quantity': data['quantity'] ?? 1,
          'image': data['image'] ?? '',
        };
      }).toList();
    });
  }

  Future<void> registerPayment(BuildContext context, String orderNumber, String paymentMethod) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final orderRef = firestore.collection('orders').doc(orderNumber);
      final orderSnapshot = await orderRef.get();

      if (!orderSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order not found.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Update the order with payment details
      await orderRef.update({
        'paymentMethod': paymentMethod,
        'status': 'paid', // Update the status to 'paid'
        'paymentDate': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment registered successfully with $paymentMethod!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error registering payment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await firestore
          .collection('orders')
          .where('email', isEqualTo: user.email)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['orderNumber'] = doc.id; 
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching all orders: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> getAllOrderItemsStream() {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    return firestore
        .collection('orders')
        .where('email', isEqualTo: user.email)
        .snapshots()
        .asyncMap((querySnapshot) async {
      final allItems = <Map<String, dynamic>>[];

      for (var doc in querySnapshot.docs) {
        final orderNumber = doc.id;
        final itemsSnapshot = await doc.reference.collection('items').get();

        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();
          itemData['orderNumber'] = orderNumber; // Adiciona o número do pedido
          allItems.add(itemData);
        }
      }

      return allItems;
    });
  }
}
