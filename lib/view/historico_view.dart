import 'package:flutter/material.dart';
import '../services/pedido_service.dart';

class HistoricoView extends StatefulWidget {
  @override
  _HistoricoViewState createState() => _HistoricoViewState();
}

class _HistoricoViewState extends State<HistoricoView> {
  List<String> historico = [];

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
      print('Erro ao carregar histórico: $e');
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
    );
  }
}
