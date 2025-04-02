import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//import '../services/message_notifier.dart';

void success(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.green),
  );
}

void error(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );
}

class LoginController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  //
  // Create a new user account
  // in Firebase Authentication
  //
  void createAccount(context, name, email, password) {
    auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      //
      // STORE the user's name in Firestore
      //
      FirebaseFirestore.instance.collection('users').add({
        'uid': value.user!.uid,
        'name': name,
        'email': email,
      });

      success(context, 'User $email successfully created.');
      Navigator.pop(context);
    }).catchError((e) {
      switch (e.code) {
        case 'email-already-in-use':
          error(context, 'This email $email is already registered.');
          break;
        case 'invalid-email':
          error(context, 'The format of the email $email is invalid.');
          break;
        default:
          error(context, 'ERROR: ${e.code.toString()}');
      }
    });
  }

  //
  // LOGIN
  // Log in a previously registered user
  // in the Firebase Authentication service
  //
  void login(context, email, password) {
    auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) {
      Navigator.pushReplacementNamed(context, 'menu');
    }).catchError((e) {
      switch (e.code) {
        case 'invalid-email':
          error(context, 'Incorrect email or password.');
          break;
        case 'invalid-credential':
          error(context, 'Incorrect email or password.');
        default:
          error(context, 'ERROR: ${e.code.toString()}');
      }
    });
  }

  //
  // FORGOT PASSWORD
  // Sends an email message for password recovery to
  // a valid email account
  //
  void forgotPassword(BuildContext context, String email) async {
    if (email.isNotEmpty) {
      try {
        await auth.sendPasswordResetEmail(email: email);
        success(context, 'Email successfully sent to $email.');
      } catch (e) {
        error(context, 'Error sending email. Check if the email is registered.'); // ${e.code.toString()}');
      }
    } else {
      error(context, 'Provide the email to recover the account.');
    }
    Navigator.pop(context);
  }

  void resetPassword(context, String newPassword) {
    if (newPassword.isNotEmpty) {
      auth.confirmPasswordReset(code: '', newPassword: newPassword);
      success(context, 'Password successfully reset.');
    } else {
      error(context, 'Provide the email to recover the account.');
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
  // Logged-in User ID
  //
  idUser() {
    return auth.currentUser!.uid;
  }

  //
  // Logged-in User Name
  //
  Future<String> loggedInUserName() async {
    var name = "";
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: idUser())
        .get()
        .then((value) {
      name = value.docs[0].data()['name'] ?? '';
    });
    return name;
  }

  Future<String> loggedInUserPassword() async {
    var password = "";
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: idUser())
        .get()
        .then((value) {
      password = value.docs[0].data()['password'] ?? '';
    });
    return password;
  }

  Future<String> loggedInUserFirstName() async {
    var fullName = "";
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: idUser())
        .get()
        .then((value) {
      fullName = value.docs[0].data()['name'] ?? '';
    });

    // Extract the first name
    var firstName = fullName.split(' ').first;
    return firstName;
  }

  Future<String> loggedInUserEmail() async {
    var email = "";
    await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: idUser())
        .get()
        .then((value) {
      email = value.docs[0].data()['email'] ?? '';
    });
    return email;
  }

  void ForgotPassword(BuildContext context, String email) {
    // Add logic to handle password reset, e.g., API call or Firebase integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password reset instructions sent to $email')),
    );
  }
}
