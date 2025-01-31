import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOOOR 로그인',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEFF), // 배경 색상
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              Image.asset('assets/images/dooor.png', height: 250),

              const SizedBox(height: 20),
              // 아이디 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: ' 아이디',
                    filled: true,
                    fillColor: const Color(0xffff5f5dc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 비밀번호 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    filled: true,
                    fillColor: const Color(0xffff5f5dc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 로그인 버튼
              SizedBox(
                width: 330,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그인 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEADA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      color: Color(0x1F000000),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 0),

              // 하단 텍스트 회원가입입 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40), // 왼쪽 여백 추가
                    child: TextButton(
                      onPressed: () {
                        // 회원가입 로직
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),

              // 비밀번호 찾기와 변경 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      // 아이디 찾기 로직
                    },
                    child: const Text(
                      '아이디 찾기',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Text(
                    '|',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                      onPressed: () {
                        // 비밀번호 변경 로직
                      },
                      child: const Text(
                        '비밀번호 변경',
                        style: TextStyle(color: Colors.grey),
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
