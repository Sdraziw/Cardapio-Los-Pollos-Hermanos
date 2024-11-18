import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart'; // Atualize o caminho conforme necessário

class CategoriaView extends StatelessWidget {
  const CategoriaView({super.key});

  @override
  Widget build(BuildContext context) {
    final String categoria = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Categoria: $categoria'),
        backgroundColor: Color(0xFFFFD600),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Voltar à página anterior
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('itens_cardapio')
            .where('categoria', isEqualTo: categoria)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Prato> pratos = snapshot.data!.docs.map((doc) => Prato.fromDocument(doc)).toList();
          pratos.sort((a, b) => a.nome.compareTo(b.nome));

          return ListView.builder(
            itemCount: pratos.length,
            itemBuilder: (context, index) {
              Prato prato = pratos[index];
              return ListTile(
                leading: Image.network(prato.imagem),
                title: Text(prato.nome),
                subtitle: Text(prato.descricao),
                trailing: Text(prato.preco.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
