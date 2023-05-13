import 'package:chat/core/utils/constants.dart';
import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_event_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late TypingEventService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDatabase(
        r: r, connection: connection, databaseName: AppConstants.databaseName);
    await createTable(
        r: r,
        connection: connection,
        tableName: AppConstants.tableTypingEvents);

    sut = TypingEventService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanTable(r, connection, AppConstants.tableTypingEvents);
  });

  final user1 = User.fromJson({
    'id': '1223',
    'active': true,
    'lastSeen': DateTime.now(),
    'username': 'user1',
    'photoUrl': 'photoUrl',
  });

  final user2 = User.fromJson({
    'id': '1114',
    'active': true,
    'lastSeen': DateTime.now(),
    'username': 'user2',
    'photoUrl': 'photoUrl',
  });

  test('creates a new typing event document in database', () async {
    final typingEvent = TypingEvent(
      from: user2.id,
      to: user1.id,
      type: TypingEventType.start,
    );
    final res = await sut.send(typingEvent, user1);
    expect(res, true);
  });

  test('successfully subscribe and receive typing events', () async {
    sut.subscribe(user2, [user1.id]).listen(expectAsync1((event) {
      expect(event.from, user1.id);
    }, count: 2));

    TypingEvent typing = TypingEvent(
      from: user1.id,
      to: user2.id,
      type: TypingEventType.start,
    );

    TypingEvent stopTyping = TypingEvent(
      from: user1.id,
      to: user2.id,
      type: TypingEventType.stop,
    );

    await sut.send(typing, user2);
    await sut.send(stopTyping, user2);
  });
}
