class User {
  late String _id;
  String get id => _id;

  String username;
  String photoUrl;
  bool active;
  DateTime lastSeen;

  User({
    required this.username,
    required this.photoUrl,
    required this.active,
    required this.lastSeen,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'photoUrl': photoUrl,
      'active': active,
      'lastSeen': lastSeen,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final User user = User(
      username: json['username'],
      photoUrl: json['photoUrl'],
      active: json['active'],
      lastSeen: json['lastSeen'],
    );
    user._id = json['id'];
    return user;
  }
}
