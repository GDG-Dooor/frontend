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
      title: '챗봇한테 인사해보기', // 퀘스트 제목
      description: '챗봇과 대화를 시작해보세요', // 퀘스트 설명
      stage: 1, // 퀘스트 단계
    ),
    Quest(
      questId: 2,
      title: '퀘스트 탭 클릭하기',
      description: '여기는 퀘스트창이야. 나는 네가 이 퀘스트를 깨면서 자신감을 얻었으면 좋겠어',
      stage: 1,
    ),
    Quest(
      questId: 3,
      title: '랭킹 탭 확인하기',
      description: '많은 사람들이 함께하고 있어. 한 번 봐봐',
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
      title: '물 한 잔 마시기',
      description: '물을 마시며 몸의 수분을 채워보세요',
      stage: 2,
    ),

    // 3단계
    Quest(
      questId: 7,
      title: '창문 열고 바깥 공기 마셔보기',
      description: '신선한 공기를 마시며 잠시 휴식을 취해보세요',
      stage: 3,
    ),
    Quest(
      questId: 8,
      title: '5분간 명상해보기',
      description: '마음을 가라앉히고 명상을 해보세요. 아무생각이나 해도 상관없어요',
      stage: 3,
    ),
    Quest(
      questId: 9,
      title: '모르는 영단어 5개 외우기',
      description: '영어 단어를 찾아보고, 외워보세요 \n외운 영어단어 5개를 써주세요',
      stage: 3,
    ),

    //4단계
    Quest(
      questId: 10,
      title: '손 글씨로 “나는 잘하고 있어” 적어보기',
      description: '손 글씨로 적고나서 사진을 찍어주세요',
      needsVerification: true,
      stage: 4,
    ),
    Quest(
      questId: 11,
      title: '본인에게 긍정적인 말 3번 하기',
      description: '긍정적인 말을 외쳐보세요',
      stage: 4,
    ),
    Quest(
      questId: 12,
      title: '오늘 하루를 포이에게 말해주세요',
      stage: 4,
      description: '당신의 현재 감정을 말해주세요',
    ),

    //5단계
    Quest(
      questId: 13,
      title: '집 안의 거울 닦아보기',
      description: '어떤 거울이든 상관없어요',
      stage: 5,
    ),
    Quest(
      questId: 13,
      title: '거울 앞에서 미소 지어보기',
      description: '거울 앞에서 미소를 지어보세요',
      stage: 5,
    ),
    Quest(
      questId: 13,
      title: '감사했던 일을 포이한테 말해주세요',
      description: '사소한거라도 상관없어요',
      stage: 5,
    ),
  ];

  List<Stage> stages = []; //stages는 각 스테이지(Stage) 정보를 저장하는 리스트
  bool isLoading =
      true; //isLoading은 데이터 로딩 상태를 나타내는 변수. true이면 로딩 중, false이면 로딩 완료 -> 목록을 정상적으로 표시.

  @override
  void initState() {
    super.initState();
    _loadStagesData(); //데이터 로딩 함수 호출
  }

  void _loadStagesData() {
    // 📌 API 호출을 통해 스테이지 정보를 불러오는 코드
    stages = [
      Stage(
        stageId: 1,
        title: "1단계 ",
        questId: [1, 2, 3],
      ),
      Stage(
        stageId: 2,
        title: "2단계",
        questId: [4, 5, 6],
      ),
      Stage(
        stageId: 3,
        title: "3단계 ",
        questId: [7, 8, 9],
      ),
      Stage(
        stageId: 4,
        title: "4단계 ",
        questId: [10, 11, 12],
      ),
      Stage(
        stageId: 5,
        title: "5단계",
        questId: [13, 14, 15],
      ),
      Stage(
        stageId: 6,
        title: "6단계 ",
        questId: [16, 17, 18],
      ),
      Stage(
        stageId: 7,
        title: "7단계 ",
        questId: [19, 20, 21],
      ),
      Stage(
        stageId: 8,
        title: "8단계 ",
        questId: [22, 23, 24],
      ),
      Stage(
        stageId: 9,
        title: "9단계",
        questId: [25, 26, 27],
      ),
      Stage(
        stageId: 10,
        title: "10단계 ",
        questId: [28, 29, 30],
      ),
      Stage(
        stageId: 11,
        title: "11단계 ",
        questId: [31, 32, 33],
      ),
      Stage(
        stageId: 12,
        title: "12단계 ",
        questId: [34, 35, 36],
      ),
      Stage(
        stageId: 13,
        title: "13단계",
        questId: [37, 38, 39],
      ),
      Stage(
        stageId: 14,
        title: "14단계 ",
        questId: [40, 41, 42],
      ),
      Stage(
        stageId: 15,
        title: "15단계 ",
        questId: [43, 44, 45],
      ),
      Stage(
        stageId: 16,
        title: "16단계 ",
        questId: [46, 47, 48],
      ),
      Stage(
        stageId: 17,
        title: "17단계 ",
        questId: [49, 50, 51],
      ),
      Stage(
        stageId: 18,
        title: "18단계 ",
        questId: [52, 53, 54],
      ),
      Stage(
        stageId: 19,
        title: "19단계",
        questId: [55, 56, 57],
      ),
    ];

    setState(() {
      isLoading = false;
    });
  }

  //퀘스트들이 모두 완료되었는지 확인
  @override
  Widget build(BuildContext context) {
    // 각 단계별 퀘스트 완료 여부 확인
    bool isStageCompleted(int stageId) {
      return quests
          .where((quest) =>
              quest.stage == stageId) // ✅ 특정 단계(stageId)에 해당하는 퀘스트 필터링
          .every((quest) => quest.isCompleted); // ✅ 해당 단계의 모든 퀘스트가 완료되었는지 확인
    }

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              //스크롤 가능하게 설정
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: stages.map((stage) {
                    //각 스테이지 UI 생성
                    // 이전 단계가 완료되었는지 확인
                    bool isPreviousStageCompleted = stage.stageId ==
                            1 || //첫 번째 스테이지(튜토리얼 단계)는 항상 열려 있음.
                        isStageCompleted(
                            stage.stageId - 1); //그 외 스테이지는 이전 스테이지가 완료된 경우에만 열림

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8), //스테이지 간격
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E8976), //배경색 적용
                        borderRadius: BorderRadius.circular(8), //모서리 둥글게
                      ),
                      child: Theme(
                        //테마 설정
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent, //구분선 투명하게 설정
                        ),
                        child: ExpansionTile(
                          //확장형 스테이지 : 클릭 시 펼쳐지는 리스트
                          title: Row(
                            children: [
                              Text(
                                stage.title,
                                style: const TextStyle(
                                  //스테이지 제목 스타일
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold, //굵게
                                ),
                              ),
                              const Spacer(), //오른쪽 여백
                              Icon(
                                isPreviousStageCompleted //이전 스테이지가 완료되었는지에 따라 아이콘 변경
                                    ? Icons.lock_open //완료된 경우
                                    : Icons.lock, //미완료된 경우
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                          children:
                              isPreviousStageCompleted //이전 스테이지가 완료되었는지에 따라 퀘스트 목록 표시
                                  ? quests //퀘스트 목록
                                      .where(//특정 스테이지에 해당하는 퀘스트 필터링
                                          (quest) =>
                                              quest.stage ==
                                              stage
                                                  .stageId) //현재 stageId와 일치하는 퀘스트만 필터링
                                      .map((quest) =>
                                          _buildQuestTile(quest)) //퀘스트 UI 생성
                                      .toList()
                                  : <Widget>[],
                        ),
                      ),
                    );
                  }).toList(), //스테이지 목록을 리스트로 변환
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
          onTap:
              quest.isCompleted ? null : _showQuestDialog, // ✅ 퀘스트 완료 시 클릭 불가
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
