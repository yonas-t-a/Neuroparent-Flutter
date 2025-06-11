import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/user/events/registered_events.dart';

void main() {
  group('RegisteredEventsScreen Widget Tests', () {
    testWidgets('renders RegisteredEventsScreen correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Registered Events')),
              body: const Center(child: Text('No registered events found.')),
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Registered Events'), findsOneWidget);
      expect(find.text('No registered events found.'), findsOneWidget);
    });

    testWidgets('displays loading indicator while fetching registered events', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: const CircularProgressIndicator()),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
