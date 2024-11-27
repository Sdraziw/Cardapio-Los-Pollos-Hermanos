import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import '../services/pedido_service.dart';
import '../model/itens_model.dart';

class CarrinhoView extends StatefulWidget {
  const CarrinhoView({super.key});

  @override
  CarrinhoViewState createState() => CarrinhoViewState();
}

class CarrinhoViewState extends State<CarrinhoView> {
  final pedidoService = GetIt.I<PedidoService>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool incluirGorjeta = false;
  double percentualGorjeta = 10.0;
  String mensagemErro = '';
  String codigoPromocional = '';
  String mensagemCodigo = '';
  List<Prato> itensCarrinho = [];

  // Cupons de desconto ativos
  bool lanche2024 = true;
  bool sobremesa2024 = true;

  String verificarOuGerarNumeroPedido = '';

  @override
  void initState() {
    super.initState();
    pedidoService.verificarOuGerarNumeroPedido().then((numeroPedido) {
      setState(() {
        verificarOuGerarNumeroPedido = numeroPedido;
        carregarItensCarrinho();
      });
    });
  }
  
  void carregarItensCarrinho() async {
    try {
      final itens = await pedidoService.buscarItensPedidoPorStatus(verificarOuGerarNumeroPedido, 'preparando');
      setState(() {
        itensCarrinho = itens.map((item) => Prato.fromMap(item)).toList();
      });
    } catch (e) {
      print('Erro ao carregar itens do carrinho: $e');
    }
  }

  Future<void> adicionarAoPedido(Prato prato, int quantidade) async {
    try {
      await pedidoService.adicionarAoPedido(prato, quantidade, context);
      carregarItensCarrinho();
    } catch (e) {
      print('Erro ao adicionar item ao pedido: $e');
    }
  }

  Future<void> removerDoPedido(Prato prato) async {
    try {
      await pedidoService.removerDoPedido(prato);
      carregarItensCarrinho();
    } catch (e) {
      print('Erro ao remover item do pedido: $e');
    }
  }

