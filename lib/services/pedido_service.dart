import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PedidoService {
  static const String _numeroPedidoKey = 'numeroPedido';
  static const String _historicoKey = 'historicoPedidos';
  // Lista de pratos no pedido atual
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Lista de pratos no pedido atual
  final List<Prato> _pedidos = [];
  List<Prato> get pedidos => _pedidos;

  // Registrar o serviço no GetIt
  static void setup() {
    getIt.registerLazySingleton<PedidoService>(() => PedidoService());
  }

  // Gera um número de pedido único e incrementa o contador de pedidos
  Future<String> gerarNumeroPedido() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int numeroPedido = prefs.getInt(_numeroPedidoKey) ?? 0;
    numeroPedido++;
    await prefs.setInt(_numeroPedidoKey, numeroPedido);
    return numeroPedido.toString().padLeft(4, '0');
  }

  // Adiciona um prato ao pedido
  void adicionarPratoAoPedido(Prato prato) {
    _pedidos.add(prato);
  }

  Future<void> adicionarAoPedido(Prato prato, int quantidade) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);

      // Verificar se o pedido já existe
      final pedidoDoc = await pedidoRef.get();
      if (!pedidoDoc.exists) {
        // Criar um novo pedido se não existir
        await pedidoRef.set({
          'uid': user.uid,
          'status': 'aguardando pagamento',
          'data_hora': FieldValue.serverTimestamp(),
          'numero_pedido': await _obterProximoNumeroPedido(),
        });
      }

      // Adicionar o item à subcoleção 'itens'
      await pedidoRef.collection('itens').add({
        'nome': prato.nome,
        'preco': prato.preco,
        'quantidade': quantidade,
      });
    }
  }

  Future<int> _obterProximoNumeroPedido() async {
    final configRef = firestore.collection('config').doc('numeroPedido');
    final configDoc = await configRef.get();

    if (configDoc.exists) {
      int numeroPedido = configDoc['numero'] ?? 0;
      await configRef.update({'numero': numeroPedido + 1});
      return numeroPedido + 1;
    } else {
      await configRef.set({'numero': 1});
      return 1;
    }
  }

  Future<List<Map<String, dynamic>>> buscarItensPedido() async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensSnapshot = await pedidoRef.collection('itens').get();
      return itensSnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<int?> buscarNumeroPedido() async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final pedidoDoc = await pedidoRef.get();
      if (pedidoDoc.exists) {
        return pedidoDoc['numero_pedido'];
      }
    }
    return null;
  }

  // Remove um prato do pedido
  void removerDoPedido(Prato prato) {
    _pedidos.remove(prato);
  }

  // Limpa o pedido atual
  void limparPedido() {
    _pedidos.clear();
  }

  // Registra o histórico do pedido
  Future<void> registrarHistorico(String numeroPedido) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historico = prefs.getStringList(_historicoKey) ?? [];

    // Adiciona o histórico com o número do pedido, status e itens do pedido
    historico.add(
        'Pedido: $numeroPedido - Status: ${_pedidos.isNotEmpty ? _pedidos.first.status : 'Desconhecido'} - Itens: ${_pedidos.map((prato) => prato.nome).join(", ")}');

    // Armazena o histórico atualizado
    await prefs.setStringList(_historicoKey, historico);
    limparPedido(); // Limpa o pedido após o registro no histórico
  }

  // Obtém o histórico de pedidos
  Future<List<String>> obterHistorico() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historicoKey) ?? [];
  }
}

// Registrar o serviço no GetIt
final getIt = GetIt.instance;

// Função de configuração do serviço
void setupservice() {
  PedidoService.setup();
}
