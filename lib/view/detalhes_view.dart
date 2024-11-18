// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:get_it/get_it.dart';
import '../model/itens_model.dart';
import '../services/pedido_service.dart';
import '../controller/menu_controller.dart' as custom;

class DetalhesView extends StatefulWidget {
  const DetalhesView({super.key});

  @override
  State<DetalhesView> createState() => _DetalhesViewState();
}

class _DetalhesViewState extends State<DetalhesView> {
  int quantidade = 1; // Contador para a quantidade do prato
  final pedidoService = GetIt.I<PedidoService>(); // Acessando o serviço de pedidos
  final custom.MenuController _menuController = custom.MenuController(); // Instância do MenuController

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
              ImageNetwork(
                image: dados.foto,
                height: 200,
                width: screenWidth, // Usando a largura da tela para a imagem
                fitWeb: BoxFitWeb.cover, // A imagem cobre a largura com proporção mantida
                onLoading: const CircularProgressIndicator(
                  color: Colors.indigoAccent,
                ),
              ),
              SizedBox(height: 20),

              // Descrição do prato usando FutureBuilder
              FutureBuilder<String>(
                future: _menuController.itensCardapioDescricao(dados.nome),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar a descrição');
                  } else {
                    return ListTile(
                      title: Text(
                        'Descrição',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        snapshot.data ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                },
              ),

              SizedBox(height: 30),

              // Preço do prato usando FutureBuilder
              FutureBuilder<double>(
                future: _menuController.itensCardapioPreco(dados.nome),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar o preço');
                  } else {
                    return ListTile(
                      title: Text(
                        'Preço',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'R\$ ${snapshot.data?.toStringAsFixed(2) ?? ''}', // Exibindo o preço em formato monetário
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantidade++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 5),

              // Exibição do total com base na quantidade selecionada
              FutureBuilder<double>(
                future: _menuController.itensCardapioPreco(dados.nome),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar o preço');
                  } else {
                    double preco = snapshot.data ?? 0.0;
                    return Text(
                      'Total: R\$ ${(quantidade * preco).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),

              SizedBox(height: 20),

              // Botão de adicionar ao pedido
              ElevatedButton(
                onPressed: () {
                  // Adiciona o prato ao pedido usando o serviço
                  for (int i = 0; i < quantidade; i++) {
                    pedidoService.adicionarAoPedido(dados);
                  }

                  // Exibir um snackbar ou diálogo confirmando a adição
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Adicionado $quantidade ${dados.nome}(s) ao pedido!'),
                    ),
                  );

                  // Redireciona para a tela de pedidos
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PedidosView()), // Navegar para a tela de pedidos
                  );*/
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
