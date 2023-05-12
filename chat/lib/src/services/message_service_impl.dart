import 'dart:async';

import 'package:chat/core/utils/constants.dart';
import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/message_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageService implements IMessageService {
  final RethinkDb r;
  final Connection _connection;

  final StreamController<Message> _controller =
      StreamController<Message>.broadcast();
  StreamSubscription _changeFeed = Stream.empty().listen((event) {});

  MessageService(this.r, this._connection);

  @override
  void dispose() {
    _changeFeed.cancel();
    _controller.close();
  }

  @override
  Stream<Message> getMessages(User activeUser) {
    _startListening(activeUser);
    return _controller.stream;
  }

  @override
  Future<bool> isMessageSent(Message message) async {
    Map record = await r
        .table(AppConstants.tableMessages)
        .insert(message.toJson())
        .run(_connection);

    return record['inserted'] == 1;
  }

  void _startListening(User activeUser) {
    _changeFeed = r
        .table(AppConstants.tableMessages)
        .filter({'to': activeUser.id})
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) {
                  return;
                }

                final message = Message.fromJson(feedData['new_val']);
                _controller.sink.add(message);
                _removeDeliverredMessage(message);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  void _removeDeliverredMessage(Message message) {
    r
        .table(AppConstants.tableMessages)
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
