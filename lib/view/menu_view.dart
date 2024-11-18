import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import '../controller/menu_controller.dart' as custom; // Atualize o caminho conforme necessário
import '../controller/login_controller.dart'; // Atualize o caminho conforme necessário

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  MenuViewState createState() => MenuViewState();
}

class MenuViewState extends State<MenuView> {
  final custom.MenuController _menuController = custom.MenuController();
  final LoginController loginController = LoginController();
  String query = '';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Column(
        children: [
          FutureBuilder<String>(
            future: loginController.usuarioLogadoPrimeiroNome(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Erro ao carregar dados');
              } else {
                return Text(
                  'Bem-vindo, ${snapshot.data}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'CarnevaleeFreakshow',
                    color: Colors.black,
                  ),
                );
              }
            },
          ),
          SizedBox(height: 1),
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
                      hintText: 'Digite aqui para pesquisar...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('itens_cardapio').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Prato> itensMenu = snapshot.data!.docs.map((doc) => Prato.fromDocument(doc)).toList();
                itensMenu.sort((a, b) => a.categoria.compareTo(b.categoria));

                Map<String, List<Prato>> itensPorCategoria = {};
                for (var item in itensMenu) {
                  if (!itensPorCategoria.containsKey(item.categoria)) {
                    itensPorCategoria[item.categoria] = [];
                  }
                  itensPorCategoria[item.categoria]!.add(item);
                }

                return ListView(
                  children: itensPorCategoria.entries.map((entry) {
                    return ExpansionTile(
                      title: Text(entry.key),
                      children: entry.value.map((prato) {
                        return FutureBuilder<bool>(
                          future: _menuController.itensCardapioAtivo(prato.nome),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return ListTile(
                                title: Text(prato.nome),
                                subtitle: Text('Verificando disponibilidade...'),
                              );
                            }

                            bool ativo = snapshot.data!;
                            if (!ativo) {
                              return ListTile(
                                title: Text(prato.nome),
                                subtitle: Text('Item indisponível'),
                              );
                            }

                            return ListTile(
                              leading: prato.imagem.isNotEmpty
                                  ? (prato.imagem.startsWith('http')
                                      ? Image.network(prato.imagem)
                                      : Image.asset(prato.imagem))
                                  : null,
                              title: Text(prato.nome),
                              subtitle: Text(prato.descricao),
                              trailing: Text(prato.precoFormatado),
                              onTap: () {
                                // Navegar para a tela de detalhes do produto
                                Navigator.pushNamed(context, 'detalhes', arguments: prato);
                              },
                            );
                          },
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}