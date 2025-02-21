class Quest {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  final bool needsVerification;
  final String? verificationType;
  final int stage; // level 대신 stage로 변경
  bool isCompleted;

  Quest({
    String? id,
    required this.title,
    required this.description,
    this.isRequired = false,
    this.needsVerification = false,
    this.verificationType,
    required this.stage,
    this.isCompleted = false,
  }) : id = id ?? title.replaceAll(' ', '_').toLowerCase();
}
