import 'package:flutter/material.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'admin/navigation.dart';
import 'user/navigation.dart';
import 'admin/articles/create_article.dart';
import 'admin/articles/edit_article.dart';
import 'admin/events/create_event.dart';
import 'admin/events/edit_event.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _role; // 'admin' or 'user'

  void _onLogin(String role) {
    setState(() {
      _role = role;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_role == 'admin') {
      child = const AdminNavigation();
    } else if (_role == 'user') {
      child = const UserNavigation();
    } else {
      child = LoginPage(onLogin: _onLogin);
    }
    return MaterialApp(
      title: 'NeuroParent',
      debugShowCheckedModeBanner: false,
      home: child,
      routes: {
        '/articles/create_article': (context) => CreateArticlePage(),
        '/articles/edit_article': (context) => EditArticlePage(),
        '/events/create_event': (context) => CreateEventPage(),
        '/events/edit_event': (context) => EditEventPage(),
      },
    );
  }
}
