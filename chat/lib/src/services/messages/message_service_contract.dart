import 'package:chat/src/models/message.dart';
import 'package:chat/src/models/user.dart';

abstract class IMessageService {
  Future<bool> sendMessage(Message message);
  Stream<Message> getMessages(User user);
  void dispose();
}
