import 'dart:async';
import 'package:flutter/material.dart';

class RGBCircle extends StatefulWidget {
  final double radius;

  const RGBCircle({super.key, this.radius = 100.0});

  @override
  RGBCircleState createState() => RGBCircleState();
}

class RGBCircleState extends State<RGBCircle> {
  Color _currentColor = Colors.red;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startColorChange();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startColorChange() {
    _timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        _currentColor = Color.fromARGB(
          255,
          (timer.tick % 256),
          ((timer.tick * 2) % 256),
          ((timer.tick * 3) % 256),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _currentColor,
        ),
      ),
    );
  }
}