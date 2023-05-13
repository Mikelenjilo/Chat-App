enum TypingEventType { start, stop }

extension EnumParsing on TypingEventType {
  String value() {
    return toString().split('.').last;
  }

  static TypingEventType fromString(String value) {
    return TypingEventType.values.firstWhere((e) => e.value() == value);
  }
}

class TypingEvent {
  late String _id;
  String get id => _id;

  final String from;
  final String to;
  final TypingEventType type;

  TypingEvent({
    required this.from,
    required this.to,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'from': from,
      'to': to,
      'type': type.value(),
    };
  }

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final TypingEvent typingEvent = TypingEvent(
      from: json['from'],
      to: json['to'],
      type: EnumParsing.fromString(json['type']),
    );
    typingEvent._id = json['id'];
    return typingEvent;
  }
}
