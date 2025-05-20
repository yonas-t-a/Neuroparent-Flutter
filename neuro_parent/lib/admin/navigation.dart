import 'package:flutter/material.dart';
import 'home_page.dart';
import 'articles/article_list.dart';
import 'events/event_list.dart';
import 'events/registered_events.dart';
import 'profile/profile_page.dart';
import 'add_page.dart';

final _adminPages = [
  {
    'label': 'Home',
    'file': 'home_page.dart',
    'widget': AdminHomePage(),
  },
  {
    'label': 'Articles',
    'file': 'article_list.dart',
    'widget': ArticleListPage(),
  },
  {
    'label': 'Events',
    'file': 'event_list.dart',
    'widget': EventListPage(),
  },
  {
    'label': 'Registered Events',
    'file': 'registered_events.dart',
    'widget': RegisteredEventsPage(),
  },
  {
    'label': 'Profile',
    'file': 'profile_page.dart',
    'widget': ProfilePage(),
  },
  {
    'label': 'Add',
    'file': 'add_page.dart',
    'widget': AddPage(),
  },
];

class AdminNavigation extends StatefulWidget {
  final int initialIndex;
  const AdminNavigation({this.initialIndex = 0, super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final page = _adminPages[_selectedIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(page['file']  as String, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: page['widget'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: _adminPages
            .map((p) => BottomNavigationBarItem(
                  icon: const Icon(Icons.circle),
                  label: p['label']  as String,
                ))
            .toList(),
        onTap: (idx) => setState(() => _selectedIndex = idx),
      ),
    );
  }
}