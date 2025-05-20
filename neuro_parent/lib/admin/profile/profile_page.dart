import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('profile_page.dart')),
      body: const Center(child: Text('This is the Profile Page')),
      backgroundColor: Colors.black,
    );
  }
}