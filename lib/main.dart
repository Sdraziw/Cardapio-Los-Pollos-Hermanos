import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:los_pollos_hermanos/firebase_options.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Certifique-se de importar o provider pois ele é necessário para o uso do ChangeNotifierProvider

import 'package:los_pollos_hermanos/view/cadastro_view.dart';
import 'package:los_pollos_hermanos/view/detalhes_view.dart';
import 'package:los_pollos_hermanos/view/esqueci_senha_view.dart';
import 'package:los_pollos_hermanos/view/login_view.dart';
import 'package:los_pollos_hermanos/view/menu_view.dart';
import 'package:los_pollos_hermanos/view/categoria_view.dart';
import 'package:los_pollos_hermanos/view/carrinho_view.dart';
import 'package:los_pollos_hermanos/view/perfil_view.dart';
import 'package:los_pollos_hermanos/view/pagamento_view.dart';
import 'package:los_pollos_hermanos/view/opcoes_pagamento_view.dart';
import 'package:los_pollos_hermanos/view/promo_view.dart';
import 'package:los_pollos_hermanos/view/promo2_view.dart';
import 'package:los_pollos_hermanos/view/historico_view.dart';
import 'package:los_pollos_hermanos/view/splash_view.dart';

import 'package:los_pollos_hermanos/services/message_notifier.dart';
import 'package:los_pollos_hermanos/services/pedido_service.dart';
import 'package:los_pollos_hermanos/widgets/aurora_animation.dart'; // Importa a animação da aurora
import 'dart:ui';
import 'dart:typed_data';
import 'package:get_it/get_it.dart';
import 'package:los_pollos_hermanos/view/rgb_circle.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {

  await dotenv.load(fileName: ".env");

  // Configure the ChannelBuffers to handle messages
  ChannelBuffers channelBuffers = ChannelBuffers();
  channelBuffers.setListener('flutter/lifecycle', (ByteData? data, PlatformMessageResponseCallback? callback) {
    // Handle the message here
    if (callback != null) {
      callback(null);
    }
  });

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  void setupservice() {
    GetIt.I.registerSingleton<PedidoService>(PedidoService()); // Registrar o serviço de pedidos antes de executar o app
    GetIt.I.registerSingleton<PromoView>(PromoView());
  }

  setupservice();

  runApp(
    //home: AuroraAnimation(), // Usa a animação da aurora como tela inicial
    DevicePreview(
      enabled: false,
      builder: (context) => ChangeNotifierProvider( // provider
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
        'promo': (context) => PromoView(),
        'promo2': (context) => Promo2View(),
        'aurora': (context) => const AuroraAnimation(),
        'historico': (context) => HistoricoView(),
        'splash': (context) => SplashView(),
      },
      title: 'Los Pollos Hermanos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Los Pollos Hermanos'),
        ),
        body: RGBCircle(),
      ),
    );
  }
}
