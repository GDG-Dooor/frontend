class Quest {
  final int questId;
  final String title;
  final String description;
  final bool isRequired;
  final bool needsVerification;
  final String? verificationType;
  final int stage; // level 대신 stage로 변경
  bool isCompleted;

  Quest({
    required this.questId,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.needsVerification = false,
    this.verificationType,
    required this.stage,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'questId': questId,
      'title': title,
      'description': description,
      'stageId': stage,
      'needImage': needsVerification,
    };
  }
}

class QuestCreateRequest {
  final String title;
  final String description;
  final int stageId;
  final bool needImage;

  QuestCreateRequest({
    required this.title,
    required this.description,
    required this.stageId,
    this.needImage = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'stageId': stageId,
      'needImage': needImage,
    };
  }
}
