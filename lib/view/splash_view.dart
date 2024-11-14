import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  SplashViewState createState() => SplashViewState();
}

class SplashViewState extends State<SplashView> {
  late VideoPlayerController _videoController;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    // Inicia a configuração de vídeo
    _iniciarVideo();

    // Inicia a configuração do áudio
    _iniciarAudio();

    /*// Navega para a próxima tela após a reprodução do vídeo
    _videoController.addListener(() {
      if (_videoController.value.position == _videoController.value.duration) {
        Navigator.pushReplacementNamed(context, 'login');
      }
    });
  }*/

  
    // Navega para a próxima tela após 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (_videoController.value.isInitialized && mounted) {
        Navigator.pushNamed(context, 'login');
      }
    });
  }

  /// Método para inicializar e configurar o vídeo
  Future<void> _iniciarVideo() async {
    _videoController = VideoPlayerController.asset('lib/videos/coke.mp4')
      ..initialize().then((_) {
        setState(() {}); // Atualiza o estado para reconstruir a tela
        _videoController.play();
        _videoController.setLooping(true); // Repetir vídeo em loop
      }).catchError((error) {
        debugPrint('Erro ao carregar vídeo: $error');
      });
  }

  /// Método para inicializar e configurar o áudio
  Future<void> _iniciarAudio() async {
    _audioPlayer = AudioPlayer();
    try {
      // Carrega o áudio do asset
      await _audioPlayer.setSource(AssetSource('lib/audios/breaking_bad.mp3'));

      // Define o modo de liberação para repetir o áudio em loop
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Inicia a reprodução
      await _audioPlayer.resume();
    } catch (error) {
      debugPrint('Erro ao carregar áudio: $error');
    }
  }

  @override
  void dispose() {
    _videoController.dispose(); // Libera o controlador de vídeo
    _audioPlayer.dispose(); // Libera o controlador de áudio
    super.dispose();
  }

  final String desertImage = 'lib/images/desert.jpg'; // Define the path to the desert image
  final Color containerColor = Colors.black.withOpacity(1.0); // Define the container color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _videoController.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                )
              : Center(child: CircularProgressIndicator()),
          Center(
            child: Text(
                'Los Pollos Hermanos',
                style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                  offset: Offset(1.5, 1.5),
                  blurRadius: 3.0,
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
              height: 150, // Altura fixa
              decoration: BoxDecoration(
                color: containerColor, // Usar a cor do container
                image: DecorationImage(
                  image:
                      AssetImage(desertImage), // Caminho da imagem do deserto
                  fit: BoxFit.cover, // Preenche a largura
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}