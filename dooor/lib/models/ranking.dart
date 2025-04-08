class Ranking {
  final int rankingId;
  final User user;
  int rank;
  int score;
  final DateTime updatedAt;

  Ranking({
    required this.rankingId,
    required this.user,
    required this.rank,
    required this.score,
    required this.updatedAt,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      rankingId: json['rankingId'] ?? 0,
      user: User.fromJson(json['user'] ?? {}),
      rank: json['rank'] ?? 0,
      score: json['score'] ?? 0,
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class User {
  final int userId;
  final String email;
  final String name;
  final String role;
  final int rank;
  final int currentQuestId;
  final bool currentQuestCleared;
  final DateTime createdAt;

  User({
    required this.userId,
    required this.email,
    required this.name,
    required this.role,
    required this.rank,
    required this.currentQuestId,
    required this.currentQuestCleared,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'ROLE_USER',
      rank: json['rank'] ?? 0,
      currentQuestId: json['currentQuestId'] ?? 0,
      currentQuestCleared: json['currentQuestCleared'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
