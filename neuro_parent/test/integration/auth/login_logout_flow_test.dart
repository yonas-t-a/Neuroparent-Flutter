import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/services/auth_service.dart';
import 'package:neuro_parent/auth/auth_bloc.dart';


void main() {
  group('Auth Integration', () {
    final authService = AuthService();

    test('login and logout flow', () async {
      // Replace with valid credentials for your backend
      final email = 'validuser@example.com';
      final password = 'validpassword';

      final result = await authService.login(email, password);
      expect(result['token'], isNotNull);
      expect(result['user'].email, email);

      // For logout, if you have an endpoint, call it here.
      // Otherwise, just clear the token in your app.
    });

    test('login with invalid credentials', () async {
      expect(
        () => authService.login('wrong@example.com', 'wrongpass'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });
}
