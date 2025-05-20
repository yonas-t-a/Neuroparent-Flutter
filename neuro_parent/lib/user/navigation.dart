import 'package:flutter/material.dart';

final _userPages = [
  {'label': 'Home', 'file': 'home_page.dart'},
  {'label': 'Events', 'file': 'event_list.dart'},
  {'label': 'Articles', 'file': 'article_list.dart'},
  {'label': 'Registered Events', 'file': 'registered_events.dart'},
  {'label': 'Profile', 'file': 'profile_page.dart'},
];

class UserNavigation extends StatefulWidget {
  final int initialIndex;
  const UserNavigation({this.initialIndex = 0, super.key});

  @override
  State<UserNavigation> createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final page = _userPages[_selectedIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(page['file']!, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _userPages.length,
        itemBuilder: (context, idx) => ListTile(
          title: Text(
            _userPages[idx]['label']!,
            style: TextStyle(
              color: idx == _selectedIndex ? Colors.blue : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () => setState(() => _selectedIndex = idx),
        ),
      ),
    );
  }
}