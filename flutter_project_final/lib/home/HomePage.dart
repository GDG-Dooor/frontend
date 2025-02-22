import 'package:flutter/material.dart';
import '../main.dart';
import '../screens/chat_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/Logo2.png',
          height: 36, // 로고 크기를 2배로 증가
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // pushReplacement 대신 push 사용하여 네비게이션 스택 유지
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                );
              },
              child: Image.asset('assets/images/Character.png', width: 200),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
