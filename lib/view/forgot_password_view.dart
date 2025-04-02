/* Adicional Forgot minha Password
Não solicitado, porém adaptado ao projeto
*/

import 'package:flutter/material.dart';
import 'package:los_pollos_hermanos_en/controller/login_controller.dart';

class ForgotPasswordView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Color(0xFFFFD600), // Cor da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter your email to receive password reset instructions:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                        prefixIcon: Icon(Icons.alternate_email_rounded),
                labelText: 'E-mail',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String email = emailController.text;
                LoginController().ForgotPassword(context, email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD600), // Cor do botão
              ),
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
