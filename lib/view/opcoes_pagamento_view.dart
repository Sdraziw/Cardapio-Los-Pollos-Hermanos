import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/pedido_service.dart'; // Importe o PedidoService

class OpcoesPagamentoView extends StatelessWidget {
  const OpcoesPagamentoView({super.key});

  @override
  Widget build(BuildContext context) {
    final pedidoService =
        GetIt.I<PedidoService>(); // Acesse o serviço de pedidos

    return Scaffold(
      appBar: AppBar(
        title: Text('Opções de Pagamento'),
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone e botão para pagamento via Pix
            GestureDetector(
              onTap: () async {
                String numeroPedido = await pedidoService.gerarNumeroPedido();
                // Adicionar o código para pagamento via Pix
                await pedidoService.registrarPagamento(numeroPedido, 'Pix');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Pagamento via Pix confirmado! 💰\nAguarde, seu pedido está sendo preparado!⌛\nNúmero do pedido: $numeroPedido'),
                  ),
                );
                Navigator.pushNamed(context, 'menu');
              },
              child: Column(
                children: [
                  Icon(Icons.payment,
                      size: 60, color: Colors.blue), // Ícone de Pix
                  SizedBox(height: 10),
                  Text('Pagamento via Pix', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            SizedBox(height: 40), // Espaçamento entre opções
            // Ícone e botão para pagamento via cartão de crédito
            GestureDetector(
              onTap: () async {
                String numeroPedido = await pedidoService.gerarNumeroPedido();
                // Adicionar o código para pagamento via Pix
                await pedidoService.registrarPagamento(numeroPedido, 'Cartão de Crédito');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Pagamento via Cartão de Crédito confirmado!\nAguarde, seu pedido está sendo preparado!\nNúmero do pedido: $numeroPedido'),
                  ),
                );
                // Redirecionar para a tela de opções de pagamento ou outra
                Navigator.pushNamed(context, 'menu');
              },
              child: Column(
                children: [
                  Icon(Icons.credit_card,
                      size: 60,
                      color: Colors.green), // Ícone de cartão de crédito
                  SizedBox(height: 10),
                  Text('Pagamento via Cartão de Crédito',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
