import 'package:flutter/material.dart';
import '../models/quest.dart';
import 'quest_verification_screen.dart';
import '../services/api_service.dart';
import '../models/stage.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final List<Quest> quests = [
    // 1단계 - 튜토리얼
    Quest(
      questId: 1,
      title: '챗봇한테 인사해보기',
      description: '챗봇과 대화를 시작해보세요',
      needsVerification: true,
      verificationType: 'chat',
      stage: 1,
    ),
    Quest(
      questId: 2,
      title: '퀘스트 탭 클릭하기',
      description: '안녕 여기는 퀘스트창이야. 나는 네가 이 퀘스트를 깨면서 자신감을 얻었으면 좋겠어',
      stage: 1,
    ),
    Quest(
      questId: 3,
      title: '랭킹 탭 확인하기',
      description: '이렇게 함께 문을 열어가는 사람들이 있어. 우리도 같이 해보자',
      stage: 1,
    ),

    // 2단계
    Quest(
      questId: 4,
      title: '좋아하는/듣고싶은 말 적어보기',
      description: '자신에게 힘이 되는 말을 적어보세요',
      stage: 2,
    ),
    Quest(
      questId: 5,
      title: '좋아하는 음악을 듣기',
      description: '음악과 함께 휴식을 취해보세요',
      stage: 2,
    ),
    Quest(
      questId: 6,
      title: '물 한잔 마시기',
      description: '작은 습관부터 시작해보세요',
      stage: 2,
    ),

    // 쉬운 퀘스트
    Quest(
      questId: 7,
      title: '창문 열고 바깥 공기 마셔보기',
      description: '신선한 공기를 마시며 잠시 휴식을 취해보세요',
      stage: 2,
    ),
    Quest(
      questId: 8,
      title: '손 글씨로 "나는 잘하고 있어" 적어보기',
      description: '자신을 긍정적으로 표현해보세요',
      needsVerification: true,
      stage: 2,
    ),
    Quest(
      questId: 9,
      title: '미니 정리 정돈',
      description: '방 한 구석을 정리해보세요',
      isRequired: true,
      stage: 2,
    ),
    Quest(
      questId: 10,
      title: '3분간 스트레칭하기',
      description: '간단한 스트레칭으로 몸을 풀어보세요',
      isRequired: true,
      stage: 2,
    ),

    // 어려운 퀘스트
    Quest(
      questId: 11,
      title: '동네 편의점 다녀오기',
      description: '영수증을 인증해주세요',
      needsVerification: true,
      stage: 3,
    ),
    Quest(
      questId: 12,
      title: '도서관 책 대출받기',
      description: '대출증을 인증해주세요',
      needsVerification: true,
      stage: 3,
    ),
    Quest(
      questId: 13,
      title: '코인노래방 가보기',
      description: '마이크 사진을 찍어 인증해주세요',
      needsVerification: true,
      stage: 3,
    ),
  ];

  List<Stage> stages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStagesData();
  }

  void _loadStagesData() {
    // 모든 단계 데이터를 한 번에 초기화
    stages = [
      Stage(
        stageId: 1,
        title: "1단계 ",
        description: "튜토리얼",
        questId: [1, 2, 3],
      ),
      Stage(
        stageId: 2,
        title: "2단계",
        description: "마음 열기",
        questId: [4, 5, 6],
      ),
      Stage(
        stageId: 3,
        title: "3단계 ",
        description: "새로운 시작",
        questId: [7, 8, 9],
      ),
      Stage(
        stageId: 4,
        title: "4단계 ",
        description: "자아 탐색",
        questId: [10, 11, 12],
      ),
      Stage(
        stageId: 5,
        title: "5단계",
        description: "자기 돌봄",
        questId: [13, 14, 15],
      ),
      Stage(
        stageId: 6,
        title: "6단계 ",
        description: "환경 변화",
        questId: [16, 17, 18],
      ),
      Stage(
        stageId: 7,
        title: "7단계 ",
        description: "목표 설정",
        questId: [19, 20, 21],
      ),
      Stage(
        stageId: 8,
        title: "8단계 ",
        description: "음식 도전",
        questId: [22, 23, 24],
      ),
      Stage(
        stageId: 9,
        title: "9단계",
        description: "미래 계획",
        questId: [25, 26, 27],
      ),
      Stage(
        stageId: 10,
        title: "10단계 ",
        description: "온라인 활동",
        questId: [28, 29, 30],
      ),
      Stage(
        stageId: 11,
        title: "11단계 ",
        description: "창의적 활동",
        questId: [31, 32, 33],
      ),
      Stage(
        stageId: 12,
        title: "12단계 ",
        description: "첫 외출",
        questId: [34, 35, 36],
      ),
      Stage(
        stageId: 13,
        title: "13단계",
        description: "근교 산책",
        questId: [37, 38, 39],
      ),
      Stage(
        stageId: 14,
        title: "14단계 ",
        description: "외출 도전",
        questId: [40, 41, 42],
      ),
      Stage(
        stageId: 15,
        title: "15단계 ",
        description: "자기 관리",
        questId: [43, 44, 45],
      ),
      Stage(
        stageId: 16,
        title: "16단계 ",
        description: "외식 도전",
        questId: [46, 47, 48],
      ),
      Stage(
        stageId: 17,
        title: "17단계 ",
        description: "문화생활",
        questId: [49, 50, 51],
      ),
      Stage(
        stageId: 18,
        title: "18단계 ",
        description: "활동 도전",
        questId: [52, 53, 54],
      ),
      Stage(
        stageId: 19,
        title: "19단계",
        description: "사회적 연결",
        questId: [55, 56, 57],
      ),
    ];

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 각 단계별 퀘스트 완료 여부 확인
    bool isStageCompleted(int stageId) {
      return quests
          .where((quest) => quest.stage == stageId)
          .every((quest) => quest.isCompleted);
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo2.png',
              height: 36,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: stages.map((stage) {
                    // 이전 단계가 완료되었는지 확인
                    bool isPreviousStageCompleted = stage.stageId == 1 ||
                        isStageCompleted(stage.stageId - 1);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E8976),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Text(
                                stage.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                isPreviousStageCompleted
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                          children: isPreviousStageCompleted
                              ? quests
                                  .where(
                                      (quest) => quest.stage == stage.stageId)
                                  .map((quest) => _buildQuestTile(quest))
                                  .toList()
                              : <Widget>[],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }

  Widget _buildQuestTile(Quest quest) {
    void _showQuestDialog() async {
      try {
        print('퀘스트 시작 API 호출 시도: questId=${quest.questId}');
        final response = await ApiService.startQuest(1, quest.questId);

        if (!mounted) return;

        if (response.statusCode == 200) {
          // 퀘스트 시작 성공 후 다이얼로그 표시
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xFFF5F1ED),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quest.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF75553E),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7E4E2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                quest.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF75553E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (quest.needsVerification)
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            final completed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestVerificationScreen(
                                  questId: quest.questId,
                                  questTitle: quest.title,
                                  verificationType:
                                      quest.verificationType ?? 'image',
                                ),
                              ),
                            );

                            if (completed == true) {
                              try {
                                final completeResponse =
                                    await ApiService.completeQuest(
                                        1, quest.questId);

                                if (!mounted) return;

                                if (completeResponse.statusCode == 200) {
                                  setState(() {
                                    quest.isCompleted = true;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('퀘스트가 완료되었습니다!')),
                                  );
                                }
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('퀘스트 완료 처리 중 오류가 발생했습니다.')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9E8976),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '인증하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              final completeResponse =
                                  await ApiService.completeQuest(
                                      1, quest.questId);

                              if (!mounted) return;

                              if (completeResponse.statusCode == 200) {
                                setState(() {
                                  quest.isCompleted = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('퀘스트가 완료되었습니다!')),
                                );
                              }
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('퀘스트 완료 처리 중 오류가 발생했습니다.')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9E8976),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '완료하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      } catch (e, stackTrace) {
        print('퀘스트 시작 에러: $e');
        print('스택 트레이스: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('퀘스트 시작 중 오류가 발생했습니다: ${e.toString()}')),
          );
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFBEADA0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: quest.isCompleted ? null : _showQuestDialog,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        color: quest.isCompleted ? Colors.white : null,
                      ),
                      child: quest.isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 18,
                              color: Color(0xFF9E8976),
                            )
                          : null,
                    ),
                    Expanded(
                      child: Text(
                        quest.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (quest.needsVerification && !quest.isCompleted)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
