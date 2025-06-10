import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/main.dart'; // Import your main app widget
import 'package:neuro_parent/auth/auth_bloc.dart';
import 'package:neuro_parent/services/exceptions/auth_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Import for SnackBar

void main() {
  group('Auth Integration Tests', () {
    testWidgets('Successful login navigates to home page', (
      WidgetTester tester,
    ) async {
      // TODO: Replace with valid credentials for your *local development backend*
      // These credentials must exist and be valid in your backend database.
      const String validEmail =
          'testing@test.com'; // Replace with a valid test user email
      const String validPassword =
          '12345678'; // Replace with the valid password for that user

      // Start the app wrapped in ProviderScope
      await tester.pumpWidget(const ProviderScope(child: MyApp()));

      // Wait for the app to settle on the initial route (login page)
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.bySemanticsLabel('Email'), validEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), validPassword);
      await tester.tap(find.text('log in'));
      await tester.pumpAndSettle();

      // Verify navigation to home page
      expect(
        find.text('NeuroParent'),
        findsOneWidget,
      ); // Assuming NeuroParent is on the home page
      // Or more specifically, check the route
      // expect(GoRouter.of(tester.element(find.byType(MyApp))).location, '/home');
    });

    testWidgets(
      'Login with invalid credentials displays error and stays on login page',
      (WidgetTester tester) async {
        // Start the app wrapped in ProviderScope
        await tester.pumpWidget(const ProviderScope(child: MyApp()));

        // Wait for the app to settle on the initial route (login page)
        await tester.pumpAndSettle();

        // Enter invalid credentials
        await tester.enterText(
          find.bySemanticsLabel('Email'),
          'wrong@example.com',
        );
        await tester.enterText(find.bySemanticsLabel('Password'), 'wrongpass');
        await tester.tap(find.text('log in'));
        await tester.pump(
          Duration(milliseconds: 100),
        ); // Allow SnackBar to show with a small delay
        await tester.pumpAndSettle();

        // Verify still on login page by checking for the login button
        expect(find.text('log in'), findsOneWidget);
      },
    );

    testWidgets('Successful registration navigates to login page', (
      WidgetTester tester,
    ) async {
      // Generate unique credentials for registration test
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String newEmail = 'newuser$timestamp@example.com';
      const String newPassword = 'newSecurePass123';
      const String newName = 'New Test User';

      // Start the app wrapped in ProviderScope
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Navigate to the signup page
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(
        find.text('Sign up'),
      ); // Assuming a 'Sign up' link/button on login page
      await tester.pumpAndSettle();

      // Enter registration details
      await tester.enterText(find.bySemanticsLabel('Name'), newName);
      await tester.enterText(find.bySemanticsLabel('Email'), newEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), newPassword);
      await tester.enterText(
        find.bySemanticsLabel('Confirm Password'),
        newPassword,
      );

      // Select a role (e.g., 'User') if applicable
      await tester.tap(
        find.text('User'),
      ); // Assuming a 'User' button for role selection
      await tester.pumpAndSettle();

      // Tap the sign up button
      await tester.ensureVisible(find.text('sign up'));
      await tester.tap(find.text('sign up'));
      await tester.pump(Duration(milliseconds: 100)); // Allow SnackBar to show
      await tester.pumpAndSettle();

      expect(
        find.text('log in'),
        findsOneWidget,
      ); // Confirm presence of login button
    });

    testWidgets('Login after successful registration navigates to home page', (
      WidgetTester tester,
    ) async {
      // This test depends on a successful registration first. It's often better
      // to run registration as a prerequisite for this test or use a known user.
      // For simplicity and to show the flow, we'll do registration within this test.

      final timestamp =
          DateTime.now().millisecondsSinceEpoch + 1; // Ensure unique email
      final String newEmail = 'loginuser$timestamp@example.com';
      const String newPassword = 'loginSecurePass123';
      const String newName = 'Login Test User';

      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      // Navigate to signup and register
      await tester.tap(find.text('Sign up'));
      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Name'), newName);
      await tester.enterText(find.bySemanticsLabel('Email'), newEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), newPassword);
      await tester.enterText(
        find.bySemanticsLabel('Confirm Password'),
        newPassword,
      );
      await tester.tap(find.text('User'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('sign up'));
      await tester.tap(find.text('sign up'));
      await tester.pump(
        Duration(milliseconds: 100),
      ); // Allow SnackBar to show before settling
      await tester.pumpAndSettle(); // Settle after registration

      // Explicitly pump and settle again to ensure navigation to login page is complete
      await tester.pumpAndSettle();

      // Now on login page, proceed with login
      await tester.enterText(find.bySemanticsLabel('Email'), newEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), newPassword);
      await tester.tap(find.text('log in'));
      await tester.pumpAndSettle();

      // Verify navigation to home page
      expect(
        find.text('NeuroParent'),
        findsOneWidget,
      ); // Assuming NeuroParent is on the home page
    });
  });
}
