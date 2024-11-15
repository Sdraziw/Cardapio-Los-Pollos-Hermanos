import 'package:flutter/material.dart';
import 'dart:math'; 

class PagamentoView extends StatelessWidget {
  const PagamentoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Gerar um número de pedido aleatório de 4 dígitos
    final int numeroPedido = Random().nextInt(9000) + 1000; // Gera um número entre 1000 e 9999

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibir o número do pedido
            Text(
              'Número do Pedido: #$numeroPedido',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Informe este para fazer o pagamento: #$numeroPedido',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 25, 0, 255),
              ),
            ),
            SizedBox(height: 20), // Espaçamento entre o texto e a imagem
            // Exibir a imagem
            Image.asset(
              'lib/images/embrulhos.jpg', // Caminho da imagem
              fit: BoxFit.cover,
              width: 300, // Ajuste a largura conforme necessário
            ),
            SizedBox(height: 20), // Espaçamento entre a imagem e o botão
            // Botão para pagar antecipadamente
            ElevatedButton(
              onPressed: () {
                // Redirecionar para a tela de opções de pagamento
                Navigator.pushNamed(context, 'opcoes_pagamento');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                textStyle: TextStyle(fontSize: 18),
                backgroundColor: Color(0xFFFFD600),
                foregroundColor: Colors.black,
              ),
              child: Text('Pagar Antecipadamente'),
            ),
          ],
        ),
      ),
    );
  }
}
