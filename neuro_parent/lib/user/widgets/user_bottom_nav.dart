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

 
}
