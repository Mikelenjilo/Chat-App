import 'package:chat/src/models/receipt.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/receipt/receipts_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  late Connection connection;
  late ReceiptService sut;

  setUp(() async {
    connection = await r.connect(host: '127.0.0.1', port: 28015);
    await createDatabase(r: r, connection: connection, databaseName: 'test');
    await createTable(r: r, connection: connection, tableName: 'receipts');
    sut = ReceiptService(r, connection);
  });

  tearDown(() async {
    sut.dispose();
    await cleanTable(r, connection, 'receipts');
  });

  final user = User.fromJson(
    {
      'id': '1234',
      'username': 'user1',
      'photoUrl': 'url',
      'active': true,
      'lastSeen': DateTime.now(),
    },
  );

  test('sent receipt successfully', () async {
    final receipt = Receipt(
      recipient: '777',
      messageId: '12346',
      status: ReceiptStatus.delivered,
      timestamp: DateTime.now(),
    );

    final res = await sut.send(receipt);
    expect(res, true);
  });

// TODO: Fix this test
  test(
    'successfully subscribe and receive receipts',
    () async {
      sut.receipts(user).listen(expectAsync1((receipt) {
            expect(receipt.recipient, user.id);
          }, count: 2));
      Receipt receipt1 = Receipt(
        recipient: user.id,
        messageId: '12346',
        status: ReceiptStatus.delivered,
        timestamp: DateTime.now(),
      );
      Receipt receipt2 = Receipt(
        recipient: user.id,
        messageId: '12346',
        status: ReceiptStatus.read,
        timestamp: DateTime.now(),
      );

      await sut.send(receipt1);
      await sut.send(receipt2);
    },
  );
}
