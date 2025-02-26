//하단 내비게이션, 좌측 상단 로고 , 카메라 권한

import 'package:flutter/material.dart';
import 'package:flutter_project_final/quest/quest_screen.dart';
import 'package:flutter_project_final/screens/profile_screen.dart';
import 'package:flutter_project_final/screens/ranking_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'HomePage.dart';

class Homebasic extends StatefulWidget {
  const Homebasic({super.key});

  @override
  _HomebasicState createState() => _HomebasicState();
}

class _HomebasicState extends State<Homebasic> {
  int _selectedIndex = 0; // 현재 선택된 탭의 인덱스

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission(); // 🔹홈 화면 진입 시 권한 체크 및 요청
  }

  Future<void> _checkAndRequestCameraPermission() async {
    var status = await Permission.camera.status; // 현재 권한 상태 확인

    if (status.isGranted) {
      // 🔹 이미 권한이 허용된 경우, 팝업 없이 바로 리턴
      return;
    }

    // 🔹 권한이 없으면 요청 진행
    var newStatus = await Permission.camera.request();

    if (newStatus.isGranted) {
      _showDialog("카메라 권한 허용됨", "카메라를 사용할 수 있습니다.");
    } else if (newStatus.isDenied) {
      _showDialog("카메라 권한 거부됨", "설정에서 권한을 허용해주세요.");
    } else if (newStatus.isPermanentlyDenied) {
      _showDialog("카메라 권한 영구 거부됨", "앱 설정에서 직접 허용해야 합니다.");
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (title.contains("영구 거부")) {
                openAppSettings(); // 설정 앱 열기
              }
              Navigator.of(context).pop();
            },
            child: Text("확인"),
          ),
        ],
      ),
    );
  }

  // 각 탭에서 표시할 화면 리스트
  final List<Widget> _pages = [
    HomePage(), // 홈 화면
    QuestScreen(), // 퀘스트 화면
    RankingScreen(), // RankingPage(), // 랭킹 화면
    ProfileScreen() // ProfilePage(), // 프로필 화면
  ];

  // 🟢 탭 클릭 시 화면 변경
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        title: Image.asset('assets/images/Logo2.png', height: 30),
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
        onTap: _onItemTapped, // 🟢 탭 변경 시 호출
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
