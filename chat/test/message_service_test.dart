import 'package:chat/core/utils/constants.dart';
import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_service_impl.dart';
import 'package:chat/src/services/messages/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late MessageService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDatabase(
        r: r, connection: connection, databaseName: AppConstants.databaseName);
    await createTable(r: r, connection: connection, tableName: 'messages');
    final encryption = EncryptionService(Encrypter(AES(Key.fromLength(32))));
    sut = MessageService(r, connection, encryption);
  });

  tearDown(() async {
    sut.dispose();
    await cleanTable(r, connection, 'messages');
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

    final res = await sut.send(message);
    expect(res, true);
  });

  test('successfully subscribe and receive messages', () async {
    const contents = 'this is a message';
    sut.messages(user2).listen(expectAsync1((message) {
          expect(message.to, user2.id);
          expect(message.id, isNotEmpty);
          expect(message.content, contents);
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

    await sut.send(message1);

    await sut.send(message2);
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

    await sut.send(message1);
    await sut.send(message2).whenComplete(
          () => sut.messages(user2).listen(
                expectAsync1((message) {
                  expect(message.id, isNotEmpty);
                }, count: 2),
              ),
        );
  });
}
