class User {
  final int userId;
  final String email;
  final String name;
  final String role;
  final int rank;
  final int? currentQuestId;
  final bool currentQuestCleared;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.rank,
    this.currentQuestId,
    required this.currentQuestCleared,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      rank: json['rank'] as int,
      currentQuestId: json['currentQuestId'] as int?,
      currentQuestCleared: json['currentQuestCleared'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'name': name,
      'role': role,
      'rank': rank,
      'currentQuestId': currentQuestId,
      'currentQuestCleared': currentQuestCleared,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
