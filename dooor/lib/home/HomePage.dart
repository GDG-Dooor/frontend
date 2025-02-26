//포이랑 챗화면 연결

import 'package:flutter/material.dart';
import 'package:flutter_project_final/home/chatscreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // 홈 화면
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      appBar: AppBar(
        automaticallyImplyLeading: false, // 기본 뒤로가기 버튼 제거
        centerTitle: false, // 타이틀을 왼쪽 정렬
        backgroundColor: Colors.white,
        elevation: 0, // 앱바 그림자 제거
      ),
      body: Center(
        // 화면 중앙에 배치
        child: Column(
          // 세로로 배치
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          children: [
            // 자식 위젯
            GestureDetector(
              // 클릭 가능 위젯
              onTap: () {
                // 클릭 시
                // pushReplacement 대신 push 사용하여 네비게이션 스택 유지
                Navigator.push(
                  // 채팅 화면으로 이동
                  context,
                  MaterialPageRoute(
                    // 채팅 화면으로 이동
                    builder: (context) => const ChatScreen(), // 채팅 화면
                  ),
                );
              },
              child: Image.asset('assets/images/Character.png',
                  width: 300), // 포이 이미지
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
