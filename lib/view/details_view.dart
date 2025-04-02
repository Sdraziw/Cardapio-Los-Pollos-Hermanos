import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../model/items_model.dart';
import '../services/order_service.dart';
import '../controller/menu_controller.dart' as custom;
import '../view/menu_view.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({super.key});

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  int quantity = 1; // Counter for the quantity of the dish
  final orderService = GetIt.I<OrderService>(); // Accessing the order service
  final custom.MenuController menuController =
      custom.MenuController(); // Instance of MenuController

  @override
  Widget build(BuildContext context) {
    // Retrieve the dish data
    Dish data = ModalRoute.of(context)!.settings.arguments as Dish;

    // Get the screen width
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(data.name),
        backgroundColor: const Color(0xFFFFD600), // Keeping the AppBar color
      ),
      body: Container(
        color: Colors.white, // Background color
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              // Dish image
              Image.network(
                data.image,
                height: 200,
                width: screenWidth, // Using the screen width for the image
                fit: BoxFit.cover, // The image covers the width proportionally
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.indigoAccent,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Dish description using FutureBuilder
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('menu_items')
                    .doc(data.name)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading description');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('Description not found');
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      title: const Text(
                        'Description',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['description'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Summary',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data['summary'] ?? '',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 30),

              // Dish price using FutureBuilder
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('menu_items')
                    .doc(data.name)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading price');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('Price not found');
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    double price = (data['price'] as num).toDouble();
                    return ListTile(
                      title: const Text(
                        'Price',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '\$${price.toStringAsFixed(2)}', // Displaying the price in currency format
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Quantity counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantity: $quantity',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantity > 1) {
                              quantity--;
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Displaying the total based on the selected quantity
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('menu_items')
                    .doc(data.name)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading price');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text('Price not found');
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    double price = (data['price'] as num).toDouble();
                    return Text(
                      'Total: \$${(quantity * price).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Button to add to order
              ElevatedButton(
                onPressed: () async {
                  // Add the dish to the order using the service
                  await orderService.addToOrder(data, quantity, context);

                  // Check or generate the order number
                  String orderNumber =
                      await orderService.verifyOrGenerateOrderNumber();

                  // Update the list of order items in the cart
                  await orderService.fetchOrderItemsByStatus(
                      orderNumber, 'preparing');

                  // Update the order status
                  await orderService.updateOrderStatus(
                      context, orderNumber, 'preparing');

                  // Redirect to the menu screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MenuView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(300, 50),
                  foregroundColor: Colors.black,
                  backgroundColor: const Color(0xFFFFD600), // Button color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Add to Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
