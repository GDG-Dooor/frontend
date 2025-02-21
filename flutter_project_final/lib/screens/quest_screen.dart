import 'package:flutter/material.dart';
import '../models/quest.dart';
import 'quest_verification_screen.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final List<Quest> quests = [
    // 튜토리얼 퀘스트
    Quest(
      title: '챗봇한테 인사해보기',
      description: '챗봇과 대화를 시작해보세요',
      needsVerification: true,
      verificationType: 'chat',
      stage: 1,
    ),
    Quest(
      title: '퀘스트 탭 클릭하기',
      description: '퀘스트 창에 오신 것을 환영합니다!',
      stage: 1,
    ),
    Quest(
      title: '랭킹 탭 확인하기',
      description: '함께 문을 열어가는 사람들을 만나보세요',
      stage: 1,
    ),

    // 쉬운 퀘스트
    Quest(
      title: '창문 열고 바깥 공기 마셔보기',
      description: '신선한 공기를 마시며 잠시 휴식을 취해보세요',
      stage: 2,
    ),
    Quest(
      title: '손 글씨로 "나는 잘하고 있어" 적어보기',
      description: '자신을 긍정적으로 표현해보세요',
      needsVerification: true,
      stage: 2,
    ),
    Quest(
      title: '미니 정리 정돈',
      description: '방 한 구석을 정리해보세요',
      isRequired: true,
      stage: 2,
    ),
    Quest(
      title: '3분간 스트레칭하기',
      description: '간단한 스트레칭으로 몸을 풀어보세요',
      isRequired: true,
      stage: 2,
    ),

    // 어려운 퀘스트
    Quest(
      title: '동네 편의점 다녀오기',
      description: '영수증을 인증해주세요',
      needsVerification: true,
      stage: 3,
    ),
    Quest(
      title: '도서관 책 대출받기',
      description: '대출증을 인증해주세요',
      needsVerification: true,
      stage: 3,
    ),
    Quest(
      title: '코인노래방 가보기',
      description: '마이크 사진을 찍어 인증해주세요',
      needsVerification: true,
      stage: 3,
    ),
  ];

  String _selectedType = 'tutorial';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo2.png',
              height: 36,
            ),
            const SizedBox(width: 8),
            const Text('퀘스트'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStageSection(
              '1단계', quests.where((q) => q.stage == 1).toList(), true),
          _buildStageSection(
              '2단계', quests.where((q) => q.stage == 2).toList(), false),
          _buildStageSection(
              '3단계', quests.where((q) => q.stage == 3).toList(), false),
          _buildStageSection(
              '4단계', quests.where((q) => q.stage == 4).toList(), false),
          _buildStageSection(
              '5단계', quests.where((q) => q.stage == 5).toList(), false),
          _buildStageSection(
              '6단계', quests.where((q) => q.stage == 6).toList(), false),
          _buildStageSection(
              '7단계', quests.where((q) => q.stage == 7).toList(), false),
        ],
      ),
    );
  }

  Widget _buildStageSection(
      String title, List<Quest> stageQuests, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF9E8976),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Spacer(),
            Icon(
              isUnlocked ? Icons.lock_open : Icons.lock,
              color: Colors.white,
            ),
          ],
        ),
        children: isUnlocked
            ? stageQuests.map((quest) => _buildQuestTile(quest)).toList()
            : [],
      ),
    );
  }

  Widget _buildQuestTile(Quest quest) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        children: [
          // 완료 여부 체크 표시
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: quest.isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: quest.isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.green)
                : null,
          ),
          // 퀘스트 제목
          Expanded(
            child: Text(
              quest.title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          // 인증필요 태그
          if (quest.needsVerification)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20), // 타원형 모양
              ),
              child: const Text(
                '인증필요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        if (quest.needsVerification) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestVerificationScreen(
                questId: quest.id,
                questTitle: quest.title,
                verificationType: quest.verificationType ?? 'default',
              ),
            ),
          );
        } else {
          setState(() {
            quest.isCompleted = !quest.isCompleted;
          });
        }
      },
    );
  }
}
