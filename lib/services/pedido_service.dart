import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidoService {
  String mensagemErro = '';
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
        await itensRef.add({
          'nome': prato.nome,
          'descricao': prato.descricao,
          'preco': prato.preco,
          'imagem': prato.imagem,
          'resumo': prato.resumo,
          'quantidade': quantidade,
          'item_pacote': prato.item_pacote,
          'cupom': prato.cupom,
          'categoria': prato.categoria,
        });
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

  Stream<List<Map<String, dynamic>>> buscarItensPedidoStream() {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      return pedidoRef.collection('itens').snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'nome': data['nome'] ?? '',
            'descricao': data['descricao'] ?? '',
            'preco': (data['preco'] as num?)?.toDouble() ?? 0.0,
            'imagem': data['imagem'] ?? '',
            'resumo': data['resumo'] ?? '',
            'quantidade': data['quantidade'] ?? 0,
            'item_pacote': data['item_pacote'] ?? '',
            'cupom': data['cupom'] ?? false,
            'categoria': data['categoria'] ?? '',
          };
        }).toList();
      });
    }
    return Stream.value([]);
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

  Future<void> atualizarStatusPedido(BuildContext context, String status) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(user.uid);
        await pedidoRef.update({'status': status});
        ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  content: Text('Status atualizado com sucesso para: $status'),
                ),
              );
      } catch (e) {
        print('Erro ao atualizar status: $e');
      }
    } else {
      print('Usuário não autenticado.');
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

  Future<int> obterProximoNumeroPedido(BuildContext context) async {
    final configRef = firestore.collection('config').doc('numeroPedido');
    final configDoc = await configRef.get();

    if (configDoc.exists) {
      int numeroPedido = configDoc['numero'] ?? 0;
      await configRef.update({'numero': numeroPedido + 1});
       ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  content: Text('Novo pedido gerado de número: ${numeroPedido + 1}.'),
                ),
              );
      return numeroPedido + 1;
    } else {
      await configRef.set({'numero': 1});
      ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  content: Text('Primeiro pedido registrado em Firebase.'),
                ),
              );
      return 1;
    }
  }

  Future<void> atualizarItensPedido(String nome, int quantidade, double preco,) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      QuerySnapshot query = await itensRef.where('nome', isEqualTo: nome).get();
      if (query.docs.isNotEmpty) {
        final itemDoc = query.docs.first;
        await itemDoc.reference.update({'quantidade': quantidade});
      } else { // Adiciona o item ao pedido se não existir
        await itensRef.add({'nome': nome, 'quantidade': quantidade, 'preco': preco});

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
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'nome': data['nome'] ?? '',
          'preco': (data['preco'] as num?)?.toDouble() ?? 0.0,
          'imagem': data['imagem'] ?? '',
          'resumo': data['resumo'] ?? '',
          'quantidade': data['quantidade'] ?? 0,
          'item_pacote': data['item_pacote'] ?? '',
          'cupom': data['cupom'] ?? false,
          'categoria': data['categoria'] ?? '',
        };
      }).toList();
    }
    return [];
  }

  // Verifica se já existe um pedido em andamento para o usuário logado e cria um novo pedido se não existir um pedido em andamento
  Future<void> verificarPedidoExistente(BuildContext context) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(user.uid);
        final pedidoDoc = await pedidoRef.get();

        if (pedidoDoc.exists) {
          String status = pedidoDoc['status'];
          if (status == 'novo pedido' || status == 'aguardando pagamento' || status == 'pedido aberto') {
            
              // Atualiza a tela com o pedido existente de status novo pedido ou aguardando pagamento
              await atualizarStatusPedido(context, status);
            
          } else if (status == 'pagamento confirmado') {
            // Mantém o pedido com status "pagamento confirmado" e cria um novo pedido
            int novoNumeroPedido = await obterProximoNumeroPedido(context);
            await firestore.collection('pedidos').add({
              'uid': user.uid,
              'numero_pedido': novoNumeroPedido,
              'status': 'novo pedido',
              'data': FieldValue.serverTimestamp(),
            });
            
              // Atualiza a tela com o novo pedido criado
              await atualizarStatusPedido(context, 'novo pedido');
            
          } else {
            // Mantém o pedido com status diferente de "novo pedido" ou "aguardando pagamento"
            
              mensagemErro = 'Você não pode modificar um pedido com status "$status".';
            
          }
        } else {
          int novoNumeroPedido = await obterProximoNumeroPedido(context);
          await pedidoRef.set({
            'numero_pedido': novoNumeroPedido,
            'status': 'pedido aberto',
            'data': FieldValue.serverTimestamp(),
          });
          
            // Atualiza a tela com o novo pedido criado
            await atualizarStatusPedido(context, 'pedido aberto');
          
        }
      } catch (e) {
        print('Erro ao verificar pedido existente: $e');
      }
    }
  }

  // Aplicar código promocional e adicionar item ao pedido se o código for válido
  void aplicarCodigoPromocional(BuildContext context, String codigo) {
    bool lanche2024 = true;
    bool sobremesa2024 = true;
    Prato? pratoGratuito;

    if ((codigo == 'SOBREMESA2024') && sobremesa2024 == true) {
      sobremesa2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻SOBREMESA2024 🍦- Sorvete Negresco",
        preco: 0.0,
        imagem: "lib/images/ice-cream.webp",
        descricao:
            "Sorvete Negresco é feito de leite condensado, leite, biscoitos Negresco, essência de baunilha, ovos, açúcar e creme de leite. Bem simples e delicioso! 🍦",
        resumo: 'Casquinha Recheada e Massa Baunilha',
        quantidade: 1,
        item_pacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Sobremesas',
      );
      // Adicione o prato gratuito ao pedido ou faça outra ação necessária
      _pedidos.add(pratoGratuito);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Text(
              '🌵🌕👻🍦 SOBREMESA2024🦅🌕🌵 Aplicado com sucesso.'), //futuramente colocar o expirado
        ),
      );
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻LANCHE2024 🍔- Cê é LOCO cachoeira",
        preco: 0.0,
        imagem: 'lib/images/promo_image.png',
        descricao: "Pão de hamburguer, Frango Parrudo Empanado, Molho Barbecue",
        resumo: 'Lanche parrudo | 200g 🍔',
        quantidade: 1,
        item_pacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Lanches',
      );
      // Adicione o prato gratuito ao pedido ou faça outra ação necessária
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Text(
              '🌵🌞🤤🍔 LANCHE2024🌵🌞 Aplicado com sucesso.'), //futuramente colocar o expirado
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          content: Text(
              '😕 Código promocional inválido ou já aplicado.'), //futuramente colocar o expirado
        ),
      );
    }
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
