import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../controller/login_controller.dart';
import '../services/order_service.dart';
import 'dart:math';

class PaymentView extends StatefulWidget {
  const PaymentView({super.key});

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {
  String _userName = '';
  String _userFullName = '';
  String _orderNumber = '';
  String _status = 'preparing';
  String _uid = '';
  final LoginController loginController = LoginController();
  final OrderService orderService = GetIt.I<OrderService>();

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchOrderInformation();
  }

  Future<void> _loadUserName() async {
    _userName = await loginController.loggedInUserFirstName();
    _userFullName = await loginController.loggedInUserName();
    setState(() {});
  }

  Future<void> _fetchOrderInformation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final orderNumber = await orderService.verifyOrGenerateOrderNumber();
      final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderNumber);
      final orderDoc = await orderRef.get();

      if (orderDoc.exists) {
        setState(() {
          _orderNumber = orderNumber;
          _status = orderDoc['status'];
          _uid = user.uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate a random kitchen number with 4 digits
    final int kitchenNumber = Random().nextInt(9000) + 1000; // Generates a number between 1000 and 9999

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the random kitchen number (future implementation)
            Text(
              'Kitchen: $kitchenNumber',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamily: 'GAMERA',
              ),
            ),
            SizedBox(height: 10),
            // Display the user's first name
            Text(
              'Customer: $_userName',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'GAMERA',
              ),
            ),
            SizedBox(height: 10),
            // Display the user's full name
            Text(
              'Full Name: $_userFullName',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'CarnevaleeFreakshow',
              ),
            ),
            SizedBox(height: 10),
            // Display the order number
            Text(
              'Order: #$_orderNumber',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            // Display the order status
            Text(
              'Order Status: $_status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
                fontFamily: 'CarnevaleeFreakshow',
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 20), // Spacing between the text and the image
            // Display the image
            Image.asset(
              'lib/images/embrulhos.jpg', // Path to the image
              fit: BoxFit.cover,
              width: 300, // Adjust the width as needed
            ),
            SizedBox(height: 20), // Spacing between the image and the button
            // Button to pay in advance
            ElevatedButton(
              onPressed: () {
                // Redirect to the payment options screen
                Navigator.pushNamed(context, 'payment_options');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: Color(0xFFFFD600),
                foregroundColor: Colors.black,
              ),
              child: Text('Pay in Advance'),
            ),
            SizedBox(height: 30),
            // Display the UID
            Text(
              'Record: $_uid',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'CarnevaleeFreakshow',
              ),
            ),
          ],
        ),
      ),
    );
  }
}