import 'package:flutter/material.dart';
import '../screens/quest_verification_screen.dart';
import '../home/HomePage.dart';
import '../screens/ranking_screen.dart';
import '../screens/profile_screen.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  bool _isExpanded = true;
  List<bool> taskCompletion = List.filled(3, false); // 각 항목 완료 상태
  int currentStage = 1; // 현재 단계
  bool isTutorialComplete = false; // 튜토리얼 완료 여부
  int _selectedIndex = 1; // 현재 선택된 네비게이션 바 인덱스

  // 퀘스트 데이터 구조
  final List<Map<String, dynamic>> stages = [
    {
      'stage': 1,
      'title': '튜토리얼',
      'isRequired': true,
      'quests': [
        {
          'id': 'tutorial1',
          'title': '챗봇한테 인사해보기',
          'needsVerification': false,
          'verificationType': 'none'
        },
        {
          'id': 'tutorial2',
          'title': '퀘스트 탭 클릭하기',
          'needsVerification': false,
          'verificationType': 'none'
        },
        {
          'id': 'tutorial3',
          'title': '랭킹 탭 확인하기',
          'needsVerification': false,
          'verificationType': 'none'
        },
      ],
      'message': '안녕 여기는 퀘스트창이야. 나는 네가 이 퀘스트를 깨면서 자신감을 얻었으면 좋겠어',
    },
    {
      'stage': 2,
      'title': '쉬운 퀘스트 1',
      'quests': [
        {
          'id': 'easy1_1',
          'title': '좋아하는/듣고싶은 말 적어보기',
          'needsVerification': false,
          'verificationType': 'none'
        },
        {
          'id': 'easy1_2',
          'title': '좋아하는 음악을 듣기',
          'needsVerification': false,
          'verificationType': 'none'
        },
        {
          'id': 'easy1_3',
          'title': '물한잔 마시기',
          'needsVerification': false,
          'verificationType': 'none'
        },
      ],
    },
    {
      'stage': 3,
      'title': '인증 퀘스트',
      'quests': [
        {
          'id': 'verify1',
          'title': '하늘 사진 찍기',
          'needsVerification': true,
          'verificationType': 'sky'
        },
        {
          'id': 'verify2',
          'title': '계란 요리하기',
          'needsVerification': true,
          'verificationType': 'egg'
        },
        // ... 다른 인증 퀘스트들
      ],
    },
    // ... 다른 스테이지들 추가
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('퀘스트'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.brown[300],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          final isLocked = index > 0 && !isTutorialComplete; // 튜토리얼 완료 전에는 잠금

          return Card(
            color: Colors.brown[300],
            child: isLocked
                ? _buildLockedStageTile(stage['stage'])
                : _buildStageTile(stage),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFEDE1D5),
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '퀘스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: '랭킹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // 네비게이션 처리
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // 이미 퀘스트 페이지에 있으므로 아무 작업도 하지 않음
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RankingScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Widget _buildStageTile(Map<String, dynamic> stage) {
    return ExpansionTile(
      initiallyExpanded: stage['stage'] == 1, // 튜토리얼은 기본적으로 펼침
      title: Row(
        children: [
          Text('${stage['stage']}단계',
              style: const TextStyle(color: Colors.white)),
          if (stage['isRequired'] == true)
            const Text(' ★', style: TextStyle(color: Colors.yellow)),
        ],
      ),
      children: [
        if (stage['message'] != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(stage['message'],
                style: const TextStyle(color: Colors.white70)),
          ),
        ...List.generate(
          stage['quests'].length,
          (index) => _buildQuestItem(stage['quests'][index], index),
        ),
      ],
    );
  }

  Widget _buildQuestItem(Map<String, dynamic> quest, int index) {
    return ListTile(
      title: Row(
        children: [
          Text(quest['title'], style: const TextStyle(color: Colors.white)),
          if (quest['needsVerification'] == true)
            const Text(' ☑', style: TextStyle(color: Colors.white)),
        ],
      ),
      trailing: taskCompletion[index]
          ? const Icon(Icons.check_circle, color: Colors.white70)
          : const Icon(Icons.check_circle_outline, color: Colors.white70),
      onTap: () => _handleQuestTap(quest),
    );
  }

  Widget _buildLockedStageTile(int stage) {
    return ListTile(
      title: Text('$stage단계', style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.lock, color: Colors.white),
    );
  }

  void _handleQuestTap(Map<String, dynamic> quest) {
    if (quest['needsVerification'] == true) {
      // 인증이 필요한 퀘스트 처리
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestVerificationScreen(
            questId: quest['id'] ?? '',
            questTitle: quest['title'] ?? '',
            verificationType: quest['verificationType'] ?? 'default',
          ),
        ),
      );
    } else {
      // 일반 퀘스트 완료 처리
      setState(() {
        int questIndex =
            stages.expand((stage) => stage['quests']).toList().indexOf(quest);
        if (questIndex >= 0 && questIndex < taskCompletion.length) {
          taskCompletion[questIndex] = true;
        }
      });
      // TODO: 서버에 완료 상태 업데이트
    }
  }
}
