import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  late VideoPlayerController videoController;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    // Initializes video configuration
    _initializeVideo();

    // Initializes audio configuration
    _initializeAudio();

    // Shows the SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 7),
          backgroundColor: Colors.white.withOpacity(0.5),
          content: DefaultTextStyle(
            style: TextStyle(fontSize: 9),
            child: Text(
              'It’s so hot, I must be hallucinating. I better order a cold drink right away!\nI’m thirsty!\nEspecially while listening to this series music!',
            ),
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 5),
          backgroundColor: Colors.white.withOpacity(0.5),
          content: DefaultTextStyle(
            style: TextStyle(fontSize: 9),
            child: Text(
              'Look at this scorching sun, I’m getting thirsty just looking at it!\nIs there any shade or something to drink around here?',
            ),
          ),
        ),
      );
    });

    // Navigates to the next screen after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      if (videoController.value.isInitialized && mounted) {
        Navigator.pushNamed(context, 'login');
      }
    });
  }

  /// Method to initialize and configure the video
  Future<void> _initializeVideo() async {
    videoController = VideoPlayerController.asset('lib/videos/coke.mp4')
      ..initialize().then((_) {
        setState(() {}); // Updates the state to rebuild the screen
        videoController.play();
        // videoController.setLooping(false); // Repeat video in a loop
      }).catchError((error) {
        debugPrint('Error loading video: $error');
      });
  }

  /// Method to initialize and configure the audio
  Future<void> _initializeAudio() async {
    audioPlayer = AudioPlayer();
    try {
      // Loads the audio from an absolute URL for testing
      await audioPlayer.setSourceUrl('lib/audios/breaking_bad.mp3');

      // Sets the volume to 50%
      await audioPlayer.setVolume(0.3);

      // Sets the release mode to repeat the audio in a loop
      // audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Starts playback
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Error loading audio: $error');
      // Add a fallback or a user-friendly error message
    }
  }

  /// Method to stop the audio
  Future<void> stopAudio() async {
    try {
      await audioPlayer.stop();
    } catch (error) {
      debugPrint('Error stopping audio: $error');
    }
  }

  @override
  void dispose() {
    videoController.dispose(); // Releases the video controller
    stopAudio(); // Stops the audio before releasing the controller
    audioPlayer.dispose(); // Releases the audio controller
    super.dispose();
  }

  final String desertImage =
      'lib/images/desert1.png'; // Defines the path to the desert image
  final Color containerColor =
      Colors.black.withOpacity(1.0); // Defines the container color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: videoController.value.aspectRatio,
                  child: VideoPlayer(videoController),
                )
              : Center(child: CircularProgressIndicator()),
          Center(
            child: Text(
              'Los Pollos Hermanos',
              style: TextStyle(
                fontFamily: 'CarnevaleeFreakshow', // Update to your font name
                fontSize: 30,
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
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 150, // Fixed height
              decoration: BoxDecoration(
                color: containerColor, // Use the container color
                image: DecorationImage(
                  image: AssetImage(desertImage), // Path to the desert image
                  fit: BoxFit.cover, // Fills the width
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1), // Border color
                  width: 3.0, // Border width
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}