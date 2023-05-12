import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/message_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late MessageService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDatabase(r: r, connection: connection, databaseName: 'test');
    await createTable(r: r, connection: connection, tableName: 'messages');
    sut = MessageService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanDatabase(r, connection);
  });

  final user1 = User.fromJson({
    'id': '1234',
    'username': 'user1',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  final user2 = User.fromJson({
    'id': '5678',
    'username': 'user2',
    'photoUrl': 'url',
    'active': true,
    'lastSeen': DateTime.now(),
  });

  test('sent message successfully', () async {
    Message message = Message(
      from: user1.id,
      to: '3456',
      timestamp: DateTime.now(),
      content: 'this is a message',
    );

    final res = await sut.isMessageSent(message);
    expect(res, true);
  });

  test('successfully subscribe and messages', () async {
    sut.getMessages(user2).listen(expectAsync1((message) {
          expect(message.to, user2.id);
          expect(message.id, isNotEmpty);
        }, count: 2));

    Message message1 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now(),
      content: 'this is a message',
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now(),
      content: 'this is a message',
    );

    await sut.isMessageSent(message1);

    await sut.isMessageSent(message2);
  });

  test('successfully subscribe and receive new messages', () async {
    Message message1 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now(),
      content: 'this is a message',
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now(),
      content: 'this is a message',
    );

    await sut.isMessageSent(message1);
    await sut.isMessageSent(message2).whenComplete(
          () => sut.getMessages(user2).listen(
                expectAsync1((message) {
                  expect(message.id, isNotEmpty);
                }, count: 2),
              ),
        );
  });
}
