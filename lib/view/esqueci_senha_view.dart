/* Adicional esqueci minha senha
Não solicitado, porém adaptado ao projeto
*/

import 'package:flutter/material.dart';
import 'package:los_pollos_hermanos/controller/login_controller.dart';

class EsqueciSenhaView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  EsqueciSenhaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redefinir Senha'),
        backgroundColor: Color(0xFFFFD600), // Cor da AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Digite seu e-mail para receber as instruções de redefinição de senha:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
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
                LoginController().esqueceuSenha(context, email);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFD600), // Cor do botão
              ),
              child: Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
