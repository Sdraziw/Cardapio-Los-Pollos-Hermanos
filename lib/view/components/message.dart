import 'package:flutter/material.dart';

void erro(context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 151, 3, 3).withOpacity(0.5),
      content: Text(
        msg,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(seconds: 2, milliseconds: 500),
    ),
  );
}

void sucesso(context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: const Color.fromARGB(255, 11, 123, 22).withOpacity(0.5), // Aplicar opacidade de 0.3
      content: Text(
        msg,
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}
