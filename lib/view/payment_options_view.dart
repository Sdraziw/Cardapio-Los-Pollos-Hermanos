import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:los_pollos_hermanos_en/services/order_service.dart';

class PaymentOptionsView extends StatelessWidget {
  final OrderService orderService = GetIt.I<OrderService>();

  PaymentOptionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Options'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon and button for Pix payment
            GestureDetector(
              onTap: () async {
                String orderNumber = await orderService.verifyOrGenerateOrderNumber();
                await orderService.registerPayment(context, orderNumber, 'Pix');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Pix payment confirmed! 💰\nPlease wait, your order is being prepared!⌛\nOrder number: $orderNumber'),
                  ),
                );
                Navigator.pushReplacementNamed(context, 'history');
              },
              child: Column(
                children: [
                  Icon(Icons.payment, size: 60, color: Colors.blue), // Pix icon
                  SizedBox(height: 10),
                  Text('Pix Payment', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 40), // Spacing between options
            // Icon and button for credit card payment
            GestureDetector(
              onTap: () async {
                String orderNumber = await orderService.verifyOrGenerateOrderNumber();
                await orderService.registerPayment(context, orderNumber, 'Credit Card');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Credit Card payment confirmed!\nPlease wait, your order is being prepared!\nOrder number: $orderNumber'),
                  ),
                );
                // Navigate to the history view after payment confirmation
                // You can replace 'history' with the actual route name for your history view
                Navigator.pushReplacementNamed(context, 'history');
              },
              child: Column(
                children: [
                  Icon(Icons.credit_card, size: 60, color: Colors.green), // Credit Card icon
                  SizedBox(height: 10),
                  Text('Credit Card Payment', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}