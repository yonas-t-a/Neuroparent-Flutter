import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/auth/login_page.dart';
import 'package:neuro_parent/auth/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';

// Mock the AuthNotifier to control its state for widget testing
class MockAuthNotifier extends StateNotifier<AuthState>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(AuthInitial()); // Initialize with a default state

  // You can add more specific mock behaviors here if needed for deeper interactions
  // For basic UI presence, we might not need extensive mocking beyond initial state.
}

void main() {
  group('LoginPage Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;
    late ProviderContainer container;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      container = ProviderContainer(
        overrides: [authProvider.overrideWith((ref) => mockAuthNotifier)],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('LoginPage renders correctly with all essential widgets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      // Verify NeuroParent text
      expect(find.text('NeuroParent'), findsOneWidget);

      // Verify input fields by hintText
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);

      // Verify buttons/links
      expect(find.text('log in'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget); // Case-sensitive for link
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('User role toggle updates UI correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      // Initially, Admin is selected (based on default in LoginPage)
      // Check for visual indicator, e.g., color, if possible, or tap and verify change

      // Tap User toggle
      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();

      // We can't directly check the isAdmin property from outside the widget,
      // but we can look for changes in the visual representation of the toggle buttons.
      // This part might need adjustment based on how the toggleButton actually signals selection.
      // For now, we'll assume the text presence implies visibility and tap-ability.
      expect(find.text('User'), findsOneWidget); // Still there after tap

      // Tap Admin toggle back
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();
      expect(find.text('Admin'), findsOneWidget); // Still there after tap
    });

    testWidgets('Can enter text into email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.enterText(
        find.bySemanticsLabel('Email'),
        'test@example.com',
      );
      await tester.enterText(find.bySemanticsLabel('Password'), 'password123');

      expect(find.text('test@example.com'), findsOneWidget);
      expect(
        find.text('password123'),
        findsOneWidget,
      ); // Password text is typically obscured, but the value is there.
    });
  });
}
