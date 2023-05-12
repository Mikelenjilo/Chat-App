import 'dart:async';

import 'package:chat/core/utils/constants.dart';
import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/encryption/encryption_service_contract.dart';
import 'package:chat/src/services/messages/message_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageService implements IMessageService {
  final RethinkDb r;
  final Connection _connection;
  final IEncryption _encryption;

  final StreamController<Message> _controller =
      StreamController<Message>.broadcast();
  StreamSubscription _changeFeed = const Stream.empty().listen((event) {});

  MessageService(this.r, this._connection, this._encryption);

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
  Future<bool> sendMessage(Message message) async {
    var data = message.toJson();
    data['content'] = _encryption.encrypt(message.content);

    Map record =
        await r.table(AppConstants.tableMessages).insert(data).run(_connection);

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

                final message = _messageFromFeed(feedData);
                _controller.sink.add(message);
                _removeDeliverredMessage(message);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Message _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    data['content'] = _encryption.decrypt(data['content']);

    return Message.fromJson(data);
  }

  void _removeDeliverredMessage(Message message) {
    r
        .table(AppConstants.tableMessages)
        .get(message.id)
        .delete({'return_changes': false}).run(_connection);
  }
}
