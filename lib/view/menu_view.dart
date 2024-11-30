import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import '../controller/login_controller.dart';
import '../controller/menu_controller.dart' as custom;
import '../services/pedido_service.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  MenuViewState createState() => MenuViewState();
}

class MenuViewState extends State<MenuView> {
  final LoginController loginController = LoginController();
  final custom.MenuController menuController = custom.MenuController();
  final PedidoService pedidoService = PedidoService();

  String query = '';
  int _currentIndex = 0;
  int quantidadeItensCarrinho = 0;

  @override
  void initState() {
    super.initState();
    consultarQuantidadeItensCarrinho();
  }

  consultarQuantidadeItensCarrinho() async {
    int quantidadeCarrinho =
        await pedidoService.consultarQuantidadeItensCarrinho();
    setState(() {
      quantidadeItensCarrinho = quantidadeCarrinho;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFFFFD600),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /*FutureBuilder<String>(
                future: loginController.usuarioLogadoPrimeiroNome(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar dados: ${snapshot.error}');
                  } else {
                    return Text(
                      '\nBem-vindo, ${snapshot.data}! -  Los Pollos Hermanos! MENU',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'CarnevaleeFreakshow',
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),*/
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    // campo de pesquisa (lupa)
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Digite aqui para pesquisar...',
                          hintTextDirection: TextDirection.ltr,
                          hintStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                      ),
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: quantidadeItensCarrinho > 0
                            ? [Colors.orange, Colors.orangeAccent, Colors.blueAccent]
                            : [Colors.transparent, Colors.transparent, Colors.transparent],
                            begin: quantidadeItensCarrinho > 0
                            ? Alignment.topLeft : Alignment.bottomCenter,
                            end: quantidadeItensCarrinho > 0
                            ? Alignment.bottomCenter : Alignment.topRight,
                          ),
                        ),
                        padding: EdgeInsets.all(
                            8), // Ajuste o padding conforme necessário
                        child: IconButton(
                          icon: Icon(Icons.shopping_cart, color: Colors.black),
                          onPressed: () {
                            // Navegar para a tela do carrinho de compras
                            Navigator.pushNamed(context, 'carrinho');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.black.withOpacity(0.5),
                                duration: Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 10.0),
                                padding: EdgeInsets.all(5.0),
                                content: Text(
                                  'Carrinho de compras $quantidadeItensCarrinho itens',
                                  style: TextStyle(fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (quantidadeItensCarrinho >
                          0) // Exibir quantidade de itens no carrinho conceito BADGE
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$quantidadeItensCarrinho',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Imagem de fundo com opacidade
          Positioned.fill(
            child: Image.asset(
              'lib/images/fundo2.png',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.5),
              colorBlendMode: BlendMode.lighten,
            ),
          ),
          // Filtro de desfoque
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
              child: Container(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
          // Conteúdo principal
          Column(
            children: [
              Container(
                width: double.infinity, // Ocupa toda a largura disponível
                color: Color(0xFFFFD600), // Cor de fundo do container
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: FutureBuilder<String>(
                  future: loginController.usuarioLogadoPrimeiroNome(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 10),
                          Text(
                            'Carregando usuario...',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'CarnevaleeFreakshow',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Erro: ${snapshot.error}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    } else {
                      return Text(
                        'Bem-vindo, ${snapshot.data}! - Los Pollos Hermanos! MENU',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'CarnevaleeFreakshow',
                          color: Colors.black,
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('categorias')
                      .orderBy('ordem')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                          child: Text(
                              'Erro ao carregar dados: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return Center(
                          child: Text('Nenhuma categoria encontrada'));
                    }

                    List<DocumentSnapshot> categorias = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: categorias.length,
                      itemBuilder: (context, categoriaIndex) {
                        DocumentSnapshot categoriaDoc =
                            categorias[categoriaIndex];
                        String categoriaNome = categoriaDoc['nome'];
                        String categoriaImagem = categoriaDoc['imagem'];
                        String categoriaDescricao = categoriaDoc['descrição'];

                        return Column(
                          children: [
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('itens_cardapio')
                                  .where('ativo', isEqualTo: true)
                                  .where('categoria', isEqualTo: categoriaNome)
                                  .snapshots(),
                              builder: (context, itemSnapshot) {
                                if (itemSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (itemSnapshot.hasError) {
                                  return Center(
                                      child: Text(
                                          'Erro ao carregar itens: ${itemSnapshot.error}'));
                                } else if (!itemSnapshot.hasData ||
                                    itemSnapshot.data!.docs.isEmpty) {
                                  return SizedBox.shrink();
                                }

                                List<Prato> itensMenu = itemSnapshot.data!.docs
                                    .map((doc) => Prato.fromDocument(doc))
                                    .where((prato) =>
                                        categoriaNome.toLowerCase().contains(query
                                            .toLowerCase()) || // Verifica se a categoria corresponde
                                        prato.nome.toLowerCase().contains(query
                                            .toLowerCase())) // Ou se algum prato corresponde
                                    .toList();

                                if (itensMenu.isEmpty &&
                                    !categoriaNome
                                        .toLowerCase()
                                        .contains(query.toLowerCase())) {
                                  return SizedBox
                                      .shrink(); // Oculta a categoria se nada corresponder
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Título da categoria
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Row(
                                        children: [
                                          if (categoriaImagem.isNotEmpty)
                                            categoriaImagem.startsWith('http')
                                                ? Image.network(categoriaImagem,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover)
                                                : Image.asset(categoriaImagem,
                                                    width: 60,
                                                    height: 60,
                                                    fit: BoxFit.cover),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  categoriaNome,
                                                  style: const TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  categoriaDescricao,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    // Lista de pratos
                                    ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: itensMenu.length,
                                      itemBuilder: (context, index) {
                                        Prato prato = itensMenu[index];
                                        return Card(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          elevation: 2,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                'detalhes',
                                                arguments: prato,
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  if (prato.imagem.isNotEmpty)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: prato.imagem
                                                              .startsWith(
                                                                  'http')
                                                          ? Image.network(
                                                              prato.imagem,
                                                              width: 80,
                                                              height: 80,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              prato.imagem,
                                                              width: 80,
                                                              height: 80,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          prato.nome,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 5),
                                                        Text(
                                                          prato.descricao,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    'R\$ ${prato.preco.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      //color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                            // Espaçamento entre as categorias
                            if (query == '') const SizedBox(height: 50),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: Color(0xFFFFD600),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {
            Navigator.pushReplacementNamed(context, 'menu');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, 'historico');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, 'perfil');
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu🍔'),//caractere hamburguer para menu de opções do app 
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
