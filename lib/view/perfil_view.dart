import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:los_pollos_hermanos/controller/login_controller.dart';
import 'package:audioplayers/audioplayers.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => PerfilViewState();
}

class PerfilViewState extends State<PerfilView> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final LoginController loginController = LoginController();
  String? email = FirebaseAuth.instance.currentUser?.email;

  bool obscureText_ = true;
  int currentIndex = 2;

  void _onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });

    if (index == 0) {
      Navigator.pushReplacementNamed(context, 'menu');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, 'historico');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, 'perfil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFFFD600),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Perfil de Usuário'),
                Image.network(
                  'lib/images/heads.png',
                  height: 40,
                ),
                /*FutureBuilder<String>(
                  future: loginController.usuarioLogadoPrimeiroNome(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Erro ao carregar dados: ${snapshot.error}');
                    } else {
                      return Text(
                        '\n ${snapshot.data}! PERFIL',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'CarnevaleeFreakshow',
                          color: Colors.black,
                        ),
                      );
                    }
                  },
                ),*/
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(50, 40, 50, 10),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: ImageNetwork(
                image: 'lib/images/heisenberg.jpeg',
                height: 150,
                width: 150,
                borderRadius: BorderRadius.circular(100),
                curve: Curves.easeIn,
                fitWeb: BoxFitWeb.cover,
                onLoading: const CircularProgressIndicator(
                  color: Colors.indigoAccent,
                ),
              ),
            ),
            const SizedBox(height: 40),
            FutureBuilder<String>(
              future: loginController.usuarioLogadoNome(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar o nome');
                } else {
                  return TextFormField(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    readOnly: true,
                    initialValue: snapshot.data ?? '',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Nome',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              style: const TextStyle(fontSize: 18, color: Colors.black),
              readOnly: true,
              initialValue: email ?? '',
              decoration: InputDecoration(
                labelText: 'E-mail',
                filled: true,
                fillColor: Colors.white,
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<String>(
              future: loginController.usuarioLogadoSenha(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar a senha');
                } else {
                  return TextFormField(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    readOnly: true,
                    initialValue: '••••••••',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      /*suffixIcon: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                        onPressed: () {
                        },
                      ),*/
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
                minimumSize: const Size(150, 60),
                maximumSize: const Size(150, 70),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                iniciarAudioIceCube();
                LoginController().logout();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Deslogando...\nDirecionado para a página de Login!'),
                  ),
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacementNamed(context, 'splash');
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Sair'),
                  SizedBox(width: 15),
                  Icon(Icons.logout),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.black,
        backgroundColor: const Color(0xFFFFD600),
        currentIndex: currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil👤'),
        ],
      ),
    );
  }
  Future<void> iniciarAudioIceCube() async {
    // audioPlayer = AudioPlayer();
    try {
      // Carrega o áudio de um URL absoluto para teste
      await audioPlayer.setSourceUrl('lib/audios/ice-cubes.mp3');

      // Define o volume para 50%
      await audioPlayer.setVolume(0.5);

      // Define o modo de liberação para repetir o áudio em loop
      //audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Inicia a reprodução
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Erro ao carregar áudio: $error');
      // Adicione um fallback ou uma mensagem de erro amigável ao usuário
    }
  }
}
