import 'package:flutter/material.dart';

class Promo2View extends StatelessWidget {
  const Promo2View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OPA! Eu Tanko!  '),
        backgroundColor: const Color.fromARGB(255, 2, 82, 8), // Cor do AppBar
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
              'Você encontrou o Easter Egg x2! 🎃👻',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'lib/images/ice-cream.webp', // Substitua pela imagem de promoção
              height: 200,
            ),
            const Text(
              'Sorvete Negresco:\n é feito de leite condensado, leite, biscoitos Negresco, essência de baunilha, ovos, açúcar e creme de leite.\nBem simples e delicioso! 🍦',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 7,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Como recompensa, você ganhou uma sobremesa na compra!',
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
                  text: 'DELIRIOS DA NOITE!\n\n', // Texto normal
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'Cupom promocional:  \n', // Texto da promoção com cor diferente
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue, // Cor específica para "PROMO2024"
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(                     
                      text:
                          'SOBREMESA2024\n', // Texto da promoção com cor diferente
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.red, // Cor específica para "PROMO2024"
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Necessário uma compra de outro item qualquer do cardápio. Apresente para um atendente junto ao número de pedido e irá ganhar a sobremesa extra!',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Ação do botão (voltar ao menu, aplicar o cupom, etc.)
                Navigator.pop(context); // Fecha a tela de promoção
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
                'Voltar ao Login',
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
}
