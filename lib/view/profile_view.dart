import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:los_pollos_hermanos_en/controller/login_controller.dart';
import 'package:audioplayers/audioplayers.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
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
      Navigator.pushReplacementNamed(context, 'history');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, 'profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFFFD600),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('User Profile'),
                Image.network(
                  'lib/images/heads.png',
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 10),
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
              future: loginController.loggedInUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading name');
                } else {
                  return TextFormField(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    readOnly: true,
                    initialValue: snapshot.data ?? '',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Name',
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
                labelText: 'Email',
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
              future: loginController.loggedInUserPassword(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error loading password');
                } else {
                  return TextFormField(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    readOnly: true,
                    initialValue: '••••••••',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                startIceCubeAudio();
                LoginController().logout();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Logging out...\nRedirecting to the Login page!'),
                  ),
                );

                Future.delayed(const Duration(seconds: 2), () {
                  Navigator.pushReplacementNamed(context, 'splash');
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Logout'),
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
              icon: Icon(Icons.receipt_long), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile👤'),
        ],
      ),
    );
  }

  Future<void> startIceCubeAudio() async {
    try {
      // Load the audio from an absolute URL for testing
      await audioPlayer.setSourceUrl('lib/audios/ice-cubes.mp3');

      // Set the volume to 50%
      await audioPlayer.setVolume(0.5);

      // Start playback
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Error loading audio: $error');
    }
  }
}
