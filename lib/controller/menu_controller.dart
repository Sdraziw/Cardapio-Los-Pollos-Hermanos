import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> nomeCategoria(int ordem) async {
    var nome = "";
    await FirebaseFirestore.instance
      .collection('categorias')
      .where('ordem', isEqualTo: ordem)
      .get()
      .then((value) {
        if (value.docs.isNotEmpty) {
          nome = value.docs[0].data()['nome'] ?? '';
        }
      });
    return nome;
  }

  Future<int> ordemCategoria(String nome) async {
    var ordem = 0;
    await FirebaseFirestore.instance
      .collection('categorias')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value) {
        if (value.docs.isNotEmpty) {
          ordem = value.docs[0].data()['ordem'] ?? 0;
        }
      });
    return ordem;
  }

  Future<String> itensCardapioNome(categoria) async {
    var nome = "";
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('categoria', isEqualTo: categoria)
      .get()
      .then((value){
        nome = value.docs[0].data()['nome']  ?? '';
      });
    return nome;
  }

  Future<String> itensCardapioDescricao(nome) async {
    var descricao = "";
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value){
        descricao = value.docs[0].data()['descricao']  ?? '';
      });
    return descricao;
  }

  Future<double> itensCardapioPreco(nome) async {
    var preco = 0.0;
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value){
        preco = value.docs[0].data()['preco']  ?? '';
      });
    return preco;
  }

  Future<String> itensCardapioImagem(nome) async {
    var imagem = '';
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value){
        imagem = value.docs[0].data()['imagem']  ?? '';
      });
    return imagem;
  }

  Future<bool> itensCardapioAtivo(String nome) async {
    bool ativo = false;
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value) {
        if (value.docs.isNotEmpty) {
          ativo = value.docs[0].data()['ativo'] ?? false;
        }
      });
    return ativo;
  }

  Future<String> obterImagemPorNome(String nome) async {
    String imagem = '';
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value) {
        if (value.docs.isNotEmpty) {
          imagem = value.docs[0].data()['imagem'] ?? '';
        }
      });
    return imagem;
  }

  Future<List<String>> obterItensPorCategoria(String categoria) async {
    List<String> itens = [];
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('categoria', isEqualTo: categoria)
      .get()
      .then((value) {
        for (var doc in value.docs) {
          itens.add(doc.data()['nome']);
        }
      });
    return itens;
  }
}