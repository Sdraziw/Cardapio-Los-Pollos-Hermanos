import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidoService {
  static const String _historicoKey = 'historicoPedidos';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<Prato> _pedidos = [];
  List<Prato> get pedidos => _pedidos;

  static void setup() {
    getIt.registerLazySingleton<PedidoService>(() => PedidoService());
  }

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
        await itensRef.add({'nome': prato.nome, 'quantidade': quantidade});
      } else {
        QuerySnapshot query = await itensRef.where('nome', isEqualTo: prato.nome).get();
        DocumentSnapshot doc = query.docs.first;
        int quantidadeAtual = doc['quantidade'];
        await doc.reference.update({'quantidade': quantidadeAtual + quantidade});
      }
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

  Future<void> atualizarStatusPedido(String status) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      await pedidoRef.update({'status': status});
    }
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

  void limparPedido() {
    _pedidos.clear();
  }

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
      limparPedido();
    }
  }

  Future<void> registrarPagamento(String numeroPedido, String formaPagamento) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      await pedidoRef.update({
        'status': 'pagamento confirmado',
        'forma_pagamento': formaPagamento,
        'numero_pedido': numeroPedido,
        'data_pagamento': FieldValue.serverTimestamp(),
      });
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

  Future<void> atualizarItensPedido(String nome, int quantidade) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      QuerySnapshot query = await itensRef.where('nome', isEqualTo: nome).get();
      if (query.docs.isNotEmpty) {
        final itemDoc = query.docs.first;
        await itemDoc.reference.update({'quantidade': quantidade});
      }
    }
  }

  Future<List<Map<String, dynamic>>> obterHistoricoFiltrado() async {
    final user = auth.currentUser;
    if (user != null) {
      final historicoRef = firestore.collection('pedidos');
      final querySnapshot = await historicoRef
          .where('uid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pedido finalizado')
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }

  Future<List<String>> obterHistorico() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_historicoKey) ?? [];
  }
}

final getIt = GetIt.instance;

void setupservice() {
  PedidoService.setup();
}
