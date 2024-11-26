import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../controller/login_controller.dart';
import '../services/pedido_service.dart';
import 'dart:math';

class PagamentoView extends StatefulWidget {
  const PagamentoView({super.key});

  @override
  _PagamentoViewState createState() => _PagamentoViewState();
}

class _PagamentoViewState extends State<PagamentoView> {
  String _nomeUsuario = '';
  String _nomeCompletoUsuario = '';
  String _numeroPedido = '';
  String _status = 'preparando';
  String _uid = '';
  final LoginController loginController = LoginController();
  final PedidoService pedidoService = GetIt.I<PedidoService>();

  @override
  void initState() {
    super.initState();
    _carregarNomeUsuario();
    _buscarInformacoesPedido();
  }

  Future<void> _carregarNomeUsuario() async {
    _nomeUsuario = await loginController.usuarioLogadoPrimeiroNome();
    _nomeCompletoUsuario = await loginController.usuarioLogadoNome();
    setState(() {});
  }

  Future<void> _buscarInformacoesPedido() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final numeroPedido = await pedidoService.verificarOuGerarNumeroPedido();
      final pedidoRef = FirebaseFirestore.instance.collection('pedidos').doc(numeroPedido);
      final pedidoDoc = await pedidoRef.get();

      if (pedidoDoc.exists) {
        setState(() {
          _numeroPedido = numeroPedido;
          _status = pedidoDoc['status'];
          _uid = user.uid;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gerar um número de pedido aleatório de 4 dígitos
    final int numeroCozinha = Random().nextInt(9000) + 1000; // Gera um número entre 1000 e 9999

    return Scaffold(
      appBar: AppBar(
        title: Text('Pagamento'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Exibir o número da cozinha aleatório futuramente implementar
            Text(
              'Cozinha: $numeroCozinha',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontFamily: 'GAMERA',
              ),
            ),
            SizedBox(height: 10),
            // Exibir o nome do usuário
            Text(
              'Cliente: $_nomeUsuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'GAMERA',
              ),
            ),
            SizedBox(height: 10),
            // Exibir o nome completo do usuário
            Text(
              'Nome Completo: $_nomeCompletoUsuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontFamily: 'CarnevaleeFreakshow',
              ),
            ),
            SizedBox(height: 10),
            // Exibir o número do pedido
            Text(
              'Pedido: #$_numeroPedido',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 10),
            // Exibir o status do pedido
            Text(
              'Status do Pedido: $_status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
                fontFamily: 'CarnevaleeFreakshow',
              ),
            ),
            SizedBox(height: 10),
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
            SizedBox(height: 30),
            // Exibir o UID
            Text(
              'Registro: $_uid',
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