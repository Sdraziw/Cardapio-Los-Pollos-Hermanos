import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../view/components/mensagem.dart';

class LoginController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  //
  // Criação de um nova conta de usuário
  // no Firebase Authentication
  //
  void criarConta(context, nome, email, senha) {
    auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    ).then((value) {

      //
      // ARMAZENAR o nome do usuário no Firestore
      //
      FirebaseFirestore.instance.collection('usuarios')
        .add(
          {
            'uid' : value.user!.uid,
            'nome' : nome,
          }
        );

      sucesso(context, 'Usuário criado com sucesso.');
      Navigator.pop(context);
    }).catchError((e) {
      switch (e.code) {
        case 'email-already-in-use':
          erro(context, 'O email já foi cadastrado.');
          break;
        case 'invalid-email':
          erro(context, 'O formato do email é inválido.');
          break;
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // LOGIN
  // Efetuar o login de um usuário previamente cadastrado
  // no serviço Firebase Authentication
  //
  void login(context, email, senha) {
    auth.signInWithEmailAndPassword(
      email: email, password: senha)
    .then((value) {
      Navigator.pushReplacementNamed(context, 'menu');
    }).catchError((e) {
      switch (e.code) {
        case 'invalid-email':
          erro(context, 'E-mail ou Senha incorretos.');
          break;
        case 'invalid-credential':
          erro(context, 'E-mail ou Senha incorretos.');
        default:
          erro(context, 'ERRO: ${e.code.toString()}');
      }
    });
  }

  //
  // ESQUECEU A SENHA
  // Envia uma mensagem de email para recuperação de senha para
  // um conta de email válida
  //
  void esqueceuSenha(context, String email) {
    if (email.isNotEmpty) {
      auth.sendPasswordResetEmail(email: email);
      sucesso(context, 'Email enviado com sucesso.');
    } else {
      erro(context, 'Informe o email para recuperar a conta.');
    }
    Navigator.pop(context);
  }

  void redefinirSenha(context, String novaSenha) {
    if (novaSenha.isNotEmpty) {
      auth.confirmPasswordReset(code: '', newPassword: novaSenha);
      sucesso(context, 'Email enviado com sucesso.');
    } else {
      erro(context, 'Informe o email para recuperar a conta.');
    }
    Navigator.pop(context);
  }

  //
  // LOGOUT
  //
  logout() {
    auth.signOut();
  }

  //
  // ID do Usuário Logado
  //
  idUsuario() {
    return auth.currentUser!.uid;
  }

  //
  // NOME do Usuário Logado
  //
  Future<String> usuarioLogadoNome() async {
    var nome = "";
    await FirebaseFirestore.instance
      .collection('usuarios')
      .where('uid', isEqualTo: idUsuario())
      .get()
      .then((value){
        nome = value.docs[0].data()['nome']  ?? '';
      });
    return nome;
  }

  Future<String> usuarioLogadoSenha() async {
    var senha = "";
    await FirebaseFirestore.instance
      .collection('usuarios')
      .where('uid', isEqualTo: idUsuario())
      .get()
      .then((value){
        senha = value.docs[0].data()['senha']  ?? '';
      });
    return senha;
  }
}