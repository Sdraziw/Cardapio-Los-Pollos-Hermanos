import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:los_pollos_hermanos/services/pedido_service.dart';

class OpcoesPagamentoView extends StatelessWidget {
  final PedidoService pedidoService = GetIt.I<PedidoService>();

  @override
  Widget build(BuildContext context) {
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
                await pedidoService.registrarPagamento(context, numeroPedido, 'Pix');

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
                  Icon(Icons.payment, size: 60, color: Colors.blue), // Ícone de Pix
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
                // Adicionar o código para pagamento via Cartão de Crédito
                await pedidoService.registrarPagamento(context, numeroPedido, 'Cartão de Crédito');

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Pagamento via Cartão de Crédito confirmado!\nAguarde, seu pedido está sendo preparado!\nNúmero do pedido: $numeroPedido'),
                  ),
                );
                Navigator.pushNamed(context, 'menu');
              },
              child: Column(
                children: [
                  Icon(Icons.credit_card, size: 60, color: Colors.green), // Ícone de Cartão de Crédito
                  SizedBox(height: 10),
                  Text('Pagamento via Cartão de Crédito', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}