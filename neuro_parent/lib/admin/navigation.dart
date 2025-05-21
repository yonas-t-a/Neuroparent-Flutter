import 'package:flutter/material.dart';
import 'home_page.dart';
import 'articles/article_list.dart';
import 'articles/create_article.dart';
import 'articles/edit_article.dart';
import 'events/event_list.dart';
import 'events/create_event.dart';
import 'events/edit_event.dart';
import 'events/registered_events.dart';
import 'profile/profile_page.dart';
import 'add_page.dart';

enum AdminRoute {
  home,
  articles,
  events,
  registeredEvents,
  profile,
  add,
  createArticle,
  editArticle,
  createEvent,
  editEvent,
}

final _adminPages = [
  {'label': 'Home', 'route': AdminRoute.home, 'widget': AdminHomePage()},
  {'label': 'Articles', 'route': AdminRoute.articles, 'widget': ArticleListPage()},
  {'label': 'Events', 'route': AdminRoute.events, 'widget': EventListPage()},
  {'label': 'Registered Events', 'route': AdminRoute.registeredEvents, 'widget': RegisteredEventsPage()},
  {'label': 'Profile', 'route': AdminRoute.profile, 'widget': ProfilePage()},
  {'label': 'Add', 'route': AdminRoute.add, 'widget': null}, // handled specially
];

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  AdminRoute _currentRoute = AdminRoute.home;

  void _onNavBarTap(int idx) {
    setState(() {
      _currentRoute = _adminPages[idx]['route'] as AdminRoute;
    });
  }

  void _navigateTo(AdminRoute route) {
    setState(() {
      _currentRoute = route;
    });
  }

  Widget _getPage() {
    switch (_currentRoute) {
      case AdminRoute.home:
        return AdminHomePage();
      case AdminRoute.articles:
        return ArticleListPage();
      case AdminRoute.events:
        return EventListPage();
      case AdminRoute.registeredEvents:
        return RegisteredEventsPage();
      case AdminRoute.profile:
        return ProfilePage();
      case AdminRoute.add:
        return AddPage(
          onNavigate: _navigateTo,
        );
      case AdminRoute.createArticle:
        return CreateArticlePage();
      case AdminRoute.editArticle:
        return EditArticlePage();
      case AdminRoute.createEvent:
        return CreateEventPage();
      case AdminRoute.editEvent:
        return EditEventPage();
      default:
        return AdminHomePage();
    }
  }

  int _getNavBarIndex() {
    final idx = _adminPages.indexWhere((p) => p['route'] == _currentRoute);
    return idx == -1 ? 0 : idx;
  }

  String _getAppBarTitle() {
    switch (_currentRoute) {
      case AdminRoute.home:
        return 'home_page.dart';
      case AdminRoute.articles:
        return 'article_list.dart';
      case AdminRoute.events:
        return 'event_list.dart';
      case AdminRoute.registeredEvents:
        return 'registered_events.dart';
      case AdminRoute.profile:
        return 'profile_page.dart';
      case AdminRoute.add:
        return 'add_page.dart';
      case AdminRoute.createArticle:
        return 'create_article.dart';
      case AdminRoute.editArticle:
        return 'edit_article.dart';
      case AdminRoute.createEvent:
        return 'create_event.dart';
      case AdminRoute.editEvent:
        return 'edit_event.dart';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(_getAppBarTitle(), style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white,
        currentIndex: _getNavBarIndex(),
        type: BottomNavigationBarType.fixed,
        items: _adminPages
            .map((p) => BottomNavigationBarItem(
                  icon: const Icon(Icons.circle),
                  label: p['label'] as String,
                ))
            .toList(),
        onTap: _onNavBarTap,
      ),
    );
  }
}