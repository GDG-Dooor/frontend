import 'package:flutter/material.dart';
import '../models/quest.dart';

class QuestListItem extends StatelessWidget {
  final Quest quest;
  final bool isCompleted;
  final VoidCallback onComplete;
  final VoidCallback onCameraPressed;

  const QuestListItem({
    super.key,
    required this.quest,
    required this.isCompleted,
    required this.onComplete,
    required this.onCameraPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  quest.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (quest.needImage)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: onCameraPressed,
            )
          else
            IconButton(
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                color: isCompleted ? Colors.green : Colors.grey,
              ),
              onPressed: onComplete,
            ),
        ],
      ),
    );
  }
}
