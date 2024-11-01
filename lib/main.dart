import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:preojeto/firebase_options.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Certifique-se de importar o provider

import 'package:preojeto/view/cadastro_view.dart';
import 'package:preojeto/view/detalhes_view.dart';
import 'package:preojeto/view/esqueci_senha_view.dart';
import 'package:preojeto/view/login_view.dart';
import 'package:preojeto/view/menu_view.dart';
import 'package:preojeto/view/categoria_view.dart';
import 'package:preojeto/view/carrinho_view.dart';
import 'package:preojeto/view/perfil_view.dart';
import 'package:preojeto/view/pagamento_view.dart';
import 'package:preojeto/view/opcoes_pagamento_view.dart';
import 'package:preojeto/view/promo_view.dart';
import 'package:preojeto/view/promo2_view.dart';
import 'package:preojeto/view/historico_view.dart';
import 'package:preojeto/view/splash_view.dart';

import 'package:preojeto/services/message_notifier.dart';
import 'package:preojeto/services/pedido_service.dart';
import 'package:preojeto/widgets/aurora_animation.dart'; // Importa a animação da aurora

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setupservice(); // Registrar o serviço de pedidos antes de executar o app
  runApp(
    //home: AuroraAnimation(), // Usa a animação da aurora como tela inicial
    DevicePreview(
      builder: (context) => ChangeNotifierProvider(
        create: (context) => MessageNotifier(),
        child: const MainApp(),
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: 'login',
      routes: {
        'login': (context) => const LoginView(),
        'cadastro': (context) => const CadastroView(),
        'menu': (context) => const MenuView(),
        'detalhes': (context) => const DetalhesView(),
        'categoria': (context) => const CategoriaView(),
        'esqueci_senha': (context) => EsqueciSenhaView(),
        'carrinho': (context) => CarrinhoView(),
        'perfil': (context) => PerfilView(),
        'pagamento': (context) => PagamentoView(),
        'opcoes_pagamento': (context) => OpcoesPagamentoView(),
        'promo': (context) => const PromoView(),
        'promo2': (context) => const Promo2View(),
        'aurora': (context) => const AuroraAnimation(),
        'historico': (context) => HistoricoView(),
        'splash': (context) => SplashView(),
      },
    );
  }
}
