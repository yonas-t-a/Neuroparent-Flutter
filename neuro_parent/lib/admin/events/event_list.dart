import 'package:flutter/material.dart';

class EventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('event_list.dart')),
      body: const Center(child: Text('This is the Event List Page')),
      backgroundColor: Colors.black,
    );
  }
}