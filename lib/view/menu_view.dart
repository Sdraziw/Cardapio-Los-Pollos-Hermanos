import 'package:flutter/material.dart';
import '../model/itens_model.dart';
import '../controller/login_controller.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  List<Prato> listaEntradas = [];
  List<Prato> listaPratosPrincipais = [];
  List<Prato> listaBebidas = [];
  List<Prato> listaSobremesas = [];
  List<Prato> listaBaldes = [];
  String query = '';
  int _currentIndex = 0;
  final LoginController _controller = LoginController();

  @override
  void initState() {
    super.initState();

    //optamos náo usar ListView.builder

    // Preencher as listas com os Pratos organizados por categoria
    listaEntradas = Prato.gerarEntradas();
    listaPratosPrincipais = Prato.gerarPratosPrincipais();
    listaBebidas = Prato.gerarBebidas();
    listaSobremesas = Prato.gerarSobremesas();
    listaBaldes = Prato.gerarBaldes();
  }

  // Função para filtrar os itens com base na pesquisa
  List<Prato> filtrarPratos(List<Prato> pratos, String query) {
    return pratos.where((prato) {
      final nomePratoLower = prato.nome.toLowerCase();
      final searchLower = query.toLowerCase();
      return nomePratoLower.contains(searchLower);
    }).toList();
  }

  // Função para alternar entre diferentes telas da BottomNavigationBar
  void _onTabTapped(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    final entradasFiltradas = filtrarPratos(listaEntradas, query);
    final pratosPrincipaisFiltrados =
        filtrarPratos(listaPratosPrincipais, query);
    final bebidasFiltradas = filtrarPratos(listaBebidas, query);
    final sobremesasFiltradas = filtrarPratos(listaSobremesas, query);
    final baldesFiltrados = filtrarPratos(listaBaldes, query);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFD600),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _controller.usuarioLogadoPrimeiroNome(),
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
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            // Entradas
            if (entradasFiltradas.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Porções',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              ...entradasFiltradas.map((prato) => Card(
                    margin: EdgeInsets.all(
                        5), // Reduz o espaçamento externo do card
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      
                      onTap: () {
                        Navigator.pushNamed(context, 'detalhes', arguments: prato);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                prato.foto,
                                height: 80,
                                width: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prato.nome, style: TextStyle(fontSize: 16),),
                                  Text(prato.preco, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Icon(Icons.play_arrow_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 50),
            ],

            //SizedBox(height: 50),

            // Baldes
            if (baldesFiltrados.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Baldes de Frango',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              ...baldesFiltrados.map((prato) => Card(
                    margin: EdgeInsets.all(
                        5), // Reduz o espaçamento externo do card
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      
                      onTap: () {
                        Navigator.pushNamed(context, 'detalhes', arguments: prato);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                prato.foto,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prato.nome, style: TextStyle(fontSize: 16),),
                                  Text(prato.preco, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Icon(Icons.play_arrow_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 50),
            ],

            //SizedBox(height: 50),

            // Pratos Principais
            if (pratosPrincipaisFiltrados.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Lanches',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              ...pratosPrincipaisFiltrados.map((prato) => Card(
                    margin: EdgeInsets.all(
                        5), // Reduz o espaçamento externo do card
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      
                      onTap: () {
                        Navigator.pushNamed(context, 'detalhes', arguments: prato);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                prato.foto,
                                height: 80,
                                width: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prato.nome, style: TextStyle(fontSize: 16),),
                                  Text(prato.preco, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Icon(Icons.play_arrow_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 50),
            ],

            //SizedBox(height: 50),

            // Bebidas
            if (bebidasFiltradas.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Bebidas',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              ...bebidasFiltradas.map((prato) => Card(
                    margin: EdgeInsets.all(
                        5), // Reduz o espaçamento externo do card
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      
                      onTap: () {
                        Navigator.pushNamed(context, 'detalhes', arguments: prato);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                prato.foto,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prato.nome, style: TextStyle(fontSize: 16),),
                                  Text(prato.preco, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Icon(Icons.play_arrow_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),
                  )),
                  SizedBox(height: 50),
            ],

            //SizedBox(height: 50),

            // Sobremesas
            if (sobremesasFiltradas.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Sobremesas',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              ...sobremesasFiltradas.map((prato) => Card(
                    margin: EdgeInsets.all(
                        5), // Reduz o espaçamento externo do card
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      
                      onTap: () {
                        Navigator.pushNamed(context, 'detalhes', arguments: prato);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(
                            8.0),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                prato.foto,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(prato.nome, style: TextStyle(fontSize: 16),),
                                  Text(prato.preco, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                                ],
                              ),
                            ),
                            Icon(Icons.play_arrow_rounded, size: 22),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: Color(0xFFFFD600),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