  void confirmarRemoverItem(Prato prato) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Item'),
        content: Text('Tem certeza que deseja remover "${prato.nome}" do pedido?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await removerDoPedido(prato);
              setState(() {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.purple.withOpacity(0.5),
                      content: Text('Item removido.❌'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      padding: EdgeInsets.all(10.0),
                    ),
                  );
                });
              });
              Navigator.of(context).pop();
            },
            child: Text('Remover'),
          ),
        ],
      ),
    );
  }

  Future<String> atualizarstatus(
      context, String numeroPedido, String status) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
      final pedidoDoc = await pedidoRef.get();
      if (pedidoDoc.exists) {
        final pedidoData = pedidoDoc.data();
        if (pedidoData != null && pedidoData['email'] == user.email) {
          await pedidoRef.update({
            'status': status,
            'dataAtualizacao': FieldValue.serverTimestamp(),
            'numeroPedido': pedidoData['numeroPedido'],
            'dataCriacao': pedidoData['dataCriacao'],
            'email': user.email,
          });
          return status;
        } else if (pedidoData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              content: Text(
                  'Else if: Erro ao atualizar status do pedido. #${status}'),
            ),
          );
          return status;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              content: Text('Erro ao atualizar status do pedido. #${status}'),
            ),
          );
          return status;
        }
      }
    }
    return '0';
  }

  Future<void> aplicarCodigoPromocional(String codigo) async {
    try {
      await pedidoService.aplicarCodigoPromocional(context, codigo);
      carregarItensCarrinho();
    } catch (e) {
      print('Erro ao aplicar código promocional: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Carrinho'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: itensCarrinho.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Seu carrinho está vazio.'),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'historico');
                    },
                    icon: Icon(Icons.receipt_long),
                    label: Text('Pedidos'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: itensCarrinho.length,
                    itemBuilder: (context, index) {
                      final prato = itensCarrinho[index];
                      return ListTile(
                        leading: Image.network(prato.imagem),
                        title: Text(
                          prato.nome,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Quantidade: ${prato.quantidade}\nPreço: R\$ ${prato.preco.toStringAsFixed(2)} (cada)',
                          style: TextStyle(fontSize: 11),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () async {
                                if (prato.quantidade > 1) {
                                  await adicionarAoPedido(prato, -1);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.red.withOpacity(0.5),
                                      content: Text('Quantidade subtraída.➖'),
                                      duration: Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                      padding: EdgeInsets.all(10.0),
                                    ),
                                  );
                                } else {
                                  confirmarRemoverItem(prato);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: prato.cupom ? null : () async {
                                await adicionarAoPedido(prato, 1);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.green.withOpacity(0.5),
                                    content: Text('Quantidade adicionada.➕'),
                                    duration: Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                    padding: EdgeInsets.all(10.0),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                confirmarRemoverItem(prato);
                              },
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Código Promocional',
                          hintText: 'Digite o código promocional',
                        ),
                        onChanged: (value) {
                          setState(() {
                            codigoPromocional = value;
                          });
                        },
                      ),
                      if (mensagemCodigo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            mensagemCodigo,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          aplicarCodigoPromocional(codigoPromocional);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Color(0xFFFFD600),
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Aplicar Código Promocional'),
                      ),
                      CheckboxListTile(
                        title: Text("Incluir gorjeta de $percentualGorjeta%"),
                        subtitle: Text(
                          "A gorjeta não é obrigatória.\nSe desejar, você pode alterar o percentual.",
                          style: TextStyle(fontSize: 9, color: Colors.red),
                        ),
                        value: incluirGorjeta,
                        onChanged: (bool? value) {
                          setState(() {
                            incluirGorjeta = value!;
                          });
                        },
                      ),
                      if (incluirGorjeta) ...[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Alterar percentual da gorjeta',
                            hintText: 'Digite o percentual da gorjeta',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              if (RegExp(r'^[0-9]*[.,]?[0-9]*$').hasMatch(value)) {
                                mensagemErro = '';
                                double? novoPercentual =
                                    double.tryParse(value.replaceAll(',', '.'));
                                if (novoPercentual != null && novoPercentual > 0) {
                                  percentualGorjeta = novoPercentual;
                                } else {
                                  percentualGorjeta = 10.0;
                                }
                              } else {
                                mensagemErro = 'Insira um valor válido.';
                              }
                            });
                          },
                        ),
                        if (mensagemErro.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              mensagemErro,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                      SizedBox(height: 10),
                      Text(
                        'Total: R\$ ${calcularTotalPedido(itensCarrinho).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      if (incluirGorjeta) ...[
                        Text(
                          'Valor da gorjeta: R\$ ${(calcularTotalPedido(itensCarrinho) * (percentualGorjeta / 100)).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        Text(
                          'Total com ${percentualGorjeta.toStringAsFixed(1)}% de gorjeta: R\$ ${(calcularTotalPedido(itensCarrinho) * (1 + (percentualGorjeta / 100))).toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Agradecemos, seu incentivo é muito apreciado! Tanto ao tamanho do sorriso!',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        Center(
                          child: Text(
                            '😊',
                            style: TextStyle(
                              fontSize: percentualGorjeta * 2 > 100 ? 100 : percentualGorjeta * 2,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ] else
                        Text(
                          'Total sem gorjeta: R\$ ${calcularTotalPedido(itensCarrinho).toStringAsFixed(2)}\n  ',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await pedidoService.atualizarStatusPedido(context, verificarOuGerarNumeroPedido,'preparando');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.black.withOpacity(0.5),
                              content: Text('💳 Status: preparando e aguardando pagamento 💵\nSeu pedido será separado após o pagamento!'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              padding: EdgeInsets.all(10.0),
                            ),
                          );
                          Navigator.pushNamed(context, 'pagamento', arguments: calcularTotalPedido(itensCarrinho) * (1 + (percentualGorjeta / 100)));
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                          textStyle: TextStyle(fontSize: 18),
                          backgroundColor: Color(0xFFFFD600),
                          foregroundColor: Colors.black,
                        ),
                        child: Text('Efetuar Pagamento'),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  double calcularTotalPedido(List<Prato> itensCarrinho) {
    double total = 0;
    for (var item in itensCarrinho) {
      total += item.quantidade * item.preco;
    }
    return total;
  }
}