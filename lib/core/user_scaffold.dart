import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_bloc.dart';

class UserScaffold extends ConsumerWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final String? title;

  const UserScaffold({super.key, required this.body, this.appBar, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAdmin = authState is AuthSuccess && authState.user.role == 'admin';

    return Scaffold(
      appBar:
          appBar ??
          AppBar(
            title: title != null ? Text(title!) : null,
            actions: [
              if (isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => context.go('/admin/add'),
                  ),
                ),
            ],
          ),
      body: body,
    );
  }
}
