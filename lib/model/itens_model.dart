import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Prato {
  String nome;
  double preco; // Alterado para double
  String imagem;
  String descricao;
  String resumo;
  int quantidade;
  String status;
  bool cupom;
  String categoria;

  Prato({
    required this.nome,
    required this.preco,
    required this.imagem,
    required this.descricao,
    required this.resumo,
    this.quantidade = 1,
    this.status = 'pendente',
    this.cupom = false,
    required this.categoria,
  });

  // Método para formatar o preço do prato em formato R$
  String get precoFormatado {
    final NumberFormat formatter = NumberFormat.simpleCurrency(locale: 'pt_BR');
    return formatter.format(preco);
  }

  // Método para atualização da quantidade
  void atualizarQuantidade(int novaQuantidade) {
    if (novaQuantidade > 0) {
      quantidade = novaQuantidade;
    }
  }

  // Método estático para criar uma instância de Prato a partir de um documento do Firestore
  static Prato fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prato(
      nome: data.containsKey('nome') ? data['nome'] : '',
      preco: data.containsKey('preco') ? (data['preco'] as num).toDouble() : 0.0,
      imagem: data.containsKey('imagem') ? data['imagem'] : '',
      descricao: data.containsKey('descricao') ? data['descricao'] : '',
      resumo: data.containsKey('resumo') ? data['resumo'] : '',
      quantidade: data.containsKey('quantidade') ? data['quantidade'] : 1,
      status: data.containsKey('status') ? data['status'] : 'pendente',
      cupom: data.containsKey('cupom') ? data['cupom'] : false,
      categoria: data.containsKey('categoria') ? data['categoria'] : '',
    );
  }

  // Método estático para buscar todos os itens do Firestore
  static Future<List<Prato>> buscarTodos() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('itens_cardapio').get();
    return querySnapshot.docs.map((doc) => Prato.fromDocument(doc)).toList();
  }

  // Método estático para buscar um item específico pelo nome
  static Future<Prato?> buscarPorNome(String nome) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('itens_cardapio')
        .where('nome', isEqualTo: nome)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      return Prato.fromDocument(querySnapshot.docs.first);
    }
    return null;
  }

  // Método estático para verificar se um item já existe no Firestore
  static Future<bool> itemExiste(String nome) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('itens_cardapio')
        .where('nome', isEqualTo: nome)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Método estático para adicionar itens ao Firestore
  static Future<void> adicionarItensAoFirestore(List<Prato> pratos, String categoria) async {
    for (Prato prato in pratos) {
      bool existe = await itemExiste(prato.nome);
      if (!existe) {
        await FirebaseFirestore.instance.collection('itens_cardapio').add({
          'nome': prato.nome,
          'preco': prato.preco, // Armazenar como número
          'imagem': prato.imagem,
          'descricao': prato.descricao,
          'resumo': prato.resumo,
          'quantidade': prato.quantidade,
          'status': prato.status,
          'cupom': prato.cupom,
          'categoria': categoria,
          'ativo': true,
        });
      }
    }
  }


  // Método estático para geração de Entradas
  static Future<void> gerarEntradas() async {
    List<Prato> entradas = [
      Prato(
        nome: 'Onion Rings',
        preco: 10.50,
        imagem: 'lib/images/onion rings.png',
        descricao: 'Anéis de cebola empanados e fritos, crocantes',
        resumo: '10 pedaços | 300g',
        categoria: 'Porções',
      ),
      Prato(
        nome: "Nuggets",
        preco: 10.50,
        imagem: "lib/images/nuggets.png",
        descricao: "Nuggets de frango empanados, crocantes por fora e suculentos por dentro",
        resumo: '10 pedaços | 300g',
        categoria: 'Porções',
      ),
      Prato(
        nome: "Batata Frita G",
        preco: 10.90,
        imagem: "lib/images/french fries (2).png",
        descricao: "Batatas fritas, crocantes e temperadas",
        resumo: '200g',
        categoria: 'Porções',
      ),
      Prato(
        nome: "Batata Frita M",
        preco: 8.90,
        imagem: "lib/images/french fries (2).png",
        descricao: "Batatas fritas, crocantes e temperadas",
        resumo: '150g',
        categoria: 'Porções',
      ),
      Prato(
        nome: "Batata Frita P",
        preco: 7.90,
        imagem: "lib/images/french fries (2).png",
        descricao: "Batatas fritas, crocantes e temperadas",
        resumo: '100g',
        categoria: 'Porções',
      ),
      Prato(
        nome: "Combo Onions & Fritas",
        preco: 35.50,
        imagem: "lib/images/onions_batatas.png",
        descricao: "Anéis de cebola & Frango e Batatas fritas crocantes e temperadas num combo com maionese, ketchup, molhos especiais e molhos separados de mostarda e mel + barbecue + cebola crua",
        resumo: 'Sortidos 1/3 de onions + 1/3 de batatas + 1/3 de frango empanado | 1,1 kg',
        categoria: 'Porções',
      ),
    ];

    await adicionarItensAoFirestore(entradas, 'Entradas');
  }

  // Método estático para geração de Pratos Principais
  static Future<void> gerarPratosPrincipais() async {
    List<Prato> pratosPrincipais = [
      Prato(
        nome: 'X - Walter White',
        preco: 25.50,
        imagem: 'lib/images/burguer.png',
        descricao: 'Peito de frango empanado com queijo, tiras de bacon e molho especial',
        resumo: '400g',
        categoria: 'Lanches',
      ),
      Prato(
        nome: "X - Heisenberg",
        preco: 45.50,
        imagem: "lib/images/hamburger.png",
        descricao: "Dois hamburgueres com muito cheddar, tiras de bacon e molho picante",
        resumo: '500g',
        categoria: 'Lanches',
      ),
      Prato(
        nome: "X - Hank Schrader",
        preco: 32.50,
        imagem: "lib/images/hankburger.png",
        descricao: "Hamburguer saboroso de gnu, uma fatia semi-derretida de cheddar, anéis de cebola, fatias de picles, salada refrescante de alface e tomate, maionese e molho especial",
        resumo: '500g',
        categoria: 'Lanches',
      ),
      Prato(
        nome: "X - Gus Fring",
        preco: 25.50,
        imagem: "lib/images/xsalada.png",
        descricao: "Hamburguer suculento dos pampas, uma fatia de muçarela e uma salada refrescante de alface e tomate",
        resumo: '500g',
        categoria: 'Lanches',
      ),
      Prato(
        nome: "X - Jesse Pinkman",
        preco: 15.50,
        imagem: "lib/images/jesseburger.png",
        descricao: "Hamburguer delicioso feito na chapa, uma fatia generosa de cheddar e molho especial",
        resumo: '500g',
        categoria: 'Lanches',
      ),
      Prato(
        nome: "Combo Duplo - Cê é LOCO cachoeira",
        preco: 55.90,
        imagem: "lib/images/slc que imagem.jpeg",
        descricao: "2 Pães de hamburguer, 2 X Frango Parrudo Empanado, Molho Barbecue",
        resumo: '2 lanches parrudo | 200g cada',
        categoria: 'Lanches',
      ),
    ];

    await adicionarItensAoFirestore(pratosPrincipais, 'Pratos Principais');
  }

  // Método estático para geração de Baldes
  static Future<void> gerarBaldes() async {
    List<Prato> baldes = [
      Prato(
        nome: 'Balde de Frango G',
        preco: 19.50,
        imagem: 'lib/images/balde G.png',
        descricao: 'Frango marinado em especiarias, frito até a perfeição',
        resumo: '14 pedaços | 600g',
        categoria: 'Baldes',
      ),
      Prato(
        nome: 'Balde de Frango M',
        preco: 17.50,
        imagem: 'lib/images/balde G.png',
        descricao: 'Frango marinado em especiarias, frito até a perfeição',
        resumo: '12 pedaços | 500g',
        categoria: 'Baldes',
      ),
      Prato(
        nome: 'Balde de Frango P',
        preco: 15.50,
        imagem: 'lib/images/balde G.png',
        descricao: 'Frango marinado em especiarias, frito até a perfeição',
        resumo: '10 pedaços | 400g',
        categoria: 'Baldes',
      ),
    ];

    await adicionarItensAoFirestore(baldes, 'Baldes');
  }

  // Método estático para geração de Bebidas
  static Future<void> gerarBebidas() async {
    List<Prato> bebidas = [
      Prato(
        nome: "Refrigerante Soda",
        preco: 10.90,
        imagem: "lib/images/refri G.png",
        descricao: "Refrigerante Soda 500ml gelado para acompanhar seu prato",
        resumo: '500ml',
        categoria: 'Bebidas',
      ),
      Prato(
        nome: "Refrigerante Coca",
        preco: 12.90,
        imagem: "lib/images/coke.png",
        descricao: "Refrigerante Coca 500ml gelado para acompanhar seu prato",
        resumo: '500ml',
        categoria: 'Bebidas',
      ),
      Prato(
        nome: "Refrigerante Schweppes",
        preco: 9.50,
        imagem: "lib/images/Schweppes.png",
        descricao: "Refrigerante Schweppes 1500ml gelado para acompanhar seu pedido",
        resumo: 'Um litro e meio.',
        categoria: 'Bebidas',
      ),
      Prato(
        nome: "Água c/gás",
        preco: 3.00,
        imagem: "lib/images/agua-com-gas-500ml.png",
        descricao: "Água mineral com gás, refrescante",
        resumo: '500ml',
        categoria: 'Bebidas',
      ),
      Prato(
        nome: "Água s/gás",
        preco: 2.50,
        imagem: "lib/images/agua_sem_gas.png",
        descricao: "Água mineral natural, perfeita para hidratação",
        resumo: '500ml',
        categoria: 'Bebidas',
      ),
      Prato(
        nome: "Suco Dell Valle",
        preco: 7.50,
        imagem: "lib/images/suco_delvale.png",
        descricao: "Suco natural de frutas, refrescante e saudável",
        resumo: '350ml',
        categoria: 'Bebidas',
      ),
    ];

    await adicionarItensAoFirestore(bebidas, 'Bebidas');
  }

  // Método estático para geração de Sobremesas
  static Future<void> gerarSobremesas() async {
    List<Prato> sobremesas = [
      Prato(
        nome: "Cheesecake",
        preco: 12.00,
        imagem: "lib/images/cheesecake.jpg",
        descricao: "Delicioso cheesecake com cobertura de frutas vermelhas",
        resumo: '1 fatia',
        categoria: 'Sobremesas',
      ),
      Prato(
        nome: "Brownie",
        preco: 8.00,
        imagem: "lib/images/brownie.jpg",
        descricao: "Brownie de chocolate com nozes",
        resumo: '1 pedaço',
        categoria: 'Sobremesas',
      ),
      Prato(
        nome: "Sorvete Negresco",
        preco: 7.50,
        imagem: "lib/images/ice-cream.webp",
        descricao: "Sorvete Negresco é feito de leite condensado, leite, biscoitos Negresco, essência de baunilha, ovos, açúcar e creme de leite. Bem simples e delicioso! 🍦",
        resumo: 'Casquinha Recheada e Massa Baunilha',
        categoria: 'Sobremesas',
      ),
    ];

    await adicionarItensAoFirestore(sobremesas, 'Sobremesas');
  }
}