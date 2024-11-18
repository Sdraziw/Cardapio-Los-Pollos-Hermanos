import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  String nome;
  String descricao;
  String imagem;
  int ordem;

  Categoria({
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.ordem,
  });

  factory Categoria.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Categoria(
      nome: data['nome'],
      descricao: data['descricao'],
      imagem: data['imagem'],
      ordem: data['ordem'],
    );
  }
}