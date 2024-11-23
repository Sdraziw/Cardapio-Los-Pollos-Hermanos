import '../model/itens_model.dart';

class Pedido {
  final String numero; // Número do pedido
  final String statusPedido; // Ex: "Aguardando Pagamento", "Pago", "Concluído"
  final List<Prato> itens; // Lista de itens do pedido

  Pedido({
    required this.numero,
    required this.statusPedido,
    required this.itens,
  });
}
