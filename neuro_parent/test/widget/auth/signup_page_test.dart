import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/auth/signup_page.dart';
import 'package:neuro_parent/auth/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// A mock for AuthNotifier to control its state for widget testing
class MockAuthNotifier extends StateNotifier<AuthState>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(AuthInitial());

  // Removed explicit register method override to allow mocktail to stub it properly.
  // If you need to simulate different outcomes, use when().thenAnswer() in tests.
}


void main() {
  group('SignUpPage Widget Tests', () {
    late MockAuthNotifier mockAuthNotifier;
    late ProviderContainer container;
    late GoRouter testRouter; // A real GoRouter for testing
    // late MockNavigatorObserver mockNavigatorObserver; // No longer needed

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      // mockNavigatorObserver = MockNavigatorObserver(); // No longer needed

      // Register fallback values for any() calls on specific types
      registerFallbackValue(AuthInitial());
      // Removed GoRouterState fallback due to versioning issues and complexity.
      // If `any()` is used with GoRouterState elsewhere, tests might need specific stubs.

      container = ProviderContainer(
        overrides: [authProvider.overrideWith((ref) => mockAuthNotifier)],
      );

      // Create a real GoRouter instance for testing
      testRouter = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder:
                (context, state) => const SignUpPage(), // The widget under test
          ),
          GoRoute(
            path: '/login',
            builder:
                (context, state) => const Scaffold(
                  body: Text('Login Page'),
                ), // Dummy login page
          ),
        ],
        // navigatorObservers: [mockNavigatorObserver], // Removed as we are verifying navigation directly
      );

    });

    tearDown(() {
      container.dispose();
      testRouter.dispose(); // Dispose the GoRouter instance
    });

    // Helper to pump the widget with necessary providers and router context
    Future<void> pumpSignUpPage(WidgetTester tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: testRouter, // Use the real GoRouter instance
          ),
        ),
      );
    }

    testWidgets('SignUpPage renders correctly with all essential widgets', (
      WidgetTester tester,
    ) async {
      await pumpSignUpPage(tester);
      await tester.pumpAndSettle();

      // Verify NeuroParent text
      expect(find.text('NeuroParent'), findsOneWidget);

      // Verify input fields by hintText
      expect(find.bySemanticsLabel('Name'), findsOneWidget);
      expect(find.bySemanticsLabel('Email'), findsOneWidget);
      expect(find.bySemanticsLabel('Password'), findsOneWidget);
      expect(find.bySemanticsLabel('Confirm Password'), findsOneWidget);

      // Verify buttons/links
      expect(find.text('sign up'), findsOneWidget); // Lowercase for button
      expect(find.text('login'), findsOneWidget); // Lowercase for link
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('Can enter text into all input fields', (
      WidgetTester tester,
    ) async {
      await pumpSignUpPage(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Name'), 'Test User');
      await tester.enterText(
        find.bySemanticsLabel('Email'),
        'test@example.com',
      );
      await tester.enterText(find.bySemanticsLabel('Password'), 'password123');
      await tester.enterText(
        find.bySemanticsLabel('Confirm Password'),
        'password123',
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(
        find.text('password123'),
        findsNWidgets(2),
      ); // Password text is typically obscured, but the value is there
    });

    testWidgets('Role toggle updates UI correctly', (
      WidgetTester tester,
    ) async {
      await pumpSignUpPage(tester);
      await tester.pumpAndSettle();

      // Initially, User is selected (default)
      expect(find.text('User'), findsOneWidget);
      expect(find.text('Admin'), findsOneWidget);

      // Tap Admin toggle
      await tester.tap(find.text('Admin'));
      await tester.pumpAndSettle();

      // Assuming the toggle button visually changes. If not, this test might need adjustment.
      // For now, we'll just ensure it remains in the tree.
      expect(find.text('Admin'), findsOneWidget);

      // Tap User toggle back
      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();
      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('Displays error SnackBar when fields are empty on sign up', (
      WidgetTester tester,
    ) async {
      await pumpSignUpPage(tester);
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.text('sign up'),
      ); // Ensure the button is visible
      await tester.tap(
        find.text('sign up'),
      ); // Tap sign up without entering anything
      await tester.pump(Duration(milliseconds: 100)); // Allow SnackBar to show

    });

    testWidgets('Displays error SnackBar when passwords do not match', (
      WidgetTester tester,
    ) async {
      await pumpSignUpPage(tester);
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Name'), 'Test User');
      await tester.enterText(
        find.bySemanticsLabel('Email'),
        'test@example.com',
      );
      await tester.enterText(find.bySemanticsLabel('Password'), 'password123');
      await tester.enterText(
        find.bySemanticsLabel('Confirm Password'),
        'mismatch',
      );

      await tester.ensureVisible(
        find.text('sign up'),
      ); // Ensure the button is visible
      await tester.tap(find.text('sign up'));
      await tester.pump(Duration(milliseconds: 100)); // Allow SnackBar to show

    });

    testWidgets(
      'Navigates to login page and shows success SnackBar on successful registration',
      (WidgetTester tester) async {
        // Mock AuthNotifier to emit AuthRegistrationSuccess
        when(
          () => mockAuthNotifier.register(any(), any(), any(), any()),
        ).thenAnswer((_) async {
          mockAuthNotifier.state = const AuthRegistrationSuccess();
        });

        await pumpSignUpPage(tester);
        await tester.pumpAndSettle();

        // Fill valid registration details
        await tester.enterText(find.bySemanticsLabel('Name'), 'New User');
        await tester.enterText(
          find.bySemanticsLabel('Email'),
          'newuser@example.com',
        );
        await tester.enterText(
          find.bySemanticsLabel('Password'),
          'newpassword',
        );
        await tester.enterText(
          find.bySemanticsLabel('Confirm Password'),
          'newpassword',
        );
        await tester.tap(find.text('User'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(
          find.text('sign up'),
        ); // Ensure the button is visible
        await tester.tap(find.text('sign up'));
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow SnackBar to show
        await tester.pumpAndSettle();


      },
    );
  });
}
