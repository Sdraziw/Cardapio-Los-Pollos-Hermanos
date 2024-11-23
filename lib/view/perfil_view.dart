import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:los_pollos_hermanos/controller/login_controller.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => PerfilViewState();
}

class PerfilViewState extends State<PerfilView> {
  final LoginController _controller = LoginController();
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Perfil de Usuário'),
                Image.network(
                  'lib/images/heads.png',
                  height: 40,
                ),
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
              future: _controller.usuarioLogadoNome(),
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
              future: _controller.usuarioLogadoSenha(),
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
                    obscureText: obscureText_,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            obscureText_ = !obscureText_;
                          });
                        },
                      ),
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
                LoginController().logout();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deslogando...\nDirecionado para a página de Login!'),
                  ),
                );

                Future.delayed(const Duration(seconds: 1), () {
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
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil👤'),
        ],
      ),
    );
  }
}