import '../services/user_service.dart';
import '../models/user.dart';

class UserRepository {
  final UserService userService;

  UserRepository({required this.userService});

  Future<User> getUserById(int id) => userService.getUserById(id);

  Future<User> updateUser(
    int id, {
    String? name,
    String? email,
    String? password,
    String? oldPassword,
    String? newPassword,
  }) => userService.updateUser(
    id,
    name: name,
    email: email,
    password: password,
    oldPassword: oldPassword,
    newPassword: newPassword,
  );


}
