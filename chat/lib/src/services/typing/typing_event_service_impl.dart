import 'dart:async';

import 'package:chat/core/utils/constants.dart';
import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';
import 'package:chat/src/services/typing/typing_event_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class TypingEventService implements ITypingEvent {
  final RethinkDb _r;
  final Connection _connection;

  TypingEventService(this._r, this._connection);

  final StreamController<TypingEvent> _controller =
      StreamController<TypingEvent>.broadcast();
  StreamSubscription _changeFeed = const Stream.empty().listen((event) {});

  @override
  void dispose() {
    _controller.close();
    _changeFeed.cancel();
  }

  @override
  Future<bool> send(TypingEvent typingEvent, User to) async {
    if (!to.active) {
      return false;
    }

    Map record = await _r
        .table(AppConstants.tableTypingEvents)
        .insert(typingEvent.toJson(), {'conflict': 'update'}).run(_connection);

    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String> userIds) {
    _startReceivingTypingEvents(user, userIds);
    return _controller.stream;
  }

  void _startReceivingTypingEvents(User user, List<String> userIds) {
    _changeFeed = _r
        .table(AppConstants.tableTypingEvents)
        .filter((event) {
          return event('to')
              .eq(user.id)
              .and(_r.expr(userIds).contains(event('from')));
        })
        .changes({'include_initial': true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event.forEach((feedData) {
            if (feedData['new_val'] == null) {
              return;
            }

            final typingEvent = _eventFromFeed(feedData);
            _controller.sink.add(typingEvent);
            _removeEvent(typingEvent);
          });
        });
  }

  TypingEvent _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  void _removeEvent(typingEvent) {
    _r
        .table(AppConstants.tableTypingEvents)
        .get(typingEvent.id)
        .delete()
        .run(_connection);
  }
}
