/* RF002 Cadastro de Usuário
●	Cadastro de usuário possui todos os campos necessários
●	Validação correta de nome,  e-mail, senha e confirmação de senha.
*/

import 'package:flutter/material.dart';
import 'package:preojeto/model/user_model.dart';

class CadastroView extends StatefulWidget {
  const CadastroView({super.key});

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  _CadastroViewState();
  final formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _obscureText2 = true;

  final txtNome = TextEditingController();
  final txtUsuario = TextEditingController();
  final txtEmail = TextEditingController();
  final txtConfirmaEmail = TextEditingController();
  final txtSenha = TextEditingController();
  final txtConfirmaSenha = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD600),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD600),
      ),
      body: Container(
        color: const Color(0xFFFFD600),
        child: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(50, 60, 50, 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Nome Completo
                TextFormField(
                  controller: txtNome,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe seu nome completo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Usuário
                TextFormField(
                  controller: txtUsuario,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe seu usuário';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // E-mail
                TextFormField(
                    controller: txtEmail,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe seu e-mail';
                      } else if (!RegExp(
                              r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(value)) {
                        return 'Formato de e-mail inválido';
                      }
                      return null;
                    }),
                SizedBox(height: 20),

                // Confirmar e-mail
                TextFormField(
                  controller: txtConfirmaEmail,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirmar e-mail',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value != txtEmail.text) {
                      return 'Os e-mails não correspondem';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Senha
                TextFormField(
                  controller: txtSenha,
                  style: const TextStyle(fontSize: 18),
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
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
                      return 'Por favor, insira sua senha';
                    } else if (value.length < 6) {
                      return 'A senha precisa ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Confirmar Senha
                TextFormField(
                  controller: txtConfirmaSenha,
                  style: const TextStyle(fontSize: 18),
                  obscureText: _obscureText2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirmar Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText2 ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText2 = !_obscureText2;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value != txtSenha.text) {
                      return 'As senhas não correspondem';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 50),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(300, 50),
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 15),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Se o formulário for válido, adiciona o usuário
                      String nome = txtNome.text;
                      String email = txtEmail.text;
                      String senha = txtSenha.text;

                      // Adiciona o novo usuário ao vetor
                      Usuario.adicionarUser(nome, email, senha);

                      // Após cadastro, redireciona o usuário ou mostra uma mensagem de sucesso
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
