import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PromoView extends StatelessWidget {
  final AudioPlayer audioPlayer = AudioPlayer();
  PromoView({super.key});

  @override
  Widget build(BuildContext context) {
    startChickenAudio();
    return Scaffold(
      appBar: AppBar(
        title: const Text('You’re CRAZY waterfall!'),
        backgroundColor: Colors.red, // AppBar color
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(221, 238, 255, 0),
              Color.fromARGB(82, 255, 0, 0)
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
              'You found the Easter Egg 🎃👻!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1.5, 1.5),
                    blurRadius: 6.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'lib/images/promo_image.png', // Replace with the promotion image
              height: 200,
            ),
            const Text(
              'Burger: Breaded Chicken, Barbecue Sauce\nHearty Burger 🍔200g',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'As a reward, you won a free burger with your purchase!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 123, 58, 226),
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
                  text: 'DESERT DELIRIUMS!\n\n',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  children: [
                    TextSpan(
                      text: 'Promotional Coupon:  \n',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'SNACK2024\n',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Requires the purchase of any other menu item. Request it with your cart order and get 1 extra burger for free!',
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

  Future<void> startChickenAudio() async {
    try {
      // Load the audio from an absolute URL for testing
      await audioPlayer.setSourceUrl('lib/audios/chicken-noise.mp3');

      // Set the volume to 50%
      await audioPlayer.setVolume(0.3);

      // Start playback
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Error loading audio: $error');
      // Add a fallback or a user-friendly error message
    }
  }
}