import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/pedido_service.dart';
import '../model/itens_model.dart';

class CarrinhoView extends StatefulWidget {
  const CarrinhoView({super.key});

  @override
  CarrinhoViewState createState() => CarrinhoViewState();
}

class CarrinhoViewState extends State<CarrinhoView> {
  final pedidoService = GetIt.I<PedidoService>();
  bool incluirGorjeta = false;
  double percentualGorjeta = 10.0;
  String mensagemErro = '';
  String codigoPromocional = '';
  String mensagemCodigo = '';
  bool lanche2024 = true;
  bool sobremesa2024 = true;

  @override
  Widget build(BuildContext context) {
    double totalPedido = calcularTotalPedido();
    double totalComGorjeta = incluirGorjeta
        ? totalPedido * (1 + (percentualGorjeta / 100))
        : totalPedido;

    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Carrinho'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: pedidoService.pedidos.length,
              itemBuilder: (context, index) {
                final prato = pedidoService.pedidos[index];
                return ListTile(
                  leading: Image.network(prato.foto, width: 50, height: 50),
                  title: Text(prato.nome),
                  subtitle: Text(
                      'Preço: ${prato.preco}\nQuantidade: ${prato.quantidade}\nStatus: ${prato.status}'), // Mostra o status
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (prato.quantidade > 1) {
                              prato.quantidade--;
                            } else {
                              confirmarRemoverItem(prato);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            prato.quantidade++;
                          });
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
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Total: R\$ ${totalPedido.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (incluirGorjeta)
                  Text(
                    'Total com ${percentualGorjeta.toStringAsFixed(1)}% de gorjeta: R\$ ${totalComGorjeta.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Atualizar o status dos pedidos para "Pago"
                    for (var prato in pedidoService.pedidos) {
                      prato.status = "Pago 💵 💰"; // Atualiza o status
                    }
                    Navigator.pushNamed(context, 'pagamento',
                        arguments: totalComGorjeta);
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

  double calcularTotalPedido() {
    double total = 0;
    for (var item in pedidoService.pedidos) {
      total += item.quantidade *
          double.parse(item.preco.replaceAll('R\$ ', '').replaceAll(',', '.'));
    }
    return total;
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
            onPressed: () {
              setState(() {
                pedidoService.removerDoPedido(prato);
              });
              Navigator.of(context).pop();
            },
            child: Text('Remover'),
          ),
        ],
      ),
    );
  }

  void aplicarCodigoPromocional(String codigo) {
    Prato pratoGratuito;

    if ((codigo == 'SOBREMESA2024') && sobremesa2024 == true) {
      sobremesa2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻SOBREMESA2024 🍦- Sorvete Negresco",
        preco: "R\$ 0,00",
        foto: "lib/images/ice-cream.webp",
        descricao:
            "Sorvete Negresco é feito de leite condensado, leite, biscoitos Negresco, essência de baunilha, ovos, açúcar e creme de leite. Bem simples e delicioso! 🍦",
        resumo: 'Casquinha Recheada e Massa Baunilha',
      );
      setState(() {
        pedidoService.adicionarAoPedido(pratoGratuito); // Aqui foi corrigido
        mensagemCodigo =
            'Código sobremesa2024 aplicado com sucesso! Sorvete Negresco adicionado ao pedido.';
      });
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻LANCHE2024 🍔- Cê é LOCO cachoeira",
        preco:
            "R\$ 0,00", // Aqui assumimos que o combo também é gratuito com o código promocional
        foto: "lib/images/slc que foto.jpeg",
        descricao: "Pão de hamburguer, Frango Parrudo Empanado, Molho Barbecue",
        resumo: 'Lanche parrudo | 200g 🍔',
      );
      setState(() {
        pedidoService.adicionarAoPedido(pratoGratuito); // Aqui foi corrigido
        mensagemCodigo =
            'Código LANCHE2024 aplicado com sucesso! Lanche adicionado ao pedido.';
      });
    } else {
      setState(() {
        mensagemCodigo = 'Código promocional inválido.';
      });
    }
  }
}
