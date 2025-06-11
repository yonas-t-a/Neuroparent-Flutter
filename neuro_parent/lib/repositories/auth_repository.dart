import '../services/auth_service.dart';
import '../models/user.dart';
import '../services/exceptions/auth_exceptions.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
    : _authService = authService ?? AuthService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      return await _authService.login(email, password);
    } on AuthException {
      rethrow; // Let specific auth exceptions pass through
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  Future<User> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      return await _authService.register(name, email, password, role);
    } on AuthException {
      rethrow; // Let specific auth exceptions pass through
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }
}

