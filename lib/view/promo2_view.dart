import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class Promo2View extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();

  Promo2View({super.key});

  @override
  Widget build(BuildContext context) {
    startIceCreamAudio();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WOW! I Can Handle It!'),
        backgroundColor: const Color.fromARGB(255, 2, 82, 8), // AppBar color
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(221, 0, 255, 85),
              Color.fromARGB(167, 39, 42, 241)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'You found the Easter Egg x2! 🎃👻',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'lib/images/ice-cream.webp', // Replace with the promotion image
              height: 200,
            ),
            const Text(
              'Negresco Ice Cream:\nMade with condensed milk, milk, Negresco cookies, vanilla essence, eggs, sugar, and cream.\nSimple and delicious! 🍦',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 7,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'As a reward, you won a dessert with your purchase!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Text.rich(
                TextSpan(
                  text: 'NIGHT DELIGHTS!\n\n', // Main text
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  children: [
                    TextSpan(
                      text: 'Promotional Coupon:  \n', // Promotion text
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue, // Specific color for "PROMO2024"
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'DESSERT2024\n', // Promotion code
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.red, // Specific color for the code
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Requires the purchase of any other menu item. Request it with your cart order and get the extra dessert for free!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Button action (return to menu, apply the coupon, etc.)
                Navigator.pop(context); // Closes the promotion screen
                Navigator.pushNamed(context, 'login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.deepPurple,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startIceCreamAudio() async {
    try {
      // Load the audio from an absolute URL for testing
      await audioPlayer.setSourceUrl('lib/audios/ice-cream-truck.mp3');

      // Set the volume to 50%
      await audioPlayer.setVolume(0.1);

      // Start playback
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Error loading audio: $error');
      // Add a fallback or a user-friendly error message
    }
  }
}
