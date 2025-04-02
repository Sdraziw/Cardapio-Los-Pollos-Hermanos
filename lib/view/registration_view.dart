import 'package:flutter/material.dart';
import 'package:los_pollos_hermanos_en/controller/login_controller.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _obscureText2 = true;

  final txtFullName = TextEditingController();
  // final txtUsername = TextEditingController();
  final txtEmail = TextEditingController();
  final txtConfirmEmail = TextEditingController();
  final txtPassword = TextEditingController();
  final txtConfirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFD600),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFD600),
        title: Text('User Registration'), // Screen title
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
                // Full Name
                TextFormField(
                  controller: txtFullName,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Email
                TextFormField(
                    controller: txtEmail,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') // Regular expression to validate email
                          .hasMatch(value)) {
                        return 'Invalid email format';
                      }
                      return null;
                    }),
                SizedBox(height: 20),

                // Confirm Email
                TextFormField(
                  controller: txtConfirmEmail,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirm Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value != txtEmail.text) {
                      return 'Emails do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password
                TextFormField(
                  controller: txtPassword,
                  style: const TextStyle(fontSize: 18),
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Password',
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
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Confirm Password
                TextFormField(
                  controller: txtConfirmPassword,
                  style: const TextStyle(fontSize: 18),
                  obscureText: _obscureText2,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirm Password',
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
                        value != txtPassword.text) {
                      return 'Passwords do not match';
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
                      if (txtEmail.text != txtConfirmEmail.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Emails do not match')),
                        );
                      } else if (txtPassword.text != txtConfirmPassword.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Passwords do not match')),
                        );
                      } else {
                        LoginController().createAccount(
                          context,
                          txtFullName.text,
                          txtEmail.text,
                          txtPassword.text,
                        );
                      }
                    }
                  },
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
