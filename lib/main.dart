import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_class/firebase_options.dart';
import 'package:firebase_class/hive_database.dart';
import 'package:firebase_class/homepage.dart';
import 'package:firebase_class/auth/login.dart';
import 'package:firebase_class/auth/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final hiveDatebase = HiveDatabase();
  await hiveDatebase.openBox();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: _user != null ? '/home' : '/',
      routes: {
        '/': (_) => const RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/home': (_) => const MyHomePage(),
      },
    );
  }
}
