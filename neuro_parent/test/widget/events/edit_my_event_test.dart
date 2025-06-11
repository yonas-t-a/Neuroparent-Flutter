import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/admin/events/edit_my_events.dart';

void main() {
  group('EditMyEventPage Widget Tests', () {
    testWidgets('renders EditMyEventPage correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: EditMyEventPage(eventId: 1))),
      );

      expect(find.text('Edit Event'), findsOneWidget);
    });
  });
}
