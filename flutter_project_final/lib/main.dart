import 'package:flutter/material.dart';
import 'package:flutter_project_final/loading.dart';
import 'screens/ranking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quest_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //디버그 배너 제거
      title: 'DOOOR',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE7E4E2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF75553E),
          surface: const Color(0xFFE7E4E2),
        ),
      ),
      home: const LoadingScreen(),
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const ChatScreen(),
    const QuestScreen(),
    const RankingScreen(),
    const ProfileScreen(),
  ];

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
