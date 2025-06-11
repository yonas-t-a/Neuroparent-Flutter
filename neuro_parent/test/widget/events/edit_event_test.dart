import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/admin/events/edit_event.dart';

void main() {
  group('EditEventPage Widget Tests', () {
    testWidgets('renders EditEventPage correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: EditEventPage())),
      );

      expect(find.text('Events'), findsOneWidget);
    });
  });
}
