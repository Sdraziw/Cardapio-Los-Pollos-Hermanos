import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:los_pollos_hermanos_en/firebase_options.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart'; // Make sure to import the provider as it is necessary for using ChangeNotifierProvider

import 'package:los_pollos_hermanos_en/view/registration_view.dart';
import 'package:los_pollos_hermanos_en/view/details_view.dart';
import 'package:los_pollos_hermanos_en/view/forgot_password_view.dart';
import 'package:los_pollos_hermanos_en/view/login_view.dart';
import 'package:los_pollos_hermanos_en/view/menu_view.dart';
import 'package:los_pollos_hermanos_en/view/category_view.dart';
import 'package:los_pollos_hermanos_en/view/cart_view.dart';
import 'package:los_pollos_hermanos_en/view/profile_view.dart';
import 'package:los_pollos_hermanos_en/view/payment_view.dart';
import 'package:los_pollos_hermanos_en/view/payment_options_view.dart';
import 'package:los_pollos_hermanos_en/view/promo_view.dart';
import 'package:los_pollos_hermanos_en/view/promo2_view.dart';
import 'package:los_pollos_hermanos_en/view/history_view.dart';
import 'package:los_pollos_hermanos_en/view/splash_view.dart';

import 'package:los_pollos_hermanos_en/services/message_notifier.dart';
import 'package:los_pollos_hermanos_en/services/order_service.dart';
import 'package:los_pollos_hermanos_en/widgets/aurora_animation.dart'; // Import the aurora animation
import 'dart:ui';
import 'dart:typed_data';
import 'package:get_it/get_it.dart';
import 'package:los_pollos_hermanos_en/view/rgb_circle.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  void setupService() {
    GetIt.I.registerSingleton<OrderService>(OrderService()); // Register the order service before running the app
    GetIt.I.registerSingleton<PromoView>(PromoView());
  }

  setupService();

  runApp(
    //home: AuroraAnimation(), // Use the aurora animation as the initial screen
    DevicePreview(
      enabled: true, // Set to false for production
      builder: (context) => ChangeNotifierProvider( // provider
        create: (context) => MessageNotifier(),
        child: const MainApp(),
      ),
    ),
  );
}

String apiKey = dotenv.env['API_KEY'] ?? '';

void testFirestoreWrite() async {
  final CollectionReference collection = FirebaseFirestore.instance.collection('test');
  await collection.add({'testField': 'testValue'});
  print('Test document added');
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
        'registration': (context) => const RegistrationView(),
        'menu': (context) => const MenuView(),
        'details': (context) => const DetailsView(),
        'category': (context) => const CategoryView(),
        'forgot_password': (context) => ForgotPasswordView(),
        'cart': (context) => CartView(),
        'profile': (context) => ProfileView(),
        'payment': (context) => PaymentView(),
        'payment_options': (context) => PaymentOptionsView(),
        'promo': (context) => PromoView(),
        'promo2': (context) => Promo2View(),
        'aurora': (context) => const AuroraAnimation(),
        'history': (context) => HistoryView(),
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
