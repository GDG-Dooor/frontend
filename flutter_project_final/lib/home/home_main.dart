import 'package:flutter/material.dart';
import 'HomePage.dart';
import '../screens/quest_screen.dart';
import 'chatscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  // 각 탭에서 표시할 화면 리스트
  final List<Widget> _pages = [
    HomePage(), // 홈 화면
    QuestScreen(), // 퀘스트 화면
    // RankingPage(), // 랭킹 화면
    // ProfilePage(), // 프로필 화면
  ];

  // 탭이 변경될 때 호출되는 함수
  void _onItemTapped(int index) {
    if (index == 0) {
      // 채팅 아이콘 클릭 시
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChatScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        title: Image.asset('assets/images/Logo.png', height: 25),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pages[_selectedIndex], // 선택된 탭에 해당하는 화면 표시
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFEDE1D5),
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex, // 현재 선택된 탭
        onTap: _onItemTapped, // 탭 변경 시 호출될 함수
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '홈',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '퀘스트'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '랭킹'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
