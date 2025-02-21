import 'package:flutter/material.dart';
import 'screens/ranking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/chat_screen.dart';
import 'splash_screen.dart'; // 주석 해제
// import 'home/HomePage.dart';  // 주석 처리

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DOOOR',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE7E4E2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF75553E),
          background: const Color(0xFFE7E4E2),
        ),
      ),
      home: const SplashScreen(), // 스플래시 화면으로 시작
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const ChatScreen(), // 0: 채팅
    const QuestScreen(), // 1: 퀘스트
    const RankingScreen(), // 2: 랭킹
    const ProfileScreen(), // 3: 프로필
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: const Color(0xFF75553E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '채팅'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: '퀘스트'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: '랭킹'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}
