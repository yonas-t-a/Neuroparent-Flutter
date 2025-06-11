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
        ProviderScope(child: MaterialApp(home: EventDetailsScreen(eventId: 1))),
      );

      expect(find.text('Description'), findsOneWidget);
    });
  });
}
