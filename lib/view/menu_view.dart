import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import '../controller/login_controller.dart'; // Atualize o caminho conforme necessário
import '../controller/menu_controller.dart' as custom; // Atualize o caminho conforme necessário

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  MenuViewState createState() => MenuViewState();
}

class MenuViewState extends State<MenuView> {
  final LoginController loginController = LoginController();
  final custom.MenuController menuController = custom.MenuController();
  String query = '';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
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
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    // campo de pesquisa (lupa)
                    child: SizedBox(
                      height: 25,
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            query = value;
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Digite aqui para pesquisar...(itens ou categorias)',
                          hintTextDirection: TextDirection.ltr,
                          hintStyle: TextStyle(fontSize: 12),
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
                  IconButton(
                    icon: Icon(Icons.shopping_cart, color: Colors.black),
                    onPressed: () {
                      // Navegar para a tela do carrinho de compras
                      Navigator.pushNamed(context, 'carrinho');
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
          backgroundColor: Color(0xFFFFD600),
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
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          // Conteúdo principal
          Column(
            children: [
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
                      return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('Nenhuma categoria encontrada'));
                    }

                    List<DocumentSnapshot> categorias = snapshot.data!.docs;

                    return ListView(
                      children: categorias.map((categoriaDoc) {
                        String categoriaNome = categoriaDoc['nome'];
                        String categoriaDescricao = categoriaDoc['descrição'];
                        String categoriaImagem = categoriaDoc['imagem'];

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('itens_cardapio')
                              .where('ativo', isEqualTo: true)
                              .where('categoria', isEqualTo: categoriaNome)
                              .snapshots(),
                          builder: (context, itemSnapshot) {
                            if (itemSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (itemSnapshot.hasError) {
                              return Center(child: Text('Erro ao carregar itens: ${itemSnapshot.error}'));
                            } else if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
                              return SizedBox.shrink(); // Não exibe a categoria se não houver itens
                            }

                            List<Prato> itensMenu = itemSnapshot.data!.docs
                                .map((doc) => Prato.fromDocument(doc))
                                .where((prato) => prato.nome.toLowerCase().contains(query.toLowerCase()))
                                .toList();

                            if (itensMenu.isEmpty && !categoriaNome.toLowerCase().contains(query.toLowerCase())) {
                              return SizedBox.shrink(); // Não exibe a categoria se não houver itens correspondentes à pesquisa
                            }

                            return ExpansionTile(
                              leading: categoriaImagem.isNotEmpty
                                  ? (categoriaImagem.startsWith('http')
                                      ? Image.network(categoriaImagem, width: 200, height: 50)
                                      : Image.asset(categoriaImagem, width: 70, height: 70))
                                  : null,
                              title: Text(categoriaNome),
                              subtitle: Text(
                                categoriaDescricao,
                                style: TextStyle(fontSize: 12),
                              ),
                              children: itensMenu.map((prato) {
                                return ListTile(
                                  leading: prato.imagem.isNotEmpty
                                      ? (prato.imagem.startsWith('http')
                                          ? Image.network(prato.imagem, width: 50, height: 50)
                                          : Image.asset(prato.imagem, width: 50, height: 50))
                                      : null,
                                  title: Text(prato.nome),
                                  subtitle: Text(prato.descricao),
                                  trailing: Text('R\$ ${prato.preco.toStringAsFixed(2)}'),
                                  onTap: () {
                                    // Navegar para a tela de detalhes do prato
                                    Navigator.pushNamed(
                                      context,
                                      'detalhes',
                                      arguments: prato,
                                    );
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      }).toList(),
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
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu🍔'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}