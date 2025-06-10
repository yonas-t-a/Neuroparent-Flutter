// auth_exceptions.dart
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() : super('Email already in use');
}

class NetworkAuthException extends AuthException {
  NetworkAuthException(String? message)
    : super('Network error: ${message ?? 'Unknown network error'}');
}
