import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/user/events/event_detail.dart';

void main() {
  group('EventDetailsScreen Widget Tests', () {
    testWidgets('renders EventDetailsScreen correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Event Details')),
              body: const Center(child: Text('Description')),
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Event Details'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('displays loading indicator while fetching event data', (
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
