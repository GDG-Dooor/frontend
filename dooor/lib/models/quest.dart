class Quest {
  final int questId;
  final String title;
  final String description;
  final int stageId;
  final bool needImage;

  Quest({
    required this.questId,
    required this.title,
    required this.description,
    required this.stageId,
    required this.needImage,
  });

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      questId: json['questId'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      stageId: json['stageId'] as int? ?? 0,
      needImage: json['needImage'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questId': questId,
      'title': title,
      'description': description,
      'stageId': stageId,
      'needImage': needImage,
    };
  }
}
