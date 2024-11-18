import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pedido_service.dart';

class CarrinhoView extends StatefulWidget {
  const CarrinhoView({super.key});

  @override
  CarrinhoViewState createState() => CarrinhoViewState();
}

class CarrinhoViewState extends State<CarrinhoView> {
  final pedidoService = GetIt.I<PedidoService>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool incluirGorjeta = false;
  double percentualGorjeta = 10.0;
  String mensagemErro = '';
  String codigoPromocional = '';
  String mensagemCodigo = '';
  bool lanche2024 = true;
  bool sobremesa2024 = true;

  Future<int> obterProximoNumeroPedido() async {
    DocumentReference docRef = firestore.collection('config').doc('numeroPedido');
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      int numeroPedido = doc['numero'] ?? 0;
      return numeroPedido + 1;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrinho'),
        backgroundColor: Color(0xFFFFD600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Voltar à página anterior
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pedidoService.buscarItensPedido(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> itensCarrinho = snapshot.data!;

          if (itensCarrinho.isEmpty) {
            return Center(child: Text('Seu carrinho está vazio.'));
          }

          double total = itensCarrinho.fold(0, (sum, item) => sum + item['preco'] * item['quantidade']);

          return Column(
            children: [
              FutureBuilder<int?>(
                future: pedidoService.buscarNumeroPedido(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  int? numeroPedido = snapshot.data;
                  if (numeroPedido == null) {
                    return Center(child: Text('Erro ao carregar o número do pedido.'));
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Número do Pedido: $numeroPedido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: itensCarrinho.length,
                  itemBuilder: (context, index) {
                    var item = itensCarrinho[index];
                    return ListTile(
                      leading: item['foto'] != null ? Image.network(item['foto']) : null,
                      title: Text(item['nome']),
                      subtitle: Text('${item['descricao']}\nQuantidade: ${item['quantidade']}'),
                      trailing: Text('R\$ ${item['preco'].toStringAsFixed(2)}'),
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
                    Text('Total: R\$ ${total.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        // Implementar a lógica de finalização do pedido
                        final user = auth.currentUser;
                        if (user != null) {
                          final pedidoRef = firestore.collection('pedidos').doc(user.uid);
                          await pedidoRef.update({'status': 'preparando'});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pedido finalizado e enviado para preparação!'),
                            ),
                          );
                        }
                      },
                      child: Text('Finalizar Pedido'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}