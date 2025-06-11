import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuro_parent/auth/auth_bloc.dart';
import 'package:neuro_parent/models/user.dart';
import 'package:neuro_parent/admin/events/create_event.dart';
import 'package:neuro_parent/repositories/auth_repository.dart';

void main() {
  group('CreateEventPage Widget Tests', () {
    testWidgets('renders CreateEventPage correctly', (
      WidgetTester tester,
    ) async {
      // Mock the authProvider to simulate an authenticated admin user
      final router = GoRouter(
        initialLocation: '/admin/create-event',
        routes: [
          GoRoute(
            path: '/admin/create-event',
            builder: (context, state) => const CreateEventPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthNotifier(AuthRepository())
                ..state = AuthSuccess(
                  User(
                    userId: 1,
                    name: 'Admin',
                    email: 'admin@test.com',
                    role: 'admin',
                  ),
                  token: 'mockToken',
                ),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the presence of key UI elements
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('New Event'), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Add Event'), findsOneWidget);
    });

    testWidgets('displays error messages when form is submitted empty', (
      WidgetTester tester,
    ) async {
      // Mock the authProvider to simulate an authenticated admin user
      final router = GoRouter(
        initialLocation: '/admin/create-event',
        routes: [
          GoRoute(
            path: '/admin/create-event',
            builder: (context, state) => const CreateEventPage(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith(
              (ref) => AuthNotifier(AuthRepository())
                ..state = AuthSuccess(
                  User(
                    userId: 1,
                    name: 'Admin',
                    email: 'admin@test.com',
                    role: 'admin',
                  ),
                  token: 'mockToken',
                ),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the submit button
      await tester.tap(find.text('Add Event'));
      await tester.pump();

      // Verify error messages for required fields
      expect(find.text('Required'), findsWidgets);
    });
  });
}
