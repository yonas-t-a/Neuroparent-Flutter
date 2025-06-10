import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/main.dart'; // Import your main app widget
import 'package:neuro_parent/services/exceptions/auth_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart'; // Import for SnackBar

void main() {
  group('Auth Integration Tests', () {
    testWidgets('Successful login navigates to home page', (
      WidgetTester tester,
    ) async {
      const String validEmail =
          'testing@test.com'; 
      const String validPassword =
          '12345678'; 

      await tester.pumpWidget(const ProviderScope(child: MyApp()));

      await tester.pumpAndSettle();

      await tester.enterText(find.bySemanticsLabel('Email'), validEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), validPassword);
      await tester.tap(find.text('log in'));
      await tester.pumpAndSettle();

      expect(
        find.text('NeuroParent'),
        findsOneWidget,
      ); 
      // expect(GoRouter.of(tester.element(find.byType(MyApp))).location, '/home');
    });

    testWidgets(
      'Login with invalid credentials displays error and stays on login page',
      (WidgetTester tester) async {
        await tester.pumpWidget(const ProviderScope(child: MyApp()));

        await tester.pumpAndSettle();

        await tester.enterText(
          find.bySemanticsLabel('Email'),
          'wrong@example.com',
        );
        await tester.enterText(find.bySemanticsLabel('Password'), 'wrongpass');
        await tester.tap(find.text('log in'));
        await tester.pump(
          Duration(milliseconds: 100),
        ); 
        await tester.pumpAndSettle();

        expect(find.text('log in'), findsOneWidget);
      },
    );

    testWidgets('Successful registration navigates to login page', (
      WidgetTester tester,
    ) async {
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final String newEmail = 'newuser$timestamp@example.com';
      const String newPassword = 'newSecurePass123';
      const String newName = 'New Test User';

      
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      
      await tester.ensureVisible(find.text('Sign up'));
      await tester.tap(
        find.text('Sign up'),
      );
      await tester.pumpAndSettle();


      await tester.enterText(find.bySemanticsLabel('Name'), newName);
      await tester.enterText(find.bySemanticsLabel('Email'), newEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), newPassword);
      await tester.enterText(
        find.bySemanticsLabel('Confirm Password'),
        newPassword,
      );


      await tester.tap(
        find.text('User'),
      ); 
      await tester.pumpAndSettle();

    
      await tester.ensureVisible(find.text('sign up'));
      await tester.tap(find.text('sign up'));
      await tester.pump(Duration(milliseconds: 100)); 
      await tester.pumpAndSettle();

      expect(
        find.text('log in'),
        findsOneWidget,
      ); 
    });

    testWidgets('Login after successful registration navigates to home page', (
      WidgetTester tester,
    ) async {


      final timestamp =
          DateTime.now().millisecondsSinceEpoch + 1; 
      final String newEmail = 'loginuser$timestamp@example.com';
      const String newPassword = 'loginSecurePass123';
      const String newName = 'Login Test User';

      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();


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
      ); 
      await tester.pumpAndSettle(); 

   
      await tester.pumpAndSettle();

     
      await tester.enterText(find.bySemanticsLabel('Email'), newEmail);
      await tester.enterText(find.bySemanticsLabel('Password'), newPassword);
      await tester.tap(find.text('log in'));
      await tester.pumpAndSettle();

      expect(
        find.text('NeuroParent'),
        findsOneWidget,
      ); 
    });
  });
}
