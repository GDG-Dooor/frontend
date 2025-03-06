import 'package:flutter/material.dart';
import 'package:flutter_project_final/home/chatscreen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand, // Stack이 전체 화면을 채우도록 설정
        children: [
          // 배경 이미지
          Image.asset(
            'assets/images/back_pink.jpg', // 배경 이미지 경로 (직접 추가해주세요)
            fit: BoxFit.cover, // 이미지가 전체 화면을 덮도록 설정
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatScreen(),
                      ),
                    );
                  },
                  child: Image.asset(
                    'assets/images/Character.png',
                    width: 300,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
