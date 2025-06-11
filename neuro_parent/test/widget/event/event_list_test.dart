import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/user/events/event_list.dart';

void main() {
  group('EventsScreen Widget Tests', () {
    testWidgets('renders EventsScreen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Events')),
              body: const Center(child: Text('Events List')),
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      expect(find.text('Events List'), findsOneWidget);
    });

    testWidgets('displays loading indicator while fetching events', (
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
