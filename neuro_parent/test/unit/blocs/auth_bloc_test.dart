// // import 'package:flutter_test/flutter_test.dart';
// // import 'package:bloc_test/bloc_test.dart';
// // import 'package:neuro_parent/auth/auth_bloc.dart';
// // import 'package:neuro_parent/repositories/auth_repository.dart';

// // void main() {
// //   group('AuthBloc', () {
// //     late AuthBloc authBloc;

// //     setUp(() {
// //       authBloc = AuthBloc(AuthRepository());
// //     });

// //     blocTest<AuthBloc, AuthState>(
// //       'emits [AuthLoading, AuthFailure] when login fails',
// //       build: () => authBloc,
// //       act: (bloc) => bloc.add(LoginRequested('', '')),
// //       expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
// //     );
// //   });
// // }
// // auth_bloc_test.dart
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:neuro_parent/auth/auth_bloc.dart';
// import 'package:neuro_parent/repositories/auth_repository.dart';
// import 'package:mocktail/mocktail.dart';

// class MockAuthRepository extends Mock implements AuthRepository {}

// void main() {
//   late AuthBloc authBloc;
//   late MockAuthRepository mockRepository;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     authBloc = AuthBloc(mockRepository);
//   });

//   blocTest<AuthBloc, AuthState>(
//     'emits [AuthLoading, AuthFailure] when login fails',
//     build: () => authBloc,
//     setUp: () {
//       when(
//         () => mockRepository.login(any(), any()),
//       ).thenThrow(InvalidCredentialsException());
//     },
//     act: (bloc) => bloc.add(LoginRequested('test@test.com', 'wrongpass')),
//     expect:
//         () => [
//           AuthLoading(),
//           AuthFailure('Invalid email or password'), // Must match exactly
//         ],
//     verify: (_) {
//       verify(
//         () => mockRepository.login('test@test.com', 'wrongpass'),
//       ).called(1);
//     },
//   );
// }

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuro_parent/auth/auth_bloc.dart';
import 'package:neuro_parent/repositories/auth_repository.dart';
import 'package:neuro_parent/models/user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuro_parent/services/exceptions/auth_exceptions.dart'
    as service_exceptions;

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(mockAuthRepository)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test('initial state is AuthInitial', () {
      expect(container.read(authProvider), isA<AuthInitial>());
    });

    test('emits [AuthLoading, AuthSuccess] when login is successful', () async {
      final emittedStates = <AuthState>[];
      container.listen(authProvider, (_, next) {
        emittedStates.add(next);
      });

      final user = User(
        userId: 123,
        name: 'Test User',
        email: 'test@example.com',
        role: 'user',
      );
      when(
        () => mockAuthRepository.login('test@test.com', 'password'),
      ).thenAnswer((_) async => {'user': user, 'token': 'test_token'});

      await container
          .read(authProvider.notifier)
          .login('test@test.com', 'password');

      expect(emittedStates, [isA<AuthLoading>(), isA<AuthSuccess>()]);

      final successState = emittedStates[1] as AuthSuccess;
      expect(successState.user, user);
      expect(successState.token, 'test_token');
    });

    test(
      'emits [AuthLoading, AuthFailure] when login fails with InvalidCredentialsException',
      () async {
        final emittedStates = <AuthState>[];
        container.listen(authProvider, (_, next) {
          emittedStates.add(next);
        });

        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenThrow(service_exceptions.InvalidCredentialsException());

        await container
            .read(authProvider.notifier)
            .login('test@test.com', 'wrongpass');

        expect(emittedStates, [isA<AuthLoading>(), isA<AuthFailure>()]);

        final failureState = emittedStates[1] as AuthFailure;
        expect(failureState.error, 'Invalid email or password');
      },
    );

    test(
      'emits [AuthLoading, AuthFailure] when login fails with generic AuthException',
      () async {
        final emittedStates = <AuthState>[];
        container.listen(authProvider, (_, next) {
          emittedStates.add(next);
        });

        when(
          () => mockAuthRepository.login(any(), any()),
        ).thenThrow(service_exceptions.AuthException('Something went wrong'));

        await container
            .read(authProvider.notifier)
            .login('test@test.com', 'wrongpass');

        expect(emittedStates, [isA<AuthLoading>(), isA<AuthFailure>()]);

        final failureState = emittedStates[1] as AuthFailure;
        expect(failureState.error, 'Something went wrong');
      },
    );

    test(
      'emits [AuthLoading, AuthRegistrationSuccess] when registration is successful',
      () async {
        final emittedStates = <AuthState>[];
        container.listen(authProvider, (_, next) {
          emittedStates.add(next);
        });

        final user = User(
          userId: 123,
          name: 'New User',
          email: 'new@example.com',
          role: 'user',
        );
        when(
          () => mockAuthRepository.register(any(), any(), any(), any()),
        ).thenAnswer((_) async => user);

        await container
            .read(authProvider.notifier)
            .register('New User', 'new@example.com', 'password', 'user');

        expect(emittedStates, [
          isA<AuthLoading>(),
          isA<AuthRegistrationSuccess>(),
        ]);

        // No user or token expected in AuthRegistrationSuccess state
        // final successState = emittedStates[1] as AuthSuccess;
        // expect(successState.user, user);
        // expect(
        //   successState.token,
        //   isNull,
        // ); // Token might not be returned on registration
      },
    );

    test('emits [AuthLoading, AuthFailure] when registration fails', () async {
      final emittedStates = <AuthState>[];
      container.listen(authProvider, (_, next) {
        emittedStates.add(next);
      });

      when(
        () => mockAuthRepository.register(any(), any(), any(), any()),
      ).thenThrow(service_exceptions.EmailAlreadyInUseException());

      await container
          .read(authProvider.notifier)
          .register('New User', 'existing@example.com', 'password', 'user');

      expect(emittedStates, [isA<AuthLoading>(), isA<AuthFailure>()]);

      final failureState = emittedStates[1] as AuthFailure;
      expect(failureState.error, 'Email already in use');
    });
  });
}

// A simple utility to listen to provider changes
class Listener<T> extends Mock {
  void call(T? previous, T next);
}
