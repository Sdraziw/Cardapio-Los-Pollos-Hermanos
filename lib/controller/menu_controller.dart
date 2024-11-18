import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String> nomeCategoria(ordem) async {
    var nome = "";
    await FirebaseFirestore.instance
      .collection('categorias')
      .where('ordem', isEqualTo: ordem)
      .get()
      .then((value){
        nome = value.docs[0].data()['nome']  ?? '';
      });
    return nome;
  }

  Future<String> ordemCategoria(nome) async {
    var ordem = "";
    await FirebaseFirestore.instance
      .collection('categorias')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value){
        ordem = value.docs[0].data()['ordem']  ?? '';
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

  Future<bool> itensCardapioAtivo(nome) async {
    var ativo = false;
    await FirebaseFirestore.instance
      .collection('itens_cardapio')
      .where('nome', isEqualTo: nome)
      .get()
      .then((value){
        ativo = value.docs[0].data()['ativo']  ?? '';
      });
    return ativo;
  }
}