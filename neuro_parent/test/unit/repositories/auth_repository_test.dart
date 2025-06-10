import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/repositories/auth_repository.dart';
import 'package:neuro_parent/services/auth_service.dart';
import 'package:neuro_parent/models/user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late AuthRepository authRepository;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    authRepository = AuthRepository(authService: mockAuthService);
  });

  group('AuthRepository', () {
    final user = User(
      userId: 1,
      name: 'Test User',
      email: 'test@example.com',
      role: 'user',
    );

    test('login returns token and user on success', () async {
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) async => {'user': user, 'token': 'test_token'});

      final result = await authRepository.login('test@example.com', 'password');

      expect(result['user'], user);
      expect(result['token'], 'test_token');
    });

    test('register returns user on success', () async {
      when(() => mockAuthService.register(any(), any(), any(), any()))
          .thenAnswer((_) async => user);

      final result = await authRepository.register(
        'Test User',
        'test@example.com',
        'password',
        'user',
      );

      expect(result.email, 'test@example.com');
    });
  });
}