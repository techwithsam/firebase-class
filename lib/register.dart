import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_class/homepage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _fullname = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _pass = TextEditingController();
  bool isOpen = true, _startloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Screen'),
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
                  'Welcome to MyPage!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Text(
                  'kindly fill in your information to create an account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _fullname,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.length < 4) {
                      return 'Full name cannot be less than 6 characters';
                    } else if (!value.contains(' ')) {
                      return 'Kindly enter your full name';
                    } else if (value.split(' ')[1].length < 2) {
                      return 'Kindly enter your full name';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter your full name',
                    hintText: 'John Doe',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white38,
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
                const SizedBox(height: 16),
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
                              handleRegister(_email.text, _pass.text);
                            }
                          },
                          color: Colors.blue,
                          child: const Text(
                            'Register Me',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: 'Have an account? ',
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Login Here',
                        style: const TextStyle(color: Colors.blue),
                        recognizer: TapGestureRecognizer()
                          ..onTap =
                              () => Navigator.pushNamed(context, '/login'),
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

  Future<void> handleRegister(String email, String password) async {
    startLoading();
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      )
          .then((value) {
        stopLoading();
        snackBar('Registration successful.');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const MyHomePage(),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      stopLoading();
      if (e.code == 'weak-password') {
        snackBar('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        snackBar('The account already exists for that email.');
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
    _fullname = TextEditingController();
    _email = TextEditingController();
    _pass = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _fullname.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }
}
