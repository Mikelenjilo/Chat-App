import 'package:chat/core/utils/constants.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserService implements IUserService {
  final RethinkDb r;
  final Connection _connection;

  UserService(this.r, this._connection);

  @override
  Future<User> connectUser(User user) async {
    Map<String, dynamic> data = user.toJson();

    final result = await r.table(AppConstants.tableUsers).insert(data, {
      'conflict': 'update',
      'return_changes': true,
    }).run(_connection);

    if (result != null) {
      return User.fromJson(result['changes'].first['new_val']);
    } else {
      throw Exception('User not created');
    }
  }

  @override
  Future<void> disconnectUser(User user) async {
    await r.table(AppConstants.tableUsers).update({
      'id': user.id,
      'active': false,
      'last_seen': DateTime.now(),
    }).run(_connection);
    _connection.close();
  }

  @override
  Future<List<User>> getActiveUsers() async {
    Cursor users = await r
        .table(AppConstants.tableUsers)
        .filter({'active': true}).run(_connection);
    final usersList = await users.toList();

    return usersList.map((user) => User.fromJson(user)).toList();
  }
}
