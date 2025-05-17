import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/repositories/auth_repository.dart';

void main() {
  group('AuthRepository', () {
    final repo = AuthRepository();

    test('throws exception on login with empty credentials', () async {
      expect(() => repo.login('', ''), throwsA(isA<Exception>()));
    });

    // Add more tests for register, etc.
  });
}
