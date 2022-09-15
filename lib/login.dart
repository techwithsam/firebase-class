import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_class/homepage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  bool isOpen = true, _startloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Screen'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Text(
                  'Welcome back!!!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'kindly fill in your information to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Email address cannot be less than 6 characters';
                    } else if (!value.contains('@')) {
                      return 'Invalid email address';
                    } else if (!value.contains('.')) {
                      return 'Invalid email address';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter your email address',
                    hintText: 'example@gmail.com',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white38,
                    prefixIcon: Icon(Icons.mail),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pass,
                  obscureText: isOpen,
                  keyboardType: TextInputType.phone,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Password cannot be less than 6';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    hintText: '*******',
                    border: const OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white38,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isOpen = !isOpen;
                        });
                      },
                      icon: isOpen
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _startloading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: 440,
                        height: 40,
                        child: MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              handleLogin(_email.text, _pass.text);
                            }
                          },
                          color: Colors.blue,
                          child: const Text(
                            'Log Me In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Register Here',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamed(context, '/'),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> handleLogin(String email, String password) async {
    startLoading();
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        stopLoading();
        snackBar('Login successful.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MyHomePage(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      stopLoading();
      if (e.code == 'user-not-found') {
        snackBar('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        snackBar('Wrong password provided for that user.');
      }
    } catch (e) {
      stopLoading();
      snackBar(e.toString());
    }
  }

  void startLoading() {
    setState(() => _startloading = true);
  }

  void stopLoading() {
    setState(() => _startloading = false);
  }

  snackBar(String title) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
  }

  @override
  void initState() {
    _email = TextEditingController();
    _pass = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }
}
