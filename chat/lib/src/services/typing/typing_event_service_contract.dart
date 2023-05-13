import 'package:chat/src/models/typing_event.dart';
import 'package:chat/src/models/user.dart';

abstract class ITypingEvent {
  Future<bool> send(TypingEvent typingEvent, User to);
  Stream<TypingEvent> subscribe(User user, List<String> userIds);
  void dispose();
}
