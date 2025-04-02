import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import '../services/order_service.dart';
import '../model/items_model.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  CartViewState createState() => CartViewState();
}

class CartViewState extends State<CartView> {
  final orderService = GetIt.I<OrderService>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool includeTip = false;
  double tipPercentage = 10.0;
  String errorMessage = '';
  String promoCode = '';
  String promoCodeMessage = '';
  List<Dish> cartItems = [];
  List<String> appliedPromoCodes = [];

  // Active discount coupons
  bool snack2024 = true;
  bool dessert2024 = true;

  String verifyOrGenerateOrderNumber = '';

  @override
  void initState() {
    super.initState();
    orderService.verifyOrGenerateOrderNumber().then((orderNumber) {
      setState(() {
        verifyOrGenerateOrderNumber = orderNumber;
        loadCartItems();
      });
    });
  }

  void loadCartItems() async {
  try {
    print('Fetching items for order: $verifyOrGenerateOrderNumber');
    final items = await orderService.fetchOrderItemsByStatus(verifyOrGenerateOrderNumber, 'preparing');
    print('Fetched items: $items');

    setState(() {
      cartItems = items.map((item) => Dish.fromMap(item)).toList();
    });

    print('Cart items: $cartItems');
  } catch (e) {
    print('Error loading cart items: $e');
  }
}

  Future<void> addToOrder(Dish dish, int quantity) async {
    try {
      await orderService.addToOrder(dish, quantity, context);
      loadCartItems();
    } catch (e) {
      print('Error adding item to order: $e');
    }
  }

  Future<void> removeFromOrder(Dish dish) async {
  final user = auth.currentUser;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  try {
    final orderNumber = verifyOrGenerateOrderNumber;
    final orderRef = firestore.collection('orders').doc(orderNumber);
    final itemsRef = orderRef.collection('items');
    final itemDoc = await itemsRef.doc(dish.name).get();

    if (itemDoc.exists) {
      await itemDoc.reference.delete();
      loadCartItems(); 
      setState(() {
        cartItems.removeWhere((item) => item.name == dish.name);
      });
      loadCartItems(); 
    }
  } catch (e) {
    print('Error removing item from order: $e');
  }
}

  void confirmRemoveItem(Dish dish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Item'),
        content: Text('Are you sure you want to remove "${dish.name}" from the order?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await removeFromOrder(dish);
              setState(() {
                // Reload the cart items to reflect the changes
                loadCartItems();
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.purple.withOpacity(0.5),
                      content: Text('Item removed.❌'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      padding: EdgeInsets.all(10.0),
                    ),
                  );
                });
              });
              Navigator.of(context).pop();
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<String> updateOrderStatus(
      context, String orderNumber, String status) async {
    final user = auth.currentUser;
    if (user != null) {
      final orderRef = firestore.collection('orders').doc(orderNumber);
      final orderDoc = await orderRef.get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data();
        if (orderData != null && orderData['email'] == user.email) {
          await orderRef.update({
            'status': status,
            'lastUpdated': FieldValue.serverTimestamp(),
            'orderNumber': orderData['orderNumber'],
            'createdAt': orderData['createdAt'],
            'email': user.email,
          });
          return status;
        } else if (orderData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              content: Text(
                  'Else if: Error updating order status. #${status}'),
            ),
          );
          return status;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              content: Text('Error updating order status. #${status}'),
            ),
          );
          return status;
        }
      }
    }
    return '0';
  }

  Future<void> applyPromoCode(String code) async {
  try {
    
    if (appliedPromoCodes.contains(code)) {
      setState(() {
        promoCodeMessage = 'This promo code has already been applied.';
      });
      return;
    }


    await orderService.applyPromoCode(context, code);

   
    setState(() {
      appliedPromoCodes.add(code);
      promoCodeMessage = 'Promo code applied successfully!';
    });

    loadCartItems(); 
  } catch (e) {
    print('Error applying promo code: $e');
    setState(() {
      promoCodeMessage = 'Error applying promo code. Please try again.';
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Cart'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Your cart is empty.'),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'history');
                    },
                    icon: Icon(Icons.receipt_long),
                    label: Text('Orders'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final dish = cartItems[index];
                      return ListTile(
                        leading: Image.network(dish.image),
                        title: Text(
                          dish.name,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantity: ${dish.quantity}\nPrice: R\$ ${dish.price.toStringAsFixed(2)} (each)',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                if (dish.quantity > 1) {
                                  await addToOrder(dish, -1);
                                  setState(() {});
                                } else {
                                  confirmRemoveItem(dish);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: dish.coupon ? null : () async {
                                await addToOrder(dish, 1);
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await removeFromOrder(dish);
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Promo Code',
                          hintText: 'Enter the promo code',
                        ),
                        onChanged: (value) {
                          setState(() {
                            promoCode = value;
                          });
                        },
                      ),
                      if (promoCodeMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            promoCodeMessage,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await applyPromoCode(promoCode);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Color(0xFFFFD600),
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Apply Promo Code'),
                      ),
                      CheckboxListTile(
                        title: Text("Include tip of $tipPercentage%"),
                        subtitle: Text(
                          "The tip is not mandatory.\nIf you wish, you can change the percentage.",
                          style: TextStyle(fontSize: 9, color: Colors.red),
                        ),
                        value: includeTip,
                        onChanged: (bool? value) {
                          setState(() {
                            includeTip = value!;
                          });
                        },
                      ),
                      if (includeTip) ...[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Change tip percentage',
                            hintText: 'Enter the tip percentage',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              if (RegExp(r'^[0-9]*[.,]?[0-9]*$').hasMatch(value)) {
                                errorMessage = '';
                                double? newPercentage =
                                    double.tryParse(value.replaceAll(',', '.'));
                                if (newPercentage != null && newPercentage > 0) {
                                  tipPercentage = newPercentage;
                                } else {
                                  tipPercentage = 10.0;
                                }
                              } else {
                                errorMessage = 'Enter a valid value.';
                              }
                            });
                          },
                        ),
                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                      SizedBox(height: 10),
                      Text(
                        'Total: R\$ ${calculateOrderTotal(cartItems).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (includeTip) ...[
                        Text(
                          'Tip amount: R\$ ${(calculateOrderTotal(cartItems) * (tipPercentage / 100)).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        Text(
                          'Total with ${tipPercentage.toStringAsFixed(1)}% tip: R\$ ${(calculateOrderTotal(cartItems) * (1 + (tipPercentage / 100))).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Thank you, your support is greatly appreciated!',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Center(
                          child: Text(
                            '😊',
                            style: TextStyle(
                              fontSize: tipPercentage * 2 > 100 ? 100 : tipPercentage * 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          'Total without tip: R\$ ${calculateOrderTotal(cartItems).toStringAsFixed(2)}\n  ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await orderService.updateOrderStatus(context, verifyOrGenerateOrderNumber, 'preparing');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              content: Text('💳 Status: preparing and waiting for payment 💵\nYour order will be processed after payment!'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              padding: EdgeInsets.all(10.0),
                            ),
                          );
                          Navigator.pushNamed(context, 'payment', arguments: calculateOrderTotal(cartItems) * (1 + (tipPercentage / 100)));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Color(0xFFFFD600),
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Make Payment'),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  double calculateOrderTotal(List<Dish> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      total += item.quantity * item.price;
    }
    return total;
  }
}