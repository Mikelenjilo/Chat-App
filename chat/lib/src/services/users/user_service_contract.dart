import 'package:chat/src/models/user.dart';

abstract class IUserService {
  Future<User> connectUser(User user);
  Future<List<User>> getActiveUsers();
  Future<void> disconnectUser(User user);
}
