import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_router.dart';
import 'auth/auth_bloc.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // String? _role; // 'admin' or 'user' - No longer needed

  // void _onLogin(String role) { // No longer needed
  //   setState(() {
  //     _role = role;
  //   });
  // }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(authProvider.notifier).state = AuthInitial(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'NeuroParent',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
