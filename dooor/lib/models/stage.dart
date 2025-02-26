class Stage {
  final int stageId;
  final String title;
  final String? description;
  final List<int> questId;

  Stage({
    required this.stageId,
    required this.title,
    this.description,
    required this.questId,
  });

  factory Stage.fromJson(Map<String, dynamic> json) {
    return Stage(
      stageId: json['stageId'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      questId: List<int>.from(json['questId'] as List),
    );
  }
}
