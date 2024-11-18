import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pedido_service.dart';
import 'package:intl/intl.dart';
import '../model/itens_model.dart';

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
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('usuarios')
            .doc(auth.currentUser!.uid)
            .collection('carrinho')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Prato> itensCarrinho = snapshot.data!.docs.map((doc) => Prato.fromDocument(doc)).toList();

          if (itensCarrinho.isEmpty) {
            return Center(child: Text('Seu carrinho está vazio.'));
          }

          double total = itensCarrinho.fold(0, (sum, item) => sum + item.preco * item.quantidade);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itensCarrinho.length,
                  itemBuilder: (context, index) {
                    Prato prato = itensCarrinho[index];
                    return ListTile(
                      leading: prato.imagem.isNotEmpty ? Image.network(prato.imagem) : null,
                      title: Text(prato.nome),
                      subtitle: Text('${prato.descricao}\nQuantidade: ${prato.quantidade}'),
                      trailing: Text(prato.precoFormatado),
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
                    Text('Total: ${NumberFormat.simpleCurrency(locale: 'pt_BR').format(total)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Implementar a lógica de finalização do pedido
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