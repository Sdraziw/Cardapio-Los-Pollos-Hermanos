import 'package:flutter/material.dart';
import '../model/itens_model.dart'; // Certifique-se de que o caminho está correto

class PromoView extends StatelessWidget {
  PromoView({super.key});

  final List<Prato> pedido = [];

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cê é LOCO cachoeira! '),
          backgroundColor: Colors.red, // Cor do AppBar
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
              'Você encontrou o Easter Egg 🎃👻!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'lib/images/promo_image.png', // Substitua pela imagem de promoção
              height: 200,
            ),
            const Text(
              'Hamburguer: Frango Parrudo Empanado, Molho Barbecue\nLanche parrudo 🍔200g',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Como recompensa, você ganhou um lanche de brinde na compra!',
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
                  text: 'DELIRIOS DO DESERTO!\n\n',
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
                        color: Colors.green, // Cor específica para "PROMO2024"
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(                     
                      text:
                          'LANCHE2024\n', // Texto da promoção com cor diferente
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.red, // Cor específica para "PROMO2024"
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Necessário uma compra de outro item qualquer do cardápio. Apresente para um atendente junto ao número de pedido e irá ganhar 1 lanche extra!',
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

  // Aplicar código promocional e adicionar item ao pedido se o código for válido
  void aplicarCodigoPromocional(BuildContext context, String codigo) {
    bool lanche2024 = true;
    bool sobremesa2024 = true;
    Prato? pratoGratuito;

    if ((codigo == 'SOBREMESA2024') && sobremesa2024 == true) {
      sobremesa2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻SOBREMESA2024 🍦- Sorvete Negresco",
        preco: 0.0,
        imagem: "lib/images/ice-cream.webp",
        descricao:
            "Sorvete Negresco é feito de leite condensado, leite, biscoitos Negresco, essência de baunilha, ovos, açúcar e creme de leite. Bem simples e delicioso! 🍦",
        resumo: 'Casquinha Recheada e Massa Baunilha',
        quantidade: 1,
        item_pacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Sobremesas',
      );
      // Adicione o prato gratuito ao pedido ou faça outra ação necessária
      pedido.add(pratoGratuito);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Text(
              '🌵🌕👻🍦 SOBREMESA2024🦅🌕🌵 Aplicado com sucesso.'), //futuramente colocar o expirado
        ),
      );
    } else if ((codigo == 'LANCHE2024') && lanche2024 == true) {
      lanche2024 = false;
      pratoGratuito = Prato(
        nome: "🎃👻LANCHE2024 🍔- Cê é LOCO cachoeira",
        preco: 0.0,
        imagem: 'lib/images/promo_image.png',
        descricao: "Pão de hamburguer, Frango Parrudo Empanado, Molho Barbecue",
        resumo: 'Lanche parrudo | 200g 🍔',
        quantidade: 1,
        item_pacote: 'a retirar no balcão',
        cupom: true,
        categoria: 'Lanches',
      );
      // Adicione o prato gratuito ao pedido ou faça outra ação necessária
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.withOpacity(0.5),
          content: Text(
              '🌵🌞🤤🍔 LANCHE2024🌵🌞 Aplicado com sucesso.'), //futuramente colocar o expirado
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.withOpacity(0.5),
          content: Text(
              '😕 Código promocional inválido ou já aplicado.'), //futuramente colocar o expirado
        ),
      );
    }
  }
}