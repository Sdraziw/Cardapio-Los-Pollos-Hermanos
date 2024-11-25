import 'package:flutter/material.dart';
import '../services/pedido_service.dart';
import 'package:logger/logger.dart';

PedidoService pedidoService = PedidoService();
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
      Navigator.pushReplacementNamed(context, 'menu');
    } else if (index == 1) {
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
      historico = List<Map<String, dynamic>>.from(await pedidoService.obterHistorico());
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
          ? Center(child: Text('Nenhum pedido finalizado encontrado'))
          : ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final pedido = historico[index];
                final itens = pedido['itens'] as List<Map<String, dynamic>>;
                return ExpansionTile(
                  title: Text('Pedido #${pedido['numeroPedido']}'),
                  subtitle: Text('Status: ${pedido['statusPedido']}'),
                  children: itens.map((item) {
                    return ListTile(
                      leading: item['imagem'].isNotEmpty
                          ? (item['imagem'].startsWith('http')
                              ? Image.network(item['imagem'], width: 50, height: 50)
                              : Image.asset(item['imagem'], width: 50, height: 50))
                          : null,
                      title: Text(item['nome']),
                      subtitle: Text(item['descricao']),
                      trailing: Text('R\$ ${item['preco'].toStringAsFixed(2)}'),
                    );
                  }).toList(),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: Color(0xFFFFD600),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu🍔'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}