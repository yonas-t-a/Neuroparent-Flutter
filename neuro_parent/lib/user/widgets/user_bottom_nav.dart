import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth_bloc.dart';

class UserBottomNav extends ConsumerWidget {
  final int currentIndex;
  const UserBottomNav({required this.currentIndex, super.key});

  static const _routes = [
    '/home',
    '/events',
    '/registered',
    '/articles',
    '/profile',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState is AuthSuccess && authState.user.role == 'admin';

    // Build items list
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.event_outlined),
        activeIcon: Icon(Icons.event),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.app_registration),
        activeIcon: Icon(Icons.app_registration),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.article_outlined),
        activeIcon: Icon(Icons.article),
        label: '',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: '',
      ),
    ];

    // Add the "Add" button at the end if admin
    if (isAdmin) {
      items.add(
        BottomNavigationBarItem(
          icon: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.red, size: 20),
          ),
          activeIcon: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.red, size: 20),
          ),
          label: '',
        ),
      );
    }

    // Adjust routes for admin (add a route for the add button)
    final routes = List<String>.from(_routes);
    if (isAdmin) {
      routes.add('/admin/add');
    }

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (isAdmin && routes[index] == '/admin/add') {
          // If already on /admin/add and tapping the add button, force a rebuild by providing a unique key.
          context.go('/admin/add', extra: UniqueKey());
        } else if (index != currentIndex) {
          context.go(routes[index]);
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color.fromARGB(255, 87, 90, 95),
      unselectedItemColor: const Color(0xFF6B7280),
      items: items,
    );
  }
}
