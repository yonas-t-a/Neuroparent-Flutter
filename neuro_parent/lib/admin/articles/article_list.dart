import 'package:flutter/material.dart';

class ArticleListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('article_list.dart')),
      body: const Center(child: Text('This is the Article List Page')),
      backgroundColor: Colors.black,
    );
  }
}