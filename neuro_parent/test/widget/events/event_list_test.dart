import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/user/events/event_list.dart';

void main() {
  group('EventsScreen Widget Tests', () {
    testWidgets('renders EventsScreen correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: EventsScreen())),
      );

      expect(find.text('Events'), findsOneWidget);
    });
  });
}
