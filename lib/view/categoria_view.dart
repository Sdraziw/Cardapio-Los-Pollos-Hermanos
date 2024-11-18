import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/categoria_model.dart'; // Atualize o caminho conforme necessário

class CategoriaView extends StatelessWidget {
  const CategoriaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categorias'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categorias').orderBy('ordem').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar categorias'));
          }
          final categorias = snapshot.data!.docs.map((doc) => Categoria.fromFirestore(doc)).toList();
          return ListView.builder(
            itemCount: categorias.length,
            itemBuilder: (context, index) {
              final categoria = categorias[index];
              return ListTile(
                title: Text(categoria.nome),
                subtitle: Text(categoria.descricao),
                leading: categoria.imagem.isNotEmpty
                    ? Image.network(categoria.imagem, width: 50, height: 50)
                    : null,
                onTap: () {
                  Navigator.pushNamed(context, '/itens', arguments: categoria.nome);
                },
              );
            },
          );
        },
      ),
    );
  }
}
