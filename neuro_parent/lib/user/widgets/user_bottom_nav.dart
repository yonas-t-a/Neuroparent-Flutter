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

}
