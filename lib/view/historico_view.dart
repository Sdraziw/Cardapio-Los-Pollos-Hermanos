import 'package:flutter/material.dart';
import '../services/pedido_service.dart';
import 'package:logger/logger.dart';
import '../controller/login_controller.dart';
//import '../model/itens_model.dart';

PedidoService pedidoService = PedidoService();

class HistoricoView extends StatefulWidget {
  HistoricoView({super.key});
  final LoginController loginController = LoginController();

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
      historico = await pedidoService.obterPedidosFinalizados();
      setState(() {});
    } catch (e) {
      Logger().e('Erro ao carregar histórico: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          
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
          
          /*
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String>(
                future: widget.loginController.usuarioLogadoPrimeiroNome(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar dados: ${snapshot.error}');
                  } else {
                    return Text(
                      '\nPEDIDOS de ${snapshot.data}',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'CarnevaleeFreakshow',
                        color: Colors.black,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          backgroundColor: Color(0xFFFFD600),*/
        //),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: pedidoService.buscarItensPedidoFinalizadosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar itens: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum pedido finalizado encontrado'));
          } else {
            final itens = snapshot.data!;
            final pedidosAgrupados = <String, List<Map<String, dynamic>>>{};

            for (var item in itens) {
              final numeroPedido = item['numeroPedido'];
              if (!pedidosAgrupados.containsKey(numeroPedido)) {
                pedidosAgrupados[numeroPedido] = [];
              }
              pedidosAgrupados[numeroPedido]!.add(item);
            }

            return ListView.builder(
              itemCount: pedidosAgrupados.length,
              itemBuilder: (context, index) {
                final numeroPedido = pedidosAgrupados.keys.elementAt(index);
                final itensPedido = pedidosAgrupados[numeroPedido]!;
                final valorTotal = itensPedido.fold(0.0, (sum, item) => sum + item['preco'] * item['quantidade']);

                return ExpansionTile(
                  title: Text('Pedido #$numeroPedido'),
                  subtitle: Text('Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}'),
                  children: [
                    ...itensPedido.map((item) {
                      return ListTile(
                        leading: item['imagem'] != null && item['imagem'].isNotEmpty
                            ? (item['imagem'].startsWith('http')
                                ? Image.network(item['imagem'], width: 50, height: 50)
                                : Image.asset(item['imagem'], width: 50, height: 50))
                            : null,
                        title: Text(item['nome']),
                        subtitle: Text(item['descricao']),
                        trailing: Text('R\$ ${item['preco'].toStringAsFixed(2)}'),
                      );
                    }).toList(),
                    ListTile(
                      title: Text('Enviar nota fiscal por e-mail'),
                      trailing: Icon(Icons.email),
                      onTap: () async {
                        String emailUsuario = await widget.loginController.usuarioLogadoEmail();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nota fiscal enviada para o e-mail $emailUsuario.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: Color(0xFFFFD600),
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos📦'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}