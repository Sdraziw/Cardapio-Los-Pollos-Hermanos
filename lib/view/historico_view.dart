import 'package:flutter/material.dart';
import '../services/pedido_service.dart';
import 'package:logger/logger.dart';

class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  HistoricoViewState createState() => HistoricoViewState();
}

class HistoricoViewState extends State<HistoricoView> {
  List<String> historico = [];
  int _currentIndex = 1;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Lógica para a tela de Menu
      Navigator.pushReplacementNamed(context, 'menu');
    } else if (index == 1) {
      // Navegar para a tela de categorias
      Navigator.pushReplacementNamed(context, 'historico');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, 'perfil');
    }
  }

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    try {
      historico = await getIt<PedidoService>().obterHistorico();
      setState(() {});
    } catch (e) {
      Logger().e('Erro ao carregar histórico: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Histórico de Pedidos'),
            Image.network(
              'lib/images/rv_2.png',
              height: 90,
            ),
          ],
        ),
        backgroundColor: Color(0xFFFFD600),
        automaticallyImplyLeading: false,
      ),
      body: historico.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Você ainda não fez nenhum pedido.\n\nFaça um pedido para começar a ver seu histórico!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                ),
              ),
            )
          : ListView.separated(
              itemCount: historico.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pedido ${index + 1}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          historico[index],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Data e Hora retirada: ${DateTime.now().toLocal()}'
                              .split(' ')[0], // Data atual para exemplo
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
