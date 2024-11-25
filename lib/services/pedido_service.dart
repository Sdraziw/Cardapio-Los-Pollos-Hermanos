import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/itens_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidoService {
  String mensagemErro = '';
  static const String historicoKey = 'pedidos';
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
        if (pedidoData != null && pedidoData['email'] == user.email) {
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
          'dataCriacao': FieldValue.serverTimestamp(),
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
      final pedidoRef = firestore.collection('pedidos').doc(user.uid);
      final pedidoDoc = await pedidoRef.get();
      if (pedidoDoc.exists) {
        final pedidoData = pedidoDoc.data();
        final itensSnapshot = await pedidoRef.collection('itens').get();
        final itensData = itensSnapshot.docs.map((doc) => doc.data()).toList();

        await firestore.collection('historicoPedidos').add({
          'uid': user.uid,
          'email': user.email,
          'numeroPedido': numeroPedido,
          'statusPedido': 'pedido finalizado',
          'itens': itensData,
          'dataCriacao': FieldValue.serverTimestamp(),
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
              pedidoData['email'] == user.email) {
            await pedidoRef.update({
              'statusPedido': 'pagamento confirmado',
              'formaPagamento': formaPagamento,
              'numeroPedido': numeroPedido,
              'dataPagamento': FieldValue.serverTimestamp(),
            });

            // Move o pedido para a coleção de histórico
            await registrarHistorico(numeroPedido);

            // Limpa o novo pedido
            limparPedido();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Pagamento confirmado! Número do pedido: $numeroPedido'),
              ),
            );
            Navigator.pushNamed(context, 'menu');
          } else {
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
          .get();
      return query.docs.isNotEmpty;
    }
    return false;
  }

  Future<List<String>> obterHistorico() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(historicoKey) ?? [];
  }
}

final getIt = GetIt.instance;

void setupservice() {
  PedidoService.setup();
}
