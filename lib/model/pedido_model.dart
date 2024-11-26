import '../model/itens_model.dart';

class Pedido {
  final String numero; // Número do pedido
  final String status; // Ex: "preparando", "finalizado", "entregue"
  final List<Prato> itens; // Lista de itens do pedido

  Pedido({
    required this.numero,
    required this.status,
    required this.itens,
  });
}
