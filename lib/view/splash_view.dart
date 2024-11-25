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
    // Inicia a configuração de vídeo
    _iniciarVideo();

    // Inicia a configuração do áudio
    _iniciarAudio();

    // Mostra o SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 7),
          backgroundColor: Colors.white.withOpacity(0.5),
          content: DefaultTextStyle(
            style: TextStyle(fontSize: 9),
            child: Text(
              'Que calor, devo estar delirando melhor pedir logo uma bebida bem gelada!\nEstou com sede!\nAinda mais escutando essa música da série!',
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
              'Olhe para esse sol escaldante, estou ficando com sede só de olhar!\n Será que tem uma sombra ou algo para beber por aqui?',
            ),
          ),
        ),
        
      );
    });

    // Navega para a próxima tela após 5 segundos
    Future.delayed(const Duration(seconds: 7), () {
      if (videoController.value.isInitialized && mounted) {
        Navigator.pushNamed(context, 'login');
      }
    });
  }

  /// Método para inicializar e configurar o vídeo
  Future<void> _iniciarVideo() async {
    videoController = VideoPlayerController.asset('lib/videos/coke.mp4')
      ..initialize().then((_) {
        setState(() {}); // Atualiza o estado para reconstruir a tela
        videoController.play();
        //videoController.setLooping(false); // Repetir vídeo em loop
      }).catchError((error) {
        debugPrint('Erro ao carregar vídeo: $error');
      });
  }

  /// Método para inicializar e configurar o áudio
  Future<void> _iniciarAudio() async {
    audioPlayer = AudioPlayer();
    try {
      // Carrega o áudio de um URL absoluto para teste
      await audioPlayer.setSourceUrl('lib/audios/breaking_bad.mp3');

      // Define o volume para 50%
      await audioPlayer.setVolume(0.3);

      // Define o modo de liberação para repetir o áudio em loop
      //audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Inicia a reprodução
      await audioPlayer.resume();
    } catch (error) {
      debugPrint('Erro ao carregar áudio: $error');
      // Adicione um fallback ou uma mensagem de erro amigável ao usuário
    }
  }

  /// Método para parar o áudio
  Future<void> pararAudio() async {
    try {
      await audioPlayer.stop();
    } catch (error) {
      debugPrint('Erro ao parar áudio: $error');
    }
  }

  @override
  void dispose() {
    videoController.dispose(); // Libera o controlador de vídeo
    pararAudio(); // Para o áudio antes de liberar o controlador
    audioPlayer.dispose(); // Libera o controlador de áudio
    super.dispose();
  }

  final String desertImage =
      'lib/images/deserto1.png'; // Define the path to the desert image
  final Color containerColor =
      Colors.black.withOpacity(1.0); // Define the container color

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
                fontFamily: 'CarnevaleeFreakshow', // Atualize para o nome da sua fonte
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
              height: 150, // Altura fixa
              decoration: BoxDecoration(
                color: containerColor, // Usar a cor do container
                image: DecorationImage(
                  image: AssetImage(desertImage), // Caminho da imagem do deserto
                  fit: BoxFit.cover, // Preenche a largura
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1), // Cor da borda
                  width: 3.0, // Largura da borda
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}