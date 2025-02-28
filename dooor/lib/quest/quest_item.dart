import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestListItem extends StatelessWidget {
  final Quest quest;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onCameraPressed; // 📌 카메라 버튼 동작 추가

  const QuestListItem({
    super.key,
    required this.quest,
    required this.isCompleted,
    required this.onComplete,
    required this.onCameraPressed, // 📌 추가된 카메라 버튼 동작
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted ? Color(0xFFE6DFD5) : Color(0xFFEDE1D5),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // 완료 상태 표시 아이콘
            Container(
              decoration: BoxDecoration(
                color: isCompleted ? Color(0xFF9E8976) : Colors.transparent,
                shape: BoxShape.circle,
                border: isCompleted
                    ? null
                    : Border.all(color: Color(0xFF9E8976), width: 2),
              ),
              width: 24,
              height: 24,
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),

            const SizedBox(width: 12),

            // 퀘스트 제목 및 설명
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quest.title,
                    style: TextStyle(
                      color: isCompleted
                          ? Color(0xFF8B7363).withOpacity(0.7)
                          : Color(0xFF8B7363),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (quest.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        quest.description,
                        style: TextStyle(
                          color: isCompleted ? Colors.grey : Colors.black87,
                          fontSize: 12,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ✅ 퀘스트 완료 버튼 또는 📷 카메라 버튼
            if (quest.needImage)
              IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: isCompleted ? Colors.grey : Color(0xFF9E8976),
                ),
                onPressed: isCompleted ? null : onCameraPressed, // 📌 카메라 버튼 동작
              )
            else
              ElevatedButton(
                onPressed: isCompleted ? null : onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? Colors.grey.withOpacity(0.5)
                      : Color(0xFF9E8976),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(70, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: isCompleted ? 0 : 2,
                  shadowColor: Color(0xFF9E8976).withOpacity(0.3),
                ),
                child: Text(isCompleted ? "완료됨" : "완료"),
              ),
          ],
        ),
      ),
    );
  }
}
