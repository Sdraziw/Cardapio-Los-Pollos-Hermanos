import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pedido_service.dart';
import '../model/itens_model.dart';
import 'package:los_pollos_hermanos/view/pagamento_view.dart';// Import the PagamentoView class

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

  Future<int> obterProximoNumeroPedido() async {
    DocumentReference docRef =
        firestore.collection('config').doc('numeroPedido');
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      int numeroPedido = doc['numero'] ?? 0;
      return numeroPedido + 1;
    } else {
      return 1;
    }
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

          if (itensCarrinho.isEmpty) {
            return Center(child: Text('Seu carrinho está vazio.'));
          }

          double totalPedido = calcularTotalPedido(itensCarrinho);
          double totalComGorjeta = incluirGorjeta
              ? totalPedido * (1 + (percentualGorjeta / 100))
              : totalPedido;

          return Column(
            children: [
              FutureBuilder<int?>(
                future: pedidoService.buscarNumeroPedido(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  int? numeroPedido = snapshot.data;
                  if (numeroPedido == null) {
                    return Center(
                        child: Text('Erro ao carregar o número do pedido.'));
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Número do Pedido: $numeroPedido',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: itensCarrinho.length,
                  itemBuilder: (context, index) {
                    var item = itensCarrinho[index];
                    return ListTile(
                      leading: item['imagem'] != null
                          ? Image.network(item['imagem'])
                          : null,
                      title: Text(item['nome']),
                      subtitle: Text(
                          '${item['descricao']}\nQuantidade: ${item['quantidade']}'),
                      trailing: Text('R\$ ${item['preco'].toStringAsFixed(2)}'),
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
                      subtitle: Text("A gorjeta não é obrigatória."),
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
                        // Atualizar o status dos pedidos para "preparando"
                        await pedidoService.atualizarStatusPedido('preparando');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.black.withOpacity(0.5),
                            content: Text(
                                '💳 Status: aguardando pagamento 💵\nSeu pedido será separado após o pagamento!'),
                          ),
                        );
                        // Redireciona para a tela de pagamento
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PagamentoView()), // Navegar para a tela de pagamento
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        textStyle: TextStyle(fontSize: 18),
                        backgroundColor: Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Finalizar Pedido'),
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
        status: 'aguardando pagamento',
        cupom: false,
        categoria: 'Sobremesas',
      );
      setState(() {
        pedidoService.adicionarAoPedido(pratoGratuito, 1);
        mensagemCodigo =
            'Código SOBREMESA2024 aplicado com sucesso! Sorvete Negresco adicionado ao pedido.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            content: Text(
                '🌵🌕👻🍦 SOBREMESA2024🦅🌕🌵 Aplicado com sucesso.'), //futuramente colocar o expirado
          ),
        );
      });
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻LANCHE2024 🍔- Cê é LOCO cachoeira",
        preco: 0.0,
        imagem: "lib/images/slc que imagem.jpeg",
        descricao: "Pão de hamburguer, Frango Parrudo Empanado, Molho Barbecue",
        resumo: 'Lanche parrudo | 200g 🍔',
        quantidade: 1,
        status: 'aguardando pagamento',
        cupom: false,
        categoria: 'Lanches',
      );
      setState(() {
        pedidoService.adicionarAoPedido(pratoGratuito, 1);
        mensagemCodigo =
            'Código LANCHE2024 aplicado com sucesso! Lanche adicionado ao pedido.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            content: Text(
                '🌵🌞🤤🍔 LANCHE2024🌵🌞 Aplicado com sucesso.'), //futuramente colocar o expirado
          ),
        );
      });
    } else {
      setState(() {
        mensagemCodigo = 'Código promocional inválido.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            content: Text(
                '😕 Código promocional inválido ou já aplicado.'), //futuramente colocar o expirado
          ),
        );
      });
    }
  }
}
