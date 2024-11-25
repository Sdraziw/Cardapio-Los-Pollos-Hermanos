import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidoService {
  String mensagemErro = '';
  static const String _historicoKey = 'Pedidos';
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
        final pedidoData = pedidoDoc.data();
        if (pedidoData != null && pedidoData['uid'] == user.uid) {
          return pedidoData['numeroPedido'].toString();
        }
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
          'itemPacote': prato.itemPacote,
          'cupom': prato.cupom,
          'categoria': prato.categoria,
        });
      } else {
        QuerySnapshot query =
            await itensRef.where('nome', isEqualTo: prato.nome).get();
        DocumentSnapshot doc = query.docs.first;
        int quantidadeAtual = doc['quantidade'];
        await doc.reference
            .update({'quantidade': quantidadeAtual + quantidade});
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
            'itemPacote': data['itemPacote'] ?? '',
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
        return pedidoDoc['numeroPedido'];
      }
    }
    return null;
  }

  Future<void> atualizarStatusPedido(
      BuildContext context, String statusPedido) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(user.uid);
        final pedidoDoc = await pedidoRef.get();
        if (pedidoDoc.exists) {
          await pedidoRef.update({'statusPedido': statusPedido});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.black.withOpacity(0.5),
              content:
                  Text('Status atualizado com sucesso para: $statusPedido'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              content: Text('Erro: Documento não encontrado.'),
            ),
          );
        }
      } catch (e) {
        print('Erro ao atualizar statusPedido: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            content: Text('Erro ao atualizar statusPedido: $e'),
          ),
        );
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
      QuerySnapshot query =
          await itensRef.where('nome', isEqualTo: prato.nome).get();
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
      final historicoRef = firestore.collection('historicoPedidos');
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final pedidoDoc = await pedidoRef.get();
      if (pedidoDoc.exists) {
        final pedidoData = pedidoDoc.data();
        final itensSnapshot = await pedidoRef.collection('itens').get();
        final itensData = itensSnapshot.docs.map((doc) => doc.data()).toList();

        await historicoRef.add({
          'uid': user.uid,
          'email': user.email, // Adiciona o e-mail do usuário
          'numeroPedido': numeroPedido,
          'statusPedido': 'pedido finalizado',
          'itens': itensData,
          'data_hora': FieldValue.serverTimestamp(),
          ...?pedidoData,
        });

        // Remove o pedido atual
        await pedidoRef.delete();
      }
    }
  }

  Future<void> registrarPagamento(
      BuildContext context, String numeroPedido, String formaPagamento) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(user.uid);
        final pedidoDoc = await pedidoRef.get();

        if (pedidoDoc.exists) {
          final pedidoData = pedidoDoc.data();
          if (pedidoData != null &&
              pedidoData['numeroPedido'] == numeroPedido &&
              pedidoData['uid'] == user.uid) {
            await pedidoRef.update({
              'statusPedido': 'pagamento confirmado',
              'forma_pagamento': formaPagamento,
              'numeroPedido': numeroPedido,
              'data_pagamento': FieldValue.serverTimestamp(),
              'email': user.email, // Adiciona o e-mail do usuário
            });

            // Move o pedido para a coleção de histórico
            await registrarHistorico(numeroPedido);

            // Limpa o novo pedido
            limparPedido();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Pagamento confirmado! 💰\nAguarde, seu pedido está sendo preparado!⌛\nNúmero do pedido: $numeroPedido'),
              ),
            );
            Navigator.pushNamed(context, 'menu');
          } else {
            // Limpa o carrinho se não for o carrinho atual
            limparPedido();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.withOpacity(0.5),
                content: Text('Carrinho não é o atual, foi limpo.'),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            content: Text('Erro ao registrar pagamento: $e'),
          ),
        );
      }
    } else {
      throw Exception('Usuário não autenticado.');
    }
  }

  Future<int> obterProximoNumeroPedido(BuildContext context) async {
    final user = auth.currentUser;
    if (user != null) {
      final configOnlineRef =
          firestore.collection('configOnline').doc('numeroPedido');
      final configOnlineDoc = await configOnlineRef.get();

      if (configOnlineDoc.exists) {
        int numeroPedido = configOnlineDoc['numero'] ?? 0;
        await configOnlineRef.update({
          'numero': numeroPedido + 1,
          'timestamp': FieldValue.serverTimestamp(),
          'uid': user.uid,
          'email': user.email, // Adiciona o e-mail do usuário
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            content: Text('Novo pedido gerado de número: ${numeroPedido + 1}.'),
          ),
        );
        return numeroPedido + 1;
      } else {
        await configOnlineRef.set({
          'numero': 1,
          'timestamp': FieldValue.serverTimestamp(),
          'uid': user.uid,
          'email': user.email, // Adiciona o e-mail do usuário
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.black.withOpacity(0.5),
            content: Text('💾Primeiro pedido registrado em Firebase🔥🛢️.'),
          ),
        );
        return 1;
      }
    } else {
      throw Exception('Usuário não autenticado.');
    }
  }

  Future<void> atualizarItensPedido(
      String nome, int quantidade, Map<String, dynamic> data) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      QuerySnapshot query = await itensRef.where('nome', isEqualTo: nome).get();
      if (query.docs.isNotEmpty) {
        final itemDoc = query.docs.first;
        await itemDoc.reference.update({
          'quantidade': quantidade,
          'nome': data['nome'] ?? '',
          'descricao': data['descricao'] ?? '',
          'preco': (data['preco'] as num?)?.toDouble() ?? 0.0,
          'imagem': data['imagem'] ?? '',
          'resumo': data['resumo'] ?? '',
          'itemPacote': data['itemPacote'] ?? '',
          'cupom': data['cupom'] ?? false,
          'categoria': data['categoria'] ?? '',
        });
      } else {
        await itensRef.add({
          'nome': data['nome'] ?? '',
          'descricao': data['descricao'] ?? '',
          'preco': (data['preco'] as num?)?.toDouble() ?? 0.0,
          'imagem': data['imagem'] ?? '',
          'resumo': data['resumo'] ?? '',
          'quantidade': quantidade,
          'itemPacote': data['itemPacote'] ?? '',
          'cupom': data['cupom'] ?? false,
          'categoria': data['categoria'] ?? '',
        });
      }
    }
  }

  Future<List<Map<String, dynamic>>> obterHistoricoFiltrado() async {
    final user = auth.currentUser;
    if (user != null) {
      final historicoRef = firestore.collection('historicoPedidos');
      final querySnapshot = await historicoRef
          .where('email',
              isEqualTo: user.email) // Filtra pelo e-mail do usuário
          .orderBy('data_hora', descending: true)
          .get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'numeroPedido': data['numeroPedido'] ?? '',
          'statusPedido': data['statusPedido'] ?? '',
          'data_hora':
              (data['data_hora'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'itens': (data['itens'] as List<dynamic>?)
                  ?.map((item) => item as Map<String, dynamic>)
                  .toList() ??
              [],
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
          String statusPedido = pedidoDoc['statusPedido'];
          if (statusPedido == 'novo pedido' ||
              statusPedido == 'aguardando pagamento' ||
              statusPedido == 'pedido aberto') {
            // Atualiza a tela com o pedido existente de statusPedido novo pedido ou aguardando pagamento
            await atualizarStatusPedido(context, statusPedido);
          } else if (statusPedido == 'pagamento confirmado') {
            // Mantém o pedido com statusPedido "pagamento confirmado" e cria um novo pedido
            int novoNumeroPedido = await obterProximoNumeroPedido(context);
            await firestore.collection('pedidos').add({
              'uid': user.uid,
              'numeroPedido': novoNumeroPedido,
              'statusPedido': 'novo pedido',
              'data': FieldValue.serverTimestamp(),
              'email': user.email, // Adiciona o e-mail do usuário
            });

            // Atualiza a tela com o novo pedido criado
            await atualizarStatusPedido(context, 'novo pedido');
          } else {
            // Mantém o pedido com statusPedido diferente de "novo pedido" ou "aguardando pagamento"
            mensagemErro =
                'Você não pode modificar um pedido com statusPedido "$statusPedido".';
          }
        } else {
          int novoNumeroPedido = await obterProximoNumeroPedido(context);
          await pedidoRef.set({
            'numeroPedido': novoNumeroPedido,
            'statusPedido': 'pedido aberto',
            'data': FieldValue.serverTimestamp(),
            'email': user.email, // Adiciona o e-mail do usuário
          });

          // Atualiza a tela com o novo pedido criado
          await atualizarStatusPedido(context, 'pedido aberto');
        }
      } catch (e) {
        print('Erro ao verificar pedido existente: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            content: Text('Erro ao verificar pedido existente: $e'),
          ),
        );
      }
    }
  }

  Future<void> aplicarCodigoPromocional(
      BuildContext context, String codigo) async {
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
        itemPacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Sobremesas',
      );
      // Verifica se o item já foi adicionado por cupom
      bool itemAdicionadoPorCupom =
          await verificarItemAdicionadoPorCupom(pratoGratuito.nome);
      if (!itemAdicionadoPorCupom) {
        // Adicione o prato gratuito ao pedido no Firebase
        await adicionarAoPedido(pratoGratuito, 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            content: Text(
                '🌵🌕👻🍦 #${codigo}#🌕🌵🦅 Aplicado com sucesso.'), //futuramente colocar o expirado
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            content: Text(
                '😕 Código promocional já foi aplicado anteriormente.'), //futuramente colocar o expirado
          ),
        );
      }
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻LANCHE2024 🍔- Cê é LOCO cachoeira",
        preco: 0.0,
        imagem: 'lib/images/promo_image.png',
        descricao: "Pão de hamburguer, Frango Parrudo Empanado, Molho Barbecue",
        resumo: 'Lanche parrudo | 200g 🍔',
        quantidade: 1,
        itemPacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Lanches',
      );
      // Verifica se o item já foi adicionado por cupom
      bool itemAdicionadoPorCupom =
          await verificarItemAdicionadoPorCupom(pratoGratuito.nome);
      if (!itemAdicionadoPorCupom) {
        // Adicione o prato gratuito ao pedido no Firebase
        await adicionarAoPedido(pratoGratuito, 1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            content: Text(
                '🌵🌞🤤🍔 #${codigo}#🌵🌞 Aplicado com sucesso.'), //futuramente colocar o expirado
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            content: Text(
                '\n😜 O código promocional #${codigo}# já foi utilizado anteriormente. 😜'), //futuramente colocar o expirado
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          content: Text(
              '😕 Código promocional #${codigo}# inválido ou expirado.'), //futuramente colocar o expirado
        ),
      );
    }
  }

  Future<bool> verificarItemAdicionadoPorCupom(String nome) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final itensRef = pedidoRef.collection('itens');
      QuerySnapshot query = await itensRef
          .where('nome', isEqualTo: nome)
          .where('cupom', isEqualTo: true)
          .where('email',
              isEqualTo: user.email) // Filtra pelo e-mail do usuário
          .get();
      return query.docs.isNotEmpty;
    }
    return false;
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
