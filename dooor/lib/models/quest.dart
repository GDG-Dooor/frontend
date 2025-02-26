class Quest {
  final int questId; //퀘스트 고유 아이디
  final String title; //퀘스트 제목
  final String description; //퀘스트 설명
  final bool needsVerification; //인증 필요 여부
  final String? verificationType; //인증 방식
  final int stage; // level 대신 stage로 변경
  bool isCompleted; //퀘스트 완료 여부

  Quest({
    required this.questId,
    required this.title,
    required this.description,
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
