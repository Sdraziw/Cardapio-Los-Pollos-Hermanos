import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../model/itens_model.dart';
import '../services/pedido_service.dart';
import '../controller/menu_controller.dart' as custom;
import '../view/menu_view.dart';

class DetalhesView extends StatefulWidget {
  const DetalhesView({super.key});

  @override
  State<DetalhesView> createState() => _DetalhesViewState();
}

class _DetalhesViewState extends State<DetalhesView> {
  int quantidade = 1; // Contador para a quantidade do prato
  final pedidoService =
      GetIt.I<PedidoService>(); // Acessando o serviço de pedidos
  final custom.MenuController menuController =
      custom.MenuController(); // Instância do MenuController

  @override
  Widget build(BuildContext context) {
    // Recuperar os dados do Prato
    Prato dados = ModalRoute.of(context)!.settings.arguments as Prato;

    // Pega a largura da tela
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(dados.nome),
        backgroundColor: Color(0xFFFFD600), // Mantendo a cor da AppBar
      ),
      body: Container(
        color: Colors.white, // Fundo alterado para amarelo
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              // Imagem do prato
              Image.network(
                dados.imagem,
                height: 200,
                width: screenWidth, // Usando a largura da tela para a imagem
                fit: BoxFit
                    .cover, // A imagem cobre a largura com proporção mantida
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                        color: Colors.indigoAccent,
                      ),
                    );
                  }
                },
              ),
              SizedBox(height: 20),

              // Descrição do prato usando FutureBuilder
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('itens_cardapio')
                    .doc(dados.nome)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar a descrição');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('Descrição não encontrada');
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        'Descrição',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['descricao'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Resumo',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            data['resumo'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 30),

              // Preço do prato usando FutureBuilder
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('itens_cardapio')
                    .doc(dados.nome)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar o preço');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('Preço não encontrado');
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    double preco = (data['preco'] as num).toDouble();
                    return ListTile(
                      title: Text(
                        'Preço',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'R\$ ${preco.toStringAsFixed(2)}', // Exibindo o preço em formato monetário
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 20),

              // Contador de quantidade
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quantidade: $quantidade',
                    style: TextStyle(fontSize: 20),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (quantidade > 1) {
                              quantidade--;
                              /*ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Quantidade diminuída para $quantidade'),
                                ),
                              );*/
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantidade++;
                            /*ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Quantidade aumentada para $quantidade'),
                              ),
                            );*/
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 5),

              // Exibição do total com base na quantidade selecionada
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('itens_cardapio')
                    .doc(dados.nome)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar o preço');
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('Preço não encontrado');
                  } else {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    double preco = (data['preco'] as num).toDouble();
                    return Text(
                      'Total: R\$ ${(quantidade * preco).toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),

              SizedBox(height: 20),

              // Botão de adicionar ao pedido
              ElevatedButton(
                onPressed: () async {
                  // Adiciona o prato ao pedido usando o serviço
                  await pedidoService.adicionarAoPedido(
                      dados, quantidade, context);

                  /*// Exibir um snackbar ou diálogo confirmando a adição e atualização dos itens no pedido se houver um item com mesmo nome para mesmo usuário no mesmo pedido consultando se há um pedido do usuário logado
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Item adicionado ao pedido'),
                      duration: Duration(seconds: 1),
                    ),
                  );*/

                  // verificarOuGerarNumeroPedido é uma função que verifica se o usuário já possui um pedido em andamento, caso não tenha, gera um novo número de pedido
                  String verificarOuGerarNumeroPedido =
                      await pedidoService.verificarOuGerarNumeroPedido();

                  // Atualiza a lista de itens do pedido no carrinho passando como parâmetro o nome do prato
                  await pedidoService.buscarItensPedidoPorStatus(
                      verificarOuGerarNumeroPedido, 'preparando');
                  // Atualiza o status do pedido
                  await pedidoService.atualizarStatusPedido(
                      context, verificarOuGerarNumeroPedido, 'preparando');
                  // Atualiza o número do pedido
                  await pedidoService.buscarNumeroPedido();

                  // Redireciona para a tela do carrinho
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MenuView()), // Navegar para a tela do menu
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(300, 50),
                  foregroundColor: Colors.black,
                  backgroundColor: Color(0xFFFFD600), // Cor do botão
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Adicionar ao Pedido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
