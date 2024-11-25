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

  // Cupons de desconto ativos
  bool lanche2024 = true;
  bool sobremesa2024 = true;

  @override
  void initState() {
    super.initState();
    verificarPedidoExistente();
  }

  Future<void> verificarPedidoExistente() async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(user.email);
        final pedidoDoc = await pedidoRef.get();

        if (pedidoDoc.exists) {
          String statusPedido = pedidoDoc['statusPedido'];
          if (statusPedido == 'novo pedido' ||
              statusPedido == 'aguardando pagamento') {
            setState(() {
              PedidoService().atualizarStatusPedido(context, statusPedido);
            });
          } else if (statusPedido == 'pagamento confirmado') {
            await registrarHistorico(user, pedidoDoc);
            setState(() {
              mensagemErro =
                  'Seu pedido foi finalizado e movido para o histórico.';
            });
          } else {
            setState(() {
              mensagemErro =
                  'Você não pode modificar um pedido com statusPedido "$statusPedido".';
            });
          }
        } else {
          int novoNumeroPedido =
              await pedidoService.obterProximoNumeroPedido(context);
          await pedidoRef.set({
            'numeroPedido': novoNumeroPedido,
            'statusPedido': 'novo pedido',
            'data': FieldValue.serverTimestamp(),
            'email': user.email,
          });
          if (mounted) {
            setState(() {
              PedidoService().atualizarStatusPedido(context, 'novo pedido');
            });
          }
        }
      } catch (e) {
        print('Erro ao verificar pedido existente: $e');
      }
    }
  }

  Future<void> registrarHistorico(User user, DocumentSnapshot pedidoDoc) async {
    final historicoRef = firestore
        .collection('pedidos')
        .doc(user.email)
        .collection('historico_pedidos');
    final itensSnapshot = await pedidoDoc.reference.collection('itens').get();
    final itensData = itensSnapshot.docs.map((doc) => doc.data()).toList();

    await historicoRef.add({
      'email': user.email,
      'uid': user.uid,
      'numeroPedido': pedidoDoc['numeroPedido'],
      'statusPedido': 'pedido finalizado',
      'itens': itensData,
      'data_hora': FieldValue.serverTimestamp(),
      if (pedidoDoc.data() != null) ...pedidoDoc.data() as Map<String, dynamic>,
    });

    await pedidoDoc.reference.delete();
  }

  Future<void> atualizarStatusPedido(String statusPedido) async {
    try {
      await pedidoService.atualizarStatusPedido(context, statusPedido);
    } catch (e) {
      debugPrint('Erro ao atualizar statusPedido do pedido: $e');
    }
  }

  Future<void> adicionarAoPedido(Prato prato, int quantidade) async {
    try {
      await pedidoService.adicionarAoPedido(prato, quantidade);
    } catch (e) {
      print('Erro ao adicionar item ao pedido: $e');
    }
  }

  Future<void> removerDoPedido(Prato prato) async {
    try {
      await pedidoService.removerDoPedido(prato);
    } catch (e) {
      print('Erro ao remover item do pedido: $e');
    }
  }

  void confirmarRemoverItem(Prato prato) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remover Item'),
        content:
            Text('Tem certeza que deseja remover "${prato.nome}" do pedido?'),
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
                      content: Text('item removido.❌'),
                      duration: Duration(seconds: 1),
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

  Future<void> aplicarCodigoPromocional(String codigo) async {
    try {
      pedidoService.aplicarCodigoPromocional(context, codigo);
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: pedidoService.buscarItensPedidoStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar itens do carrinho.'));
          }
          List<Map<String, dynamic>>? itensCarrinho = snapshot.data;

          if (itensCarrinho == null || itensCarrinho.isEmpty) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  content: Text(
                      'Se o seu pedido já foi pago ✅, estamos cuidando dele 📦 e você será notificado em breve ⏳. Confira o status na tela de pedidos'),
                ),
              );
            });
            return Center(
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
            );
          }

          itensCarrinho = snapshot.data!;

          // Verificação e ajuste da quantidade de itens aplicados como cupom
          for (var item in itensCarrinho) {
            if (item['cupom'] == true && item['quantidade'] > 1) {
              item['quantidade'] = 1;
            }
          }

          double totalPedido = calcularTotalPedido(itensCarrinho);
          double totalComGorjeta = incluirGorjeta
              ? totalPedido * (1 + (percentualGorjeta / 100))
              : totalPedido;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: itensCarrinho.length,
                  itemBuilder: (context, index) {
                    var item = itensCarrinho![index];
                    return ListTile(
                      leading: item['imagem'] != null
                          ? Image.network(item['imagem'])
                          : null,
                      title: Text(
                        item['nome'] ?? 'Nome não disponível',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item['descricao'] ?? 'Descrição não disponível'}\nPreço: R\$ ${(item['preco']?.toDouble() ?? 0.0).toStringAsFixed(2)} (cada)\nQuantidade: ${item['quantidade'] ?? 0}',
                        style: TextStyle(fontSize: 11),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () async {
                              if (item['quantidade'] > 1) {
                                await adicionarAoPedido(
                                  Prato(
                                    nome: item['nome'] ?? '',
                                    descricao: item['descricao'] ?? '',
                                    preco: item['preco']?.toDouble() ?? 0.0,
                                    imagem: item['imagem'] ?? '',
                                    resumo: item['resumo'] ?? '',
                                    quantidade:
                                        item['quantidade']?.toInt() ?? 0,
                                    itemPacote: item['itemPacote'] ?? '',
                                    cupom: item['cupom'] ?? false,
                                    categoria: item['categoria'] ?? '',
                                  ),
                                  -1,
                                );
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Colors.red.withOpacity(0.5),
                                    content: Text('Quantidade subtraída.➖'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                confirmarRemoverItem(
                                  Prato(
                                    nome: item['nome'] ?? '',
                                    descricao: item['descricao'] ?? '',
                                    preco: item['preco']?.toDouble() ?? 0.0,
                                    imagem: item['imagem'] ?? '',
                                    resumo: item['resumo'] ?? '',
                                    quantidade:
                                        item['quantidade']?.toInt() ?? 0,
                                    itemPacote: item['itemPacote'] ?? '',
                                    cupom: item['cupom'] ?? false,
                                    categoria: item['categoria'] ?? '',
                                  ),
                                );
                              }
                              await pedidoService
                                  .verificarItemAdicionado(item['nome']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: item['cupom'] == true
                                ? null
                                : () async {
                                    await adicionarAoPedido(
                                      Prato(
                                        nome: item['nome'] ?? '',
                                        descricao: item['descricao'] ?? '',
                                        preco: item['preco']?.toDouble() ?? 0.0,
                                        imagem: item['imagem'] ?? '',
                                        resumo: item['resumo'] ?? '',
                                        quantidade:
                                            item['quantidade']?.toInt() ?? 0,
                                        itemPacote: item['itemPacote'] ?? '',
                                        cupom: item['cupom'] ?? false,
                                        categoria: item['categoria'] ?? '',
                                      ),
                                      1,
                                    );
                                    await pedidoService
                                        .verificarItemAdicionado(item['nome']);
                                    setState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            Colors.green.withOpacity(0.5),
                                        content:
                                            Text('Quantidade adicionada.➕'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              confirmarRemoverItem(
                                Prato(
                                  nome: item['nome'] ?? '',
                                  descricao: item['descricao'] ?? '',
                                  preco: item['preco']?.toDouble() ?? 0.0,
                                  imagem: item['imagem'] ?? '',
                                  resumo: item['resumo'] ?? '',
                                  quantidade: item['quantidade']?.toInt() ?? 0,
                                  itemPacote: item['itemPacote'] ?? '',
                                  cupom: item['cupom'] ?? false,
                                  categoria: item['categoria'] ?? '',
                                ),
                              );
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
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
                            if (RegExp(r'^[0-9]*[.,]?[0-9]*$')
                                .hasMatch(value)) {
                              mensagemErro = '';
                              double? novoPercentual =
                                  double.tryParse(value.replaceAll(',', '.'));
                              if (novoPercentual != null &&
                                  novoPercentual > 0) {
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
                      'Total: R\$ ${totalPedido.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (incluirGorjeta) ...[
                      Text(
                        'Valor da gorjeta: R\$ ${(totalComGorjeta - totalPedido).toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      Text(
                        'Total com ${percentualGorjeta.toStringAsFixed(1)}% de gorjeta: R\$ ${totalComGorjeta.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Agradecemos, seu incentivo é muito apreciado! Tanto ao tamanho do sorriso!',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      // Adiciona um emoji de sorriso ao final do texto se a gorgeja for maior o sorriso cresce conforme o valor
                      Center(
                        child: Text(
                          '😊',
                          style: TextStyle(
                            fontSize: percentualGorjeta * 2 > 100
                                ? 100
                                : percentualGorjeta * 2,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        'Total sem gorjeta: R\$ ${totalPedido.toStringAsFixed(2)}\n  ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await atualizarStatusPedido('aguardando pagamento');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            content: Text(
                                '💳 Status: aguardando pagamento 💵\nSeu pedido será separado após o pagamento!'),
                          ),
                        );
                        Navigator.pushNamed(context, 'pagamento',
                            arguments: totalComGorjeta);
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
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
          );
        },
      ),
    );
  }

  double calcularTotalPedido(List<Map<String, dynamic>> itensCarrinho) {
    double total = 0;
    for (var item in itensCarrinho) {
      total += (item['quantidade']?.toDouble() ?? 0) *
          (item['preco']?.toDouble() ?? 0.0);
    }
    return total;
  }
}
