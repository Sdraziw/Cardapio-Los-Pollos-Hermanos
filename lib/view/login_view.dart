import 'package:flutter/material.dart';
import 'package:los_pollos_hermanos_en/controller/login_controller.dart';
import 'package:shared_preferences/shared_preferences.dart'; // To save the "Remember Me" state locally
import 'dart:math'; // To generate random colors
import 'package:audioplayers/audioplayers.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late AudioPlayer audioPlayer = AudioPlayer();
  final formKey = GlobalKey<FormState>();
  Color backgroundColor = const Color(0xFFFFD600);
  final primaryColor = const Color.fromARGB(255, 0, 0, 0);

  final txtEmail = TextEditingController();
  final txtPassword = TextEditingController();

  bool _rememberMe = false;
  bool _obscureText = true;
  int clickCount = 0;

  @override
  void initState() {
    super.initState();
    _loadRememberMe(); // Loads the "Remember Me" state
  }

  // Function to load the "Remember Me" state and credentials
  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        txtEmail.text = prefs.getString('email') ?? '';
        txtPassword.text = prefs.getString('Password') ?? '';
      }
    });
  }

  // Function to save the "Remember Me" state and credentials
  void _saveRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      prefs.setString('email', txtEmail.text);
      prefs.setString('Password', txtPassword.text);
    } else {
      prefs.remove('email');
      prefs.remove('Password');
    }
  }

  // Function to generate a random color
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    String desertImage = (clickCount >= 4 && clickCount < 10)
        ? "lib/images/desert1.png"
        : (clickCount >= 38)
            ? "lib/images/giphy.gif"
            : "lib/images/desert.png";

    Color containerColor = (clickCount >= 4 && clickCount < 10)
        ? const Color.fromARGB(0, 0, 0, 0)
        : Colors.transparent;

    backgroundColor = clickCount >= 4 ? Colors.black : const Color(0xFFFFD600);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            color: backgroundColor,
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 60, 50, 60),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Image(
                      image: AssetImage("lib/images/logo.png"),
                      width: 200,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('Login',
                            style: TextStyle(
                              fontSize: 18,
                              color:
                                  clickCount >= 4 ? Colors.white : primaryColor,
                            )),
                      ],
                    ),
                    const SizedBox(height: 5),
                    TextFormField(
                      controller: txtEmail,
                      style: TextStyle(
                        fontSize: 18,
                        color: clickCount >= 4 ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(clickCount >= 4
                            ? Icons.email_outlined
                            : Icons.email),
                        filled: true,
                        fillColor:
                            clickCount >= 4 ? Colors.black54 : Colors.white,
                        labelText: 'E-mail',
                        labelStyle: TextStyle(
                          color: clickCount >= 4 ? Colors.white : Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: clickCount >= 4
                                  ? Colors.white
                                  : primaryColor),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: txtPassword,
                      style: TextStyle(
                        fontSize: 18,
                        color: clickCount >= 4 ? Colors.white : Colors.black,
                      ),
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: Icon(clickCount >= 4
                            ? Icons.lock_outlined
                            : Icons.lock),
                        filled: true,
                        fillColor:
                            clickCount >= 4 ? Colors.black54 : Colors.white,
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: clickCount >= 4 ? Colors.white : Colors.black,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: clickCount >= 4
                                  ? Colors.white
                                  : primaryColor),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color:
                                clickCount >= 4 ? Colors.white : Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                            _saveRememberMe(); // Saves the checkbox state
                          },
                          activeColor: Colors.blue,
                          checkColor: Colors.white,
                        ),
                        Text(
                          'Remember Me',
                          style: TextStyle(
                              color: clickCount >= 4
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        const SizedBox(width: 30),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'forgot_password');
                          },
                          child: Text(
                            "Forgot Password",
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  clickCount >= 4 ? Colors.white : Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(300, 50),
                        backgroundColor: clickCount >= 4
                            ? primaryColor
                            : const Color.fromARGB(255, 0, 0, 0),
                        foregroundColor: clickCount >= 4
                            ? const Color.fromARGB(255, 255, 255, 255)
                            : const Color.fromARGB(255, 255, 255, 255),
                        textStyle: const TextStyle(fontSize: 15),
                        side: BorderSide(
                          color: clickCount >= 4
                              ? Colors.white
                              : const Color.fromARGB(255, 0, 0, 0),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          LoginController().login(
                            context,
                            txtEmail.text,
                            txtPassword.text,
                          );
                          _saveRememberMe(); // Saves the credentials
                        }
                      },
                      child: const Text('Login'),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(300, 50),
                        backgroundColor: const Color.fromRGBO(122, 124, 125, 1),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 15),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, 'registration');
                      },
                      child: const Text('Register'),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: clickCount >= 4
                ? clickCount + 115
                : clickCount + 80, // Adjust vertical position
            left: MediaQuery.of(context).size.width / 3 - 30 + clickCount * -4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  clickCount++;
                  if (clickCount == 1) {
                    startEagleAudio();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.black.withOpacity(0.2),
                        content: Text(
                          '☼ Sun with shadow? ${(clickCount)} time I see it!',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 2) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.black.withOpacity(0.2),
                        content: Text(
                          '☀ Sun has no shadow! ${(clickCount)} time observing!',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 2),
                        backgroundColor: Colors.black.withOpacity(0.2),
                        content: Text(
                          '☀ Sun moving or am I hallucinating for the ${(clickCount)} time',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 4) {
                    startWindAudio();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 3),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        content: Text(
                          '◌ Moon!? Night!? 🌙 Hallucinating ${(clickCount)} time\nI thought it was the heat! But it wasn\'t! It\'s HUNGER!',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 1),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        content: Text(
                          'I must be hungry, for the ${(clickCount)} time, I\'m hallucinating',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green.withOpacity(0.2),
                        content: Text(
                          'Easter Egg activated!🍀',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );

                    Navigator.pushNamed(context, 'promo');
                  } else if (clickCount == 10) {
                    startEagleAudio();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        padding: EdgeInsets.all(5.0),
                        backgroundColor: Colors.yellow.withOpacity(0.2),
                        content: Text(
                          'Eagle eyes! ☽',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 16) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        padding: EdgeInsets.all(10.0),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        content: Text(
                          '☽ I even liked this night theme! 🌙',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  } else if (clickCount == 37) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 5),
                        behavior: SnackBarBehavior.floating,
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        padding: EdgeInsets.all(10.0),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'This eagle is eyeing my snack!',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Check out the promotional coupon I already mentioned:',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'SNACK2024',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red, // Different color for the coupon
                              ),
                                textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (clickCount == 38) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        content: Text(
                          'Easter Egg activated *2! 🍀',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );

                    Navigator.pushNamed(context, 'promo2');
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeInOut, // Smooth transition
                transform: Matrix4.translationValues(0,
                    clickCount >= 4 ? -20 : 0, 0), // Moves the circle up
                width: clickCount >= 4
                    ? 50
                    : 97, // Reduces size after 4 clicks
                height: clickCount >= 4 ? 50 : 97,
                decoration: BoxDecoration(
                  color: clickCount >= 4
                      ? Colors.white
                      : const Color.fromARGB(255, 243, 135, 33),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    ' ',
                    style: TextStyle(color: Color.fromRGBO(252, 176, 64, 1)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 150, // Fixed height
              decoration: BoxDecoration(
                color: containerColor, // Use container color
                image: DecorationImage(
                  image:
                      AssetImage(desertImage), // Desert image path
                  fit: BoxFit.cover, // Fill width
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Method to initialize and configure eagle audio
  Future<void> startEagleAudio() async {
    audioPlayer = AudioPlayer();
    try {
      // Load audio from an absolute URL for testing
      await audioPlayer.setSourceUrl('lib/audios/eagle-scream.mp3');

      // Set volume to 50%
      await audioPlayer.setVolume(0.3);

      // Start playback
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Error loading audio: $error');
    }
  }

  /// Method to initialize and configure wind audio
  Future<void> startWindAudio() async {
    audioPlayer = AudioPlayer();
    try {
      // Load audio from an absolute URL for testing
      await audioPlayer.setSourceUrl('lib/audios/wind.mp3');

      // Set volume to 50%
      await audioPlayer.setVolume(0.3);

      // Start playback
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Error loading audio: $error');
    }
  }
}

// Function to perform logout (included in the menu or where appropriate)
void logout(BuildContext context) {
  Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
}
