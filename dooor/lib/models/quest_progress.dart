class QuestProgress {
  final List<bool> questStatus;
  final int currentQuestId;

  QuestProgress({
    required this.questStatus,
    required this.currentQuestId,
  });

  factory QuestProgress.fromJson(Map<String, dynamic> json) {
    return QuestProgress(
      questStatus: List<bool>.from(json['questStatus']),
      currentQuestId: json['currentQuestId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questStatus': questStatus,
      'currentQuestId': currentQuestId,
    };
  }
}
