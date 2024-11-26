import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidoService {
  String mensagemErro = '';
  static const String historicoKey = 'pedidos';
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<String> numeroPedido;

  PedidoService() {
    numeroPedido = verificarOuGerarNumeroPedido();
  }
  final List<Prato> _pedidos = [];
  List<Prato> get pedidos => _pedidos;

  static void setup() {
    getIt.registerLazySingleton<PedidoService>(() => PedidoService());
  }

  Future<String> verificarOuGerarNumeroPedido() async {
    final user = auth.currentUser;
    if (user != null) {
      // Verifica se há um pedido com status "preparando"
      final pedidosRef = firestore.collection('pedidos');
      final querySnapshot = await pedidosRef
          .where('email', isEqualTo: user.email)
          .where('status', isEqualTo: 'preparando')
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Se houver um pedido com status "preparando", retorna o número do pedido
        return querySnapshot.docs.first.id;
      } else {
        // Se não houver pedido "preparando", gera um novo número de pedido
        final numeroPedidoRef =
            firestore.collection('config').doc('numeroPedido');
        final numeroPedidoSnapshot = await numeroPedidoRef.get();
        int numeroPedido = numeroPedidoSnapshot.exists
            ? numeroPedidoSnapshot.data()!['valor'] + 1
            : 1;
        await numeroPedidoRef.set({'valor': numeroPedido});

        // Cria um novo pedido com status "preparando"
        await pedidosRef.doc(numeroPedido.toString()).set({
          'email': user.email,
          'status': 'preparando',
          'data': FieldValue.serverTimestamp(),
        });

        return numeroPedido.toString();
      }
    } else {
      throw Exception('Usuário não autenticado');
    }
  }

  Future<String> atualizarstatus(
      context, String numeroPedido, String status) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
      final pedidoDoc = await pedidoRef.get();
      if (pedidoDoc.exists) {
        final pedidoData = pedidoDoc.data();
        if (pedidoData != null && pedidoData['email'] == user.email) {
          await pedidoRef.update({
            'status': status,
            'dataAtualizacao': FieldValue.serverTimestamp(),
            'numeroPedido': pedidoData['numeroPedido'],
            'dataCriacao': pedidoData['dataCriacao'],
            'email': user.email,
          });
          return status;
        } else if (pedidoData != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              content: Text(
                  'Else if: Erro ao atualizar status do pedido. #${status}'),
            ),
          );
          return status;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.withOpacity(0.5),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              padding: EdgeInsets.all(10.0),
              content: Text('Erro ao atualizar status do pedido. #${status}'),
            ),
          );
          return status;
        }
      }
    }
    return '0';
  }

  void adicionarPratoAoPedido(Prato prato) {
    _pedidos.add(prato);
  }

  Future<void> adicionarAoPedido(
      Prato prato, int quantidade, BuildContext context) async {
    final user = auth.currentUser;
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          content: Text('Usuário autenticado: ${user.email}'),
        ),
      );
      final numeroPedido = await verificarOuGerarNumeroPedido();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          content: Text('Número do pedido gerado: $numeroPedido'),
        ),
      );
      final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
      final pedidoSnapshot = await pedidoRef.get();

      if (!pedidoSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Criando novo pedido para o usuário: ${user.email}'),
          ),
        );
        await pedidoRef.set({
          'uid': user.uid,
          'email': user.email,
          'status': 'preparando',
          'data_hora': FieldValue.serverTimestamp(),
          'numeroPedido': numeroPedido,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Pedido existente encontrado para o usuário: ${user.uid}'),
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
          ),
        );
      }

      final itensRef = pedidoRef.collection('itens');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          content: Text('Referência para itens do pedido: $itensRef'),
        ),
      );
      bool itemAdicionado =
          await verificarItemAdicionado(prato.nome, numeroPedido);

      if (itemAdicionado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Este Item foi adicionado ao pedido.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Este Item não estava no pedido.'),
          ),
        );
      }

      if (!itemAdicionado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Adicionando novo item ao pedido'),
          ),
        );
        await itensRef.doc(prato.nome).set({
          'item_id': prato.id,
          'nome': prato.nome,
          'descricao': prato.descricao,
          'preco': prato.preco,
          'imagem': prato.imagem,
          'resumo': prato.resumo,
          'quantidade': quantidade,
          'itemPacote': prato.itemPacote,
          'cupom': prato.cupom,
          'categoria': prato.categoria,
          'dataCriacao': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Item ${prato.nome} adicionado com sucesso'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Atualizando quantidade do item existente'),
          ),
        );
        DocumentSnapshot doc = await itensRef.doc(prato.nome).get();
        int quantidadeAtual = doc['quantidade'];
        await doc.reference
            .update({'quantidade': quantidadeAtual + quantidade});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text('Quantidade do item atualizada com sucesso'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(10.0),
          content: Text('Usuário não autenticado'),
        ),
      );
    }
  }

  Future<void> finalizarPedido(BuildContext context) async {
    final user = auth.currentUser;
    if (user != null) {
      final numeroPedidoRef =
          firestore.collection('config').doc('numeroPedido');
      await firestore.runTransaction((transaction) async {
        final numeroPedidoSnapshot = await transaction.get(numeroPedidoRef);
        int numeroPedido = numeroPedidoSnapshot.exists
            ? numeroPedidoSnapshot.data()!['valor'] + 1
            : 1;

        // Atualiza o número do pedido no documento de configuração
        transaction.update(numeroPedidoRef, {'valor': numeroPedido});

        // Cria um novo pedido com o número do pedido e o e-mail do usuário
        final pedidoRef =
            firestore.collection('pedidos').doc(numeroPedido.toString());
        transaction.set(pedidoRef, {
          'numeroPedido': numeroPedido,
          'emailUsuario': user.email,
          // Adicione outros campos necessários para o pedido aqui
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text(
                'Pedido finalizado com sucesso! Número do pedido: $numeroPedido'),
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário não autenticado'),
          backgroundColor: Colors.red.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(10.0),
        ),
      );
      // desloga e traz para tela de login view
    }
  }

  // verifica se o numero do pedido existe com o usuario logado
  Future<bool> verificarNumeroPedido(String numeroPedido) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
      final pedidoDoc = await pedidoRef.get();
      return pedidoDoc.exists && pedidoDoc.data()!['email'] == user.email;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> buscarItensPedidoPorStatus(
      String numeroPedido, String status) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
      final pedidoSnapshot = await pedidoRef.get();
      if (pedidoSnapshot.exists &&
          pedidoSnapshot.data()!['email'] == user.email &&
          pedidoSnapshot.data()!['status'] == status) {
        final itensSnapshot = await pedidoRef.collection('itens').get();
        return itensSnapshot.docs.map((doc) => doc.data()).toList();
      }
    }
    return [];
  }

  Stream<List<Map<String, dynamic>>> buscarItensPedidoPorStatusStream() {
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

  Future<bool> verificarItemAdicionado(String nome, String numeroPedido) async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
      final itensRef = pedidoRef.collection('itens');
      final query = await itensRef.where('nome', isEqualTo: nome).get();
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

  Future<void> limparPedido() async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      await pedidoRef.delete();
    }
  }

  Future<void> registrarHistorico(Map<String, dynamic> pedidoData) async {
    final user = auth.currentUser;
    if (user != null) {
      final historicoRef = firestore
          .collection('historico')
          .doc(user.uid)
          .collection('pedidos')
          .doc(pedidoData['numeroPedido'].toString());
      await historicoRef.set(pedidoData);
    }
  }

  Future<void> registrarPagamento(
      BuildContext context, String numeroPedido, String formaPagamento) async {
    final user = auth.currentUser;
    if (user != null) {
      try {
        final pedidoRef = firestore.collection('pedidos').doc(numeroPedido);
        final pedidoDoc = await pedidoRef.get();

        if (pedidoDoc.exists) {
          final pedidoData = pedidoDoc.data();
          if (pedidoData != null &&
              pedidoData['numeroPedido'] == numeroPedido) {
            await pedidoRef.update({
              'status': 'pagamento confirmado',
              'formaPagamento': formaPagamento,
              'dataPagamento': FieldValue.serverTimestamp(),
            });

            // Move o pedido para a coleção de histórico
            await registrarHistorico(pedidoData);

            // Limpa o novo pedido
            await limparPedido();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green.withOpacity(0.5),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: EdgeInsets.all(10.0),
                content: Text(
                    'Pagamento confirmado! Número do pedido: $numeroPedido'),
              ),
            );
            Navigator.pushNamed(context, 'menu');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red.withOpacity(0.5),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: EdgeInsets.all(10.0),
                content: Text(
                    'Erro: Pedido não encontrado ou número do pedido inválido.'),
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar pagamento: $e'),
          ),
        );
      }
    }
  }

  Future<int> obterProximoNumeroPedido(BuildContext context) async {
    final user = auth.currentUser;
    if (user != null) {
      final configOnlineRef =
          firestore.collection('configOnline').doc('numeroPedido');
      final configOnlineDoc = await configOnlineRef.get();
      if (configOnlineDoc.exists) {
        int numeroPedido = configOnlineDoc['numeroPedido'] ?? 0;
        await configOnlineRef.update({
          'numeroPedido': numeroPedido + 1,
          'dataCriacao': FieldValue.serverTimestamp(),
        });
        return numeroPedido + 1;
      } else {
        await configOnlineRef.set({
          'numeroPedido': 1,
          'dataCriacao': FieldValue.serverTimestamp(),
        });
        return 1;
      }
    } else {
      throw Exception('Usuário não autenticado.');
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
        id: 'SOBREMESA2024',
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
        await adicionarAoPedido(pratoGratuito, 1, context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text(
                '🌵🌕👻🍦 #${codigo}#🌕🌵🦅 Aplicado com sucesso.'), //futuramente colocar o expirado
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text(
                '😕 Código promocional já foi aplicado anteriormente.'), //futuramente colocar o expirado
          ),
        );
      }
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        id: 'LANCHE2024',
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
        await adicionarAoPedido(pratoGratuito, 1, context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text(
                '🌵🌞🤤🍔 #${codigo}#🌵🌞 Aplicado com sucesso.'), //futuramente colocar o expirado
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.withOpacity(0.5),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.all(10.0),
            content: Text(
                '\n😜 O código promocional #${codigo}# já foi utilizado anteriormente. 😜'), //futuramente colocar o expirado
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(10.0),
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
          .get();
      return query.docs.isNotEmpty;
    }
    return false;
  }

  Future<List<Map<String, dynamic>>> obterHistorico() async {
    final user = auth.currentUser;
    if (user != null) {
      final pedidosSnapshot = await firestore
          .collection('pedidos')
          .where('numeroPedido', isGreaterThan: 0)
          .get();
      return pedidosSnapshot.docs.map((doc) => doc.data()).toList();
    }
    return [];
  }
}

final getIt = GetIt.instance;

void setupservice() {
  PedidoService.setup();
}
