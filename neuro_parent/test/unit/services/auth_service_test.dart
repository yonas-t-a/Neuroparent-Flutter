import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/services/auth_service.dart';

void main() {
  group('AuthService', () {
    final authService = AuthService();

    test('throws exception on login with empty credentials', () async {
      expect(
        () => authService.login('', ''),
        throwsA(isA<Exception>()),
      );
    });

    // Add more tests for register, etc.
  });
}