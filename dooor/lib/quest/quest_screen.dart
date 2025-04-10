import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_project_final/quest/camera.dart';
import 'package:flutter_project_final/quest/quest_item.dart';
import '../models/quest.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/token_service.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/quest_service.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  List<Quest> _quests = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _currentStage = 1; // 현재 사용자의 단계
  Map<int, bool> _completedQuests = {}; // 완료된 퀘스트 목록
  Map<int, List<Quest>> _questsByStage = {}; // 스테이지별 퀘스트

  @override
  void initState() {
    super.initState();
    _loadQuestProgress();
    _fetchQuests();
  }

  // 완료된 퀘스트 목록 로드
  Future<void> _loadCompletedQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedQuestsJson = prefs.getString('completed_quests');
      final savedStage = prefs.getInt('current_stage') ?? 1;

      if (completedQuestsJson != null) {
        final Map<String, dynamic> decoded = jsonDecode(completedQuestsJson);
        setState(() {
          _completedQuests = decoded
              .map((key, value) => MapEntry(int.parse(key), value as bool));
          _currentStage = savedStage;
        });
        debugPrint('로드된 완료 퀘스트: $_completedQuests');
        debugPrint('로드된 현재 스테이지: $_currentStage');
      }
    } catch (e) {
      debugPrint('완료된 퀘스트 로드 오류: $e');
    }
  }

  // 완료된 퀘스트 저장
  Future<void> _saveCompletedQuests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedQuestsJson = jsonEncode(_completedQuests
          .map((key, value) => MapEntry(key.toString(), value)));
      await prefs.setString('completed_quests', completedQuestsJson);
      await prefs.setInt('current_stage', _currentStage);
      debugPrint('저장된 완료 퀘스트: $completedQuestsJson');
      debugPrint('저장된 현재 스테이지: $_currentStage');
    } catch (e) {
      debugPrint('완료된 퀘스트 저장 오류: $e');
    }
  }

  // 퀘스트 진행 상태 로드
  Future<void> _loadQuestProgress() async {
    try {
      final questService = QuestService();
      final progress = await questService.getQuestProgress();

      // List<bool>를 Map<int, bool>로 변환
      final Map<int, bool> completedQuests = {};
      for (int i = 0; i < progress.length; i++) {
        completedQuests[i + 1] = progress[i];
      }

      setState(() {
        _completedQuests = completedQuests;
        // 현재 스테이지 계산 (완료된 퀘스트 중 가장 높은 스테이지 + 1)
        _currentStage = completedQuests.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .fold(1, (max, stageId) => stageId > max ? stageId : max);
      });

      await _saveCompletedQuests();
    } catch (e) {
      debugPrint('퀘스트 진행 상태 로드 오류: $e');
      // 오류 발생 시 로컬 저장소에서 로드
      await _loadCompletedQuests();
    }
  }

  // 다음 스테이지 잠금 해제 확인
  void _checkStageUnlock() {
    // 현재 스테이지의 모든 퀘스트가 완료되었는지 확인
    final currentStageQuests = _questsByStage[_currentStage] ?? [];

    if (currentStageQuests.isEmpty) return;

    bool allCompleted = true;
    for (var quest in currentStageQuests) {
      if (_completedQuests[quest.questId] != true) {
        allCompleted = false;
        break;
      }
    }

    // 모든 퀘스트가 완료되었다면 다음 스테이지 언락
    if (allCompleted) {
      // 다음 스테이지가 존재하는지 확인
      if (_questsByStage.containsKey(_currentStage + 1)) {
        setState(() {
          _currentStage += 1;
        });
        _saveCompletedQuests(); // 새로운 스테이지 저장

        // 사용자에게 알림
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_currentStage}단계가 잠금 해제되었습니다!'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF816856),
          ),
        );
      }
    }
  }

  Future<void> _fetchQuests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // API 요청 헤더 설정
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json; charset=utf-8',
      };

      // 토큰이 있으면 Authorization 헤더 추가
      if (ApiService.authToken != null) {
        headers['Authorization'] = ApiService.authToken!;
      }

      // 새 API 서비스 사용
      final quests = await ApiService.getQuests(headers: headers);

      // 이미 API 서비스에서 받아온 퀘스트 목록 사용
      debugPrint('가져온 퀘스트 수: ${quests.length}');

      // 스테이지별로 그룹화
      final Map<int, List<Quest>> questsByStage = {};
      for (var quest in quests) {
        if (!questsByStage.containsKey(quest.stageId)) {
          questsByStage[quest.stageId] = [];
        }
        questsByStage[quest.stageId]!.add(quest);
      }

      // 정렬해서 저장
      final List<Quest> sortedQuests = [];
      final List<int> stages = questsByStage.keys.toList()..sort();
      for (var stage in stages) {
        sortedQuests.addAll(questsByStage[stage]!);
      }

      setState(() {
        _quests = sortedQuests;
        _questsByStage = questsByStage;
        _isLoading = false;
      });

      // 다음 스테이지 잠금 해제 여부 확인
      _checkStageUnlock();
    } catch (e) {
      debugPrint('퀘스트 목록 조회 오류: $e');
      setState(() {
        _errorMessage = '데이터 로드 중 오류가 발생했습니다: ${e.toString()}';
        _isLoading = false;
      });

      // 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('퀘스트를 불러오는 중 문제가 발생했습니다. 다시 시도해주세요.'),
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: _fetchQuests,
          ),
        ),
      );
    }
  }

  // 퀘스트 완료 처리
  Future<void> _completeQuest(Quest quest) async {
    try {
      // 이미 완료된 퀘스트인지 확인
      if (_completedQuests[quest.questId] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("이미 완료된 퀘스트입니다.")),
        );
        return;
      }

      // 📷 카메라 인증이 필요한 퀘스트의 경우
      if (quest.needImage) {
        debugPrint("카메라 필요 여부: ${quest.needImage}");

        // 카메라 화면으로 이동
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Camera_permission(
              questId: quest.questId,
              questTitle: quest.title,
              verificationType: "camera",
            ),
          ),
        );

        // 인증 실패 시 완료 처리 안 함
        if (result != true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("퀘스트 인증이 취소되었습니다.")),
          );
          return;
        }
      }

      // UI에서 완료 상태 표시 (API 요청과 무관하게)
      setState(() {
        _completedQuests[quest.questId] = true;
      });
      await _saveCompletedQuests();

      // API 요청 (사진이 필요 없는 경우 포함)
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (ApiService.authToken != null) {
        headers['Authorization'] = ApiService.authToken!;
      }

      try {
        final token = await TokenService.getAccessToken();
        if (token == null) {
          throw Exception('인증 토큰이 없습니다.');
        }

        // TokenService에서 사용자 ID 가져오기
        final userId = await TokenService.getUserId();
        if (userId == null) {
          throw Exception('사용자 ID를 찾을 수 없습니다.');
        }

        ApiService.completeQuest(
          questId: quest.questId,
          userId: int.parse(userId),
          headers: headers,
        ).then((success) {
          if (!success) {
            debugPrint('API 호출은 실패했지만 로컬에서는 완료 상태 유지');
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("퀘스트가 완료되었습니다!")),
        );

        // 다음 스테이지 잠금 해제 여부 확인
        _checkStageUnlock();
      } catch (e) {
        debugPrint('퀘스트 API 호출 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("오류 발생: 로컬에서 완료 처리됨")),
        );
        _checkStageUnlock();
      }
    } catch (e) {
      debugPrint('퀘스트 완료 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("오류 발생: 로컬에서 완료 처리됨")),
      );

      // 오류 발생 시에도 완료 상태 유지
      setState(() {
        _completedQuests[quest.questId] = true;
      });
      await _saveCompletedQuests();
      _checkStageUnlock();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 스테이지별로 퀘스트 그룹화
    Map<int, List<Quest>> questsByStage = {};
    for (var quest in _quests) {
      if (!questsByStage.containsKey(quest.stageId)) {
        questsByStage[quest.stageId] = [];
      }
      questsByStage[quest.stageId]!.add(quest);
    }

    // 스테이지 목록 (정렬됨)
    List<int> stages = questsByStage.keys.toList()..sort();

    // 스테이지별 완료 상태
    Map<int, bool> stageCompletionStatus = {};
    for (var stage in stages) {
      final stageQuests = questsByStage[stage] ?? [];
      bool allCompleted = stageQuests.isNotEmpty;
      for (var quest in stageQuests) {
        if (_completedQuests[quest.questId] != true) {
          allCompleted = false;
          break;
        }
      }
      stageCompletionStatus[stage] = allCompleted;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF816856)),
                ),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchQuests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9E8976),
                          ),
                          child: const Text("다시 시도"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: stages.length + 1, // +1은 안내 메시지를 위한 것입니다
                    itemBuilder: (context, index) {
                      if (index == stages.length) {
                        // 마지막에 점 세 개 표시
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Column(
                              children: [
                                Text("·",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                Text("·",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                Text("·",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      }

                      final stageId = stages[index];
                      final stageQuests = questsByStage[stageId] ?? [];
                      final bool isUnlocked = stageId <= _currentStage;
                      final bool isCompleted =
                          stageCompletionStatus[stageId] ?? false;

                      return Column(
                        children: [
                          // 스테이지 헤더
                          Container(
                            width: double.infinity,
                            color: isCompleted
                                ? const Color(0xFF5D4037)
                                : const Color(0xFF8B7363),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${stageId}단계",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (isCompleted)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "완료",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Icon(
                                  isUnlocked
                                      ? (isCompleted
                                          ? Icons.check_circle
                                          : Icons.arrow_drop_up)
                                      : Icons.lock,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),

                          // 잠금 해제된 단계만 퀘스트 보여주기
                          if (isUnlocked)
                            Container(
                              color: const Color(0xFFD1BFB0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: stageQuests.length,
                                itemBuilder: (context, questIndex) {
                                  final quest = stageQuests[questIndex];
                                  final bool isCompleted =
                                      _completedQuests[quest.questId] ?? false;

                                  return QuestListItem(
                                    quest: quest,
                                    isCompleted: isCompleted,
                                    onComplete: () => _completeQuest(quest),
                                    onCameraPressed: () =>
                                        _completeQuest(quest),
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
      ),
    );
  }
}
