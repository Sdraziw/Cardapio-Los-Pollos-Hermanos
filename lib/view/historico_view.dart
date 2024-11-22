import 'package:flutter/material.dart';
import '../services/pedido_service.dart';
import 'package:logger/logger.dart';

class HistoricoView extends StatefulWidget {
  const HistoricoView({super.key});

  @override
  HistoricoViewState createState() => HistoricoViewState();
}

class HistoricoViewState extends State<HistoricoView> {
  List<Map<String, dynamic>> historico = [];
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
      historico = List<Map<String, dynamic>>.from(await PedidoService().obterHistorico());
      setState(() {});
    } catch (e) {
      Logger().e('Erro ao carregar histórico: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Pedidos'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: historico.isEmpty
          ? Center(child: Text('Nenhum pedido finalizado encontrado.'))
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> pedido = historico[index];
                return ListTile(
                  title: Text('Pedido #${pedido['numero_pedido'].toString()}'),
                  subtitle: Text('Status: ${pedido['status'].toString()}'),
                  trailing: Text('Data: ${DateTime.parse(pedido['data_hora']).toLocal().toString()}'),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
