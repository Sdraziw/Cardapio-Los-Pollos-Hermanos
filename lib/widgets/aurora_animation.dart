import 'dart:math';
import 'package:flutter/material.dart';

class AuroraAnimation extends StatefulWidget {
  const AuroraAnimation({super.key});

  @override
  AuroraAnimationState createState() => AuroraAnimationState();
}

class AuroraAnimationState extends State<AuroraAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: AuroraPainter(controller),
        child: Container(),
      ),
    );
  }
}

class AuroraPainter extends CustomPainter {
  final Animation<double> animation;
  AuroraPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.greenAccent.withOpacity(0.4),
          Colors.blueAccent.withOpacity(0.3),
          Colors.purpleAccent.withOpacity(0.3),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path = Path();
    final double waveHeight = 100;
    final double waveSpeed = animation.value * 100;

    for (double i = 0; i < size.width; i++) {
      double y = sin((i / size.width * 2 * pi) + waveSpeed) * waveHeight;
      path.lineTo(i, size.height / 2 + y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
