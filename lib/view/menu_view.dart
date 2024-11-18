import 'package:flutter/material.dart';
import '../controller/menu_controller.dart' as custom;
import '../controller/login_controller.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  final custom.MenuController _menuController = custom.MenuController();
  final LoginController _loginController = LoginController();
  String query = '';
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFD600),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _loginController.usuarioLogadoPrimeiroNome(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text(
                    'Carregando...',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'CarnevaleeFreakshow',
                      color: Colors.black,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(
                    'Erro',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'CarnevaleeFreakshow',
                      color: Colors.red,
                    ),
                  );
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
          ],
        ),
      ),
      body: FutureBuilder<String>(
        future: _menuController.itensCardapioNome('categoria_exemplo'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar dados'));
          } else {
            return Center(child: Text('Item: ${snapshot.data}'));
          }
        },
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
