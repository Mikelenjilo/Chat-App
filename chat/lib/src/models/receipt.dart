enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String value() {
    return toString().split('.').last;
  }

  static ReceiptStatus fromString(String value) {
    return ReceiptStatus.values.firstWhere((e) => e.value() == value);
  }
}

class Receipt {
  late String _id;
  String get id => _id;

  final String recipient;
  final String messageId;
  final ReceiptStatus status;
  final DateTime timestamp;

  Receipt({
    required this.recipient,
    required this.messageId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipient': recipient,
      'messageId': messageId,
      'status': status.value(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final Receipt receipt = Receipt(
      recipient: json['recipient'],
      messageId: json['messageId'],
      status: EnumParsing.fromString(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
    );
    receipt._id = json['id'];
    return receipt;
  }
}
