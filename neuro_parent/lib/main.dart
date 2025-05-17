import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroParent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        useMaterial3: true,
      ),
      initialRoute: '/login_page',
      routes: {
        '/login_page': (context) => const LoginPage(),
       '/signup_page': (context) => const SignUpPage(),
      }
    );
  }
}
