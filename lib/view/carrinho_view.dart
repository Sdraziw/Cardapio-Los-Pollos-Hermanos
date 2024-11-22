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
  bool lanche2024 = true;
  bool sobremesa2024 = true;

  @override
  void initState() {
    super.initState();
    verificarPedidoExistente();
  }

  // Verifica se já existe um pedido em andamento para o usuário logado e cria um novo pedido se não existir um pedido em andamento
  Future<void> verificarPedidoExistente() async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(user.uid);
        final pedidoDoc = await pedidoRef.get();

        if (pedidoDoc.exists) {
          String statusPedido = pedidoDoc['status'];
          if (statusPedido == 'novo pedido' || statusPedido == 'aguardando pagamento') {
            setState(() {
              // Atualiza a tela com o pedido existente de status novo pedido ou aguardando pagamento
              PedidoService().atualizarStatusPedido(statusPedido);
            });
          } else if (statusPedido == 'pagamento confirmado') {
            // Mantém o pedido com status "pagamento confirmado" e cria um novo pedido
            int novoNumeroPedido = await pedidoService.obterProximoNumeroPedido();
            await firestore.collection('pedidos').add({
              'uid': user.uid,
              'numero_pedido': novoNumeroPedido,
              'status': 'novo pedido',
              'data': FieldValue.serverTimestamp(),
            });
            setState(() {
              // Atualiza a tela com o novo pedido criado
              PedidoService().atualizarStatusPedido('novo pedido');
            });
          } else {
            // Mantém o pedido com status diferente de "novo pedido" ou "aguardando pagamento"
            setState(() {
              mensagemErro = 'Você não pode modificar um pedido com status "$statusPedido".';
            });
          }
        } else {
          int novoNumeroPedido = await PedidoService().obterProximoNumeroPedido();
          await pedidoRef.set({
            'numero_pedido': novoNumeroPedido,
            'status': 'novo pedido',
            'data': FieldValue.serverTimestamp(),
          });
          setState(() {
            // Atualiza a tela com o novo pedido criado
            PedidoService().atualizarStatusPedido('novo pedido');
          });
        }
      } catch (e) {
        print('Erro ao verificar pedido existente: $e');
      }
    }
  }

  Future<void> obterProximoNumeroPedido(double novoNumeroPedido) async {
    try {
      await pedidoService.obterProximoNumeroPedido();
    } catch (e) {
      debugPrint('Erro ao obter o proximo numero do pedido: $e');
    }
  }

  Future<void> atualizarStatusPedido(String status) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        await pedidoService.atualizarStatusPedido(status);
      } catch (e) {
        print('Erro ao atualizar status do pedido: $e');
      }
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

  void aplicarCodigoPromocional(String codigo) {
    Prato pratoGratuito;

    if ((codigo == 'SOBREMESA2024') && sobremesa2024 == true) {
      sobremesa2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻SOBREMESA2024 🍦- Sorvete Negresco",
        preco: 0.0,
        imagem: "lib/images/ice-cream.webp",
        descricao:
            "Sorvete Negresco é feito de leite condensado, leite, biscoitos Negresco, essência de baunilha, ovos, açúcar e creme de leite. Bem simples e delicioso! 🍦",
        resumo: 'Casquinha Recheada e Massa Baunilha',
        quantidade: 1,
        item_pacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Sobremesas',
      );
      setState(() {
        adicionarAoPedido(pratoGratuito, 1);
        mensagemCodigo =
            'Código SOBREMESA2024 aplicado com sucesso! Sorvete Negresco adicionado ao pedido.';
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.withOpacity(0.5),
              content: Text(
                  '🌵🌕👻🍦 SOBREMESA2024🦅🌕🌵 Aplicado com sucesso.'), //futuramente colocar o expirado
            ),
          );
        });
      });
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻LANCHE2024 🍔- Cê é LOCO cachoeira",
        preco: 0.0,
        imagem: 'lib/images/promo_image.png',
        descricao: "Pão de hamburguer, Frango Parrudo Empanado, Molho Barbecue",
        resumo: 'Lanche parrudo | 200g 🍔',
        quantidade: 1,
        item_pacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Lanches',
      );
      setState(() {
        adicionarAoPedido(pratoGratuito, 1);
        mensagemCodigo =
            'Código LANCHE2024 aplicado com sucesso! Lanche adicionado ao pedido.';
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green.withOpacity(0.5),
              content: Text(
                  '🌵🌞🤤🍔 LANCHE2024🌵🌞 Aplicado com sucesso.'), //futuramente colocar o expirado
            ),
          );
        });
      });
    } else {
      setState(() {
        mensagemCodigo = 'Código promocional inválido.';
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              content: Text(
                  '😕 Código promocional inválido ou já aplicado.'), //futuramente colocar o expirado
            ),
          );
        });
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Carrinho'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: pedidoService.buscarItensPedido(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          List<Map<String, dynamic>> itensCarrinho = snapshot.data!;

          // Verificação e ajuste da quantidade de itens aplicados como cupom
          for (var item in itensCarrinho) {
            if (item['cupom'] == true && item['quantidade'] > 1) {
              item['quantidade'] = 1;
            }
          }

          // Verificação de pedido com status de novo pedido e cupom igual a true
          bool temCupom = itensCarrinho.any((item) => item['cupom'] == true);
          bool temNovoPedido = itensCarrinho.any((item) => item['status'] == 'novo pedido');

          if (temCupom && temNovoPedido) {
            for (var item in itensCarrinho) {
              if (item['cupom'] == true) {
                item['quantidade'] = 1;
              }
            }
          }

          if (itensCarrinho.isEmpty) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  content: Text(
                      'Se o seu pedido foi pago, ele está sendo separado e será notificado em breve.\nCaso já tenha realizado o pagamento e ainda não tenha sido notificado, aguarde, pois a notificação será enviada em breve.\nPara mais detalhes, verifique o status do pedido na tela de pedidos.'),
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
                    var item = itensCarrinho[index];
                    return ListTile(
                      leading: item['imagem'] != null
                          ? Image.network(item['imagem'])
                          : null,
                      title: Text(item['nome'] ?? 'Nome não disponível'),
                      subtitle: Text(
                          '${item['descricao'] ?? 'Descrição não disponível'}\nQuantidade: ${item['quantidade'] ?? 0}\nPreço: R\$ ${(item['preco'] ?? 0.0).toStringAsFixed(2)}'),
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
                                    preco: item['preco'] ?? 0.0,
                                    imagem: item['imagem'] ?? '',
                                    resumo: item['resumo'] ?? '',
                                    categoria: item['categoria'] ?? '',
                                    item_pacote: item['item_pacote'] ?? '',
                                  ),
                                  -1,
                                );
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.red.withOpacity(0.5),
                                    content: Text('Quantidade subtraída.➖'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              } else {
                                confirmarRemoverItem(
                                  Prato(
                                    nome: item['nome'] ?? '',
                                    descricao: item['descricao'] ?? '',
                                    preco: item['preco'] ?? 0.0,
                                    imagem: item['imagem'] ?? '',
                                    resumo: item['resumo'] ?? '',
                                    categoria: item['categoria'] ?? '',
                                    item_pacote: item['item_pacote'] ?? '',
                                  ),
                                );
                              }
                              await pedidoService.verificarItemAdicionado(item['nome']);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: item['cupom'] == true ? null : () async { // Adicionando a condição para não permitir adicionar mais de um item com cupom
                              await adicionarAoPedido(
                                Prato(
                                  nome: item['nome'] ?? '',
                                  descricao: item['descricao'] ?? '',
                                  preco: item['preco'] ?? 0.0,
                                  imagem: item['imagem'] ?? '',
                                  resumo: item['resumo'] ?? '',
                                  categoria: item['categoria'] ?? '',
                                  item_pacote: item['item_pacote'] ?? '',
                                ),
                                1,
                              );
                              await pedidoService.verificarItemAdicionado(item['nome']);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.green.withOpacity(0.5),
                                  content: Text('Quantidade adicionada.➕'),
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
                                  preco: item['preco'] ?? 0.0,
                                  imagem: item['imagem'] ?? '',
                                  resumo: item['resumo'] ?? '',
                                  categoria: item['categoria'] ?? '',
                                  item_pacote: item['item_pacote'] ?? '',
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
                      subtitle: Text("A gorjeta não é obrigatória."
                      ,),
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
                    if (incluirGorjeta)
                      Text(
                        'Total com ${percentualGorjeta.toStringAsFixed(1)}% de gorjeta: R\$ ${totalComGorjeta.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
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
      total += item['quantidade'] * item['preco'];
    }
    return total;
  }
}
