import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PedidoService {
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

  // Gera um número de pedido único e incrementa o contador de pedidos a aprtir da colection cofig
  Future<String> gerarNumeroPedido() async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final pedidoDoc = await pedidoRef.get();
      if (pedidoDoc.exists) {
        return pedidoDoc['numero_pedido'].toString();
      }
    }
    return '0';
  }

  // Adiciona um prato ao pedido
  void adicionarPratoAoPedido(Prato prato) {
    _pedidos.add(prato);
  }

  Future<void> adicionarAoPedido(Prato prato, int quantidade) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      bool itemAdicionado = await verificarItemAdicionado(prato.nome);

      if (!itemAdicionado) {
        await itensRef.add({
          'nome': prato.nome,
          'descricao': prato.descricao,
          'preco': prato.preco,
          'quantidade': quantidade,
          'imagem': prato.imagem,
        });
      } else {
        QuerySnapshot query = await itensRef.where('nome', isEqualTo: prato.nome).get();
        DocumentSnapshot doc = query.docs.first;
        int quantidadeAtual = doc['quantidade'];
        await doc.reference.update({'quantidade': quantidadeAtual + quantidade});
      }
    }
  }

  Future<int> obterProximoNumeroPedido() async {
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

  // Busca os itens do pedido atual do usuário logado
  Future<List<Map<String, dynamic>>> buscarItensPedido() async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensSnapshot = await pedidoRef.collection('itens').get();
      return itensSnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  // Busca o número do pedido atual do usuário logado
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

  // Atualiza o status do pedido
  Future<void> atualizarStatusPedido(String status) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      await pedidoRef.update({'status': status});
    }
  }

  // Verifica se um item já foi adicionado ao pedido
  Future<void> atualizarItensPedido() async {
    for (var prato in _pedidos) {
      final user = auth.currentUser;
      if (user != null) {
        final pedidoRef = firestore.collection('pedidos').doc(user.uid);
        final itensSnapshot = await pedidoRef.collection('itens').where('nome', isEqualTo: prato.nome).get();
        if (itensSnapshot.docs.isNotEmpty) {
          final itemDoc = itensSnapshot.docs.first;
          await itemDoc.reference.update({'quantidade': itemDoc['quantidade'] + 1});
        } else {
          await pedidoRef.collection('itens').add({
            'nome': prato.nome,
            'preco': prato.preco,
            'quantidade': 1,
            'imagem': prato.imagem,
            'descricao': prato.descricao,
          });
        }
      }
    }
  }

  // Registra o pagamento do pedido
  Future<void> registrarPagamento(String numeroPedido, String formaPagamento) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      await pedidoRef.update({
        'status': 'pagamento confirmado',
        'forma_pagamento': formaPagamento,
        'numero_pedido': numeroPedido,
      });
    }
  }


  Future<bool> verificarItem(String nome) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensSnapshot = await pedidoRef.collection('itens').where('nome', isEqualTo: nome).get();
      return itensSnapshot.docs.isNotEmpty;
    }
    return false;
  }

  Future<bool> verificarItemAdicionado(String nome) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      QuerySnapshot query = await itensRef.where('nome', isEqualTo: nome).get();
      return query.docs.isNotEmpty;
    }
    return false;
  }

  // Remove um prato do pedido
  Future<void> removerDoPedido(Prato prato) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      QuerySnapshot query = await itensRef.where('nome', isEqualTo: prato.nome).get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }
    }
  }

  // Limpa o pedido atual
  void limparPedido() {
    _pedidos.clear();
  }

  // Registra o histórico do pedido no firebase consultando a coleção 'pedidos'
  Future<void> registrarHistorico(String numeroPedido) async {
    final user = auth.currentUser;
    if (user != null) {
      final historicoRef = firestore.collection('pedidos');
      await historicoRef.add({
        'uid': user.uid,
        'numero_pedido': numeroPedido,
        'status': 'pedido finalizado',
        'itens': _pedidos.map((prato) => prato.nome).toList(),
        'data_hora': FieldValue.serverTimestamp(),

      });

      //limpar o pedido após o registro no histórico
      limparPedido();
    }
  }
  /*
  Future<void> registrarHistorico(String numeroPedido) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> historico = prefs.getStringList(_historicoKey) ?? [];

    // Adiciona o histórico com o número do pedido, status e itens do pedido do usuário logado
    historico.add('Pedido: $numeroPedido - Status: aguardando pagamento - Itens: ${_pedidos.map((prato) => prato.nome).join(", ")}');
    
    // Adiciona o histórico com o número do pedido, status e itens do pedido
    historico.add(
        'Pedido: $numeroPedido - Status: ${_pedidos.isNotEmpty ? _pedidos.first.status : 'Desconhecido'} - Itens: ${_pedidos.map((prato) => prato.nome).join(", ")}');

    // Armazena o histórico atualizado
    await prefs.setStringList(_historicoKey, historico);
    limparPedido(); // Limpa o pedido após o registro no histórico
  }
  */

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
