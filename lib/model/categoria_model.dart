import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  String nome;
  String descricao;
  String imagem;
  int ordem;
  bool ativo;

  Categoria({
    required this.nome,
    required this.descricao,
    required this.imagem,
    required this.ordem,
    required this.ativo,
  });

  factory Categoria.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Categoria(
      nome: data['nome'],
      descricao: data['descricao'],
      imagem: data['imagem'],
      ordem: data['ordem'],
      ativo: data['ativo'],
    );
  }
}