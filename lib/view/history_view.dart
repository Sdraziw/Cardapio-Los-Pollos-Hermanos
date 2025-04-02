import 'package:flutter/material.dart';
import '../services/order_service.dart';
import 'package:logger/logger.dart';
import '../controller/login_controller.dart';
//import '../model/items_model.dart';

OrderService orderService = OrderService();

class HistoryView extends StatefulWidget {
  HistoryView({super.key});
  final LoginController loginController = LoginController();

  @override
  HistoryViewState createState() => HistoryViewState();
}

class HistoryViewState extends State<HistoryView> {
  List<Map<String, dynamic>> history = [];
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, 'menu');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, 'history');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, 'profile');
    }
  }

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      history = await orderService.getAllOrders(); 
      setState(() {});
    } catch (e) {
      Logger().e('Error loading history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order History'),
              Image.network(
                'lib/images/rv_2.png',
                height: 90,
              ),
            ],
          ),
          backgroundColor: Color(0xFFFFD600),
          automaticallyImplyLeading: false,
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: orderService.getAllOrderItemsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading items: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No orders found'));
          } else {
            final items = snapshot.data!;
            final groupedOrders = <String, List<Map<String, dynamic>>>{};

            for (var item in items) {
              final orderNumber = item['orderNumber'];
              if (!groupedOrders.containsKey(orderNumber)) {
                groupedOrders[orderNumber] = [];
              }
              groupedOrders[orderNumber]!.add(item);
            }

            return ListView.builder(
              itemCount: groupedOrders.length,
              itemBuilder: (context, index) {
                final orderNumber = groupedOrders.keys.elementAt(index);
                final orderItems = groupedOrders[orderNumber]!;
                final totalValue = orderItems.fold(0.0, (sum, item) => sum + item['price'] * item['quantity']);

                return ExpansionTile(
                  title: Text('Order #$orderNumber'),
                  subtitle: Text('Total Value: \$${totalValue.toStringAsFixed(2)}'),
                  children: [
                    ...orderItems.map((item) {
                      return ListTile(
                        leading: item['image'] != null && item['image'].isNotEmpty
                            ? (item['image'].startsWith('http')
                                ? Image.network(item['image'], width: 50, height: 50)
                                : Image.asset(item['image'], width: 50, height: 50))
                            : null,
                        title: Text(item['name']),
                        subtitle: Text(item['description']),
                        trailing: Text('\$${item['price'].toStringAsFixed(2)}'),
                      );
                    }),
                    ListTile(
                      title: Text('Send invoice by email'),
                      trailing: Icon(Icons.email),
                      onTap: () async {
                        String userEmail = await widget.loginController.loggedInUserEmail();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Invoice sent to email $userEmail.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: Color(0xFFFFD600),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders📦'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}