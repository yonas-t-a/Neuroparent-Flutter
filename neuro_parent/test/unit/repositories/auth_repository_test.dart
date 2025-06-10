import 'package:flutter_test/flutter_test.dart';
import 'package:neuro_parent/repositories/auth_repository.dart';
import 'package:neuro_parent/services/auth_service.dart';
import 'package:neuro_parent/models/user.dart';
import 'package:neuro_parent/services/exceptions/auth_exceptions.dart';
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
      when(
        () => mockAuthService.login('test@test.com', 'password'),
      ).thenAnswer((_) async => {'user': user, 'token': 'some_token'});

      final result = await authRepository.login('test@test.com', 'password');

      expect(result['user'], user);
      expect(result['token'], 'some_token');
      verify(
        () => mockAuthService.login('test@test.com', 'password'),
      ).called(1);
    });

    test('login rethrows AuthException', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenThrow(InvalidCredentialsException());

      expect(
        () => authRepository.login('test@test.com', 'wrongpass'),
        throwsA(isA<InvalidCredentialsException>()),
      );
      verify(
        () => mockAuthService.login('test@test.com', 'wrongpass'),
      ).called(1);
    });

    test('login throws AuthException for other errors', () async {
      when(
        () => mockAuthService.login(any(), any()),
      ).thenThrow(Exception('Connection failed'));

      expect(
        () => authRepository.login('test@test.com', 'password'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Login failed'),
          ),
        ),
      );
      verify(
        () => mockAuthService.login('test@test.com', 'password'),
      ).called(1);
    });

    test('register returns user on success', () async {
      when(
        () => mockAuthService.register(any(), any(), any(), any()),
      ).thenAnswer((_) async => user);

      final result = await authRepository.register(
        'New User',
        'new@example.com',
        'password',
        'user',
      );

      expect(result, user);
      verify(
        () => mockAuthService.register(
          'New User',
          'new@example.com',
          'password',
          'user',
        ),
      ).called(1);
    });

    test('register rethrows AuthException', () async {
      when(
        () => mockAuthService.register(any(), any(), any(), any()),
      ).thenThrow(EmailAlreadyInUseException());

      expect(
        () => authRepository.register(
          'New User',
          'existing@example.com',
          'password',
          'user',
        ),
        throwsA(isA<EmailAlreadyInUseException>()),
      );
      verify(
        () => mockAuthService.register(
          'New User',
          'existing@example.com',
          'password',
          'user',
        ),
      ).called(1);
    });

    test('register throws AuthException for other errors', () async {
      when(
        () => mockAuthService.register(any(), any(), any(), any()),
      ).thenThrow(Exception('Database error'));

      expect(
        () => authRepository.register(
          'New User',
          'new@example.com',
          'password',
          'user',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            contains('Registration failed'),
          ),
        ),
      );
      verify(
        () => mockAuthService.register(
          'New User',
          'new@example.com',
          'password',
          'user',
        ),
      ).called(1);
    });
  });
}
