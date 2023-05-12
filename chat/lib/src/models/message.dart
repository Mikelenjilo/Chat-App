class Message {
  late String _id;
  String get id => _id;

  String from;
  String to;
  DateTime timestamp;
  String content;

  Message({
    required this.from,
    required this.to,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    final Message message = Message(
      from: json['from'],
      to: json['to'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
    message._id = json['id'];

    return message;
  }
}
