class Stage {
  final int stageId;
  final String title;
  final String description;
  final List<int> questIds;

  Stage({
    required this.stageId,
    required this.title,
    required this.description,
    required this.questIds,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      stageId: json['stageId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      questIds: List<int>.from(json['questId'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageId': stageId,
      'title': title,
      'description': description,
      'questId': questIds,
    };
  }
}
