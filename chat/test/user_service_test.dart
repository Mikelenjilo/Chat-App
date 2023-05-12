import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/users/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late UserService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDatabase(r: r, connection: connection, databaseName: 'test');
    await createTable(r: r, connection: connection, tableName: 'users');
    sut = UserService(r, connection);
  });

  tearDown(() async {
    await cleanTable(r, connection, 'users');
  });

  test('creates a new user document in database', () async {
    final user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    final userWithId = await sut.connectUser(user);
    expect(userWithId.id, isNotEmpty);
  });

  test('get online users', () async {
    final User user = User(
      username: 'test',
      photoUrl: 'url',
      active: true,
      lastSeen: DateTime.now(),
    );
    await sut.connectUser(user);
    final users = await sut.getActiveUsers();
    expect(users.length, 1);
  });
}
