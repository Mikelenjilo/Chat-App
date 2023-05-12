import 'package:chat/core/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDatabase({
  required RethinkDb r,
  required Connection connection,
  required String databaseName,
}) async {
  if (!await r.dbList().contains(databaseName).run(connection)) {
    await r
        .dbCreate(databaseName)
        .run(connection)
        .catchError((err) => {prints(err)});
  }
}

Future<void> createTable({
  required RethinkDb r,
  required Connection connection,
  required String tableName,
}) async {
  if (!await r.tableList().contains(tableName).run(connection)) {
    await r
        .tableCreate(tableName)
        .run(connection)
        .catchError((err) => {prints(err)});
  }
}

Future<void> cleanTable(
    RethinkDb r, Connection connection, String tableName) async {
  await r.table(tableName).delete().run(connection).catchError((err) => {});
  await r
      .table(AppConstants.tableMessages)
      .delete()
      .run(connection)
      .catchError((err) => {});
}
