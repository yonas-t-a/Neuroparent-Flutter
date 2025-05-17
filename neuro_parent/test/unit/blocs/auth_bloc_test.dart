// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:neuro_parent/auth/auth_bloc.dart';
// import 'package:neuro_parent/repositories/auth_repository.dart';

// void main() {
//   group('AuthBloc', () {
//     late AuthBloc authBloc;

//     setUp(() {
//       authBloc = AuthBloc(AuthRepository());
//     });

//     blocTest<AuthBloc, AuthState>(
//       'emits [AuthLoading, AuthFailure] when login fails',
//       build: () => authBloc,
//       act: (bloc) => bloc.add(LoginRequested('', '')),
//       expect: () => [isA<AuthLoading>(), isA<AuthFailure>()],
//     );
//   });
// }
// auth_bloc_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:neuro_parent/auth/auth_bloc.dart';
import 'package:neuro_parent/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authBloc = AuthBloc(mockRepository);
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthFailure] when login fails',
    build: () => authBloc,
    setUp: () {
      when(
        () => mockRepository.login(any(), any()),
      ).thenThrow(InvalidCredentialsException());
    },
    act: (bloc) => bloc.add(LoginRequested('test@test.com', 'wrongpass')),
    expect:
        () => [
          AuthLoading(),
          AuthFailure('Invalid email or password'), // Must match exactly
        ],
    verify: (_) {
      verify(
        () => mockRepository.login('test@test.com', 'wrongpass'),
      ).called(1);
    },
  );
}
