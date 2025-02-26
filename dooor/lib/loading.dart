// 초반 로딩 화면
import 'dart:async';

import 'login/login_screen.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => LoadingScreenmain();
}

class LoadingScreenmain extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후 로그인 화면으로 이동
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => login()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEFF), // 배경 색상
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지 표시
            Image.asset('assets/images/Logo.png', height: 500),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
