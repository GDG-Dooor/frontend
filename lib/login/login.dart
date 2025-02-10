import 'package:dooor_1/home/join.dart';
import 'package:flutter/material.dart';

class login extends StatelessWidget {
  const login({super.key});

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
                    hintStyle: TextStyle(color: Color(0xE6BEADA0)),
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
                    hintStyle: TextStyle(color: Color(0xE6BEADA0)),
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
                      color: Color(0X4D000000),
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 0),

              // 하단 텍스트 회원가입입 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                children: [
                  // 회원가입 버튼
                  Padding(
                    padding: const EdgeInsets.only(left: 40), // 왼쪽 여백 추가
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegistrationScreen()),
                        );
                        // 회원가입 로직
                      },
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const Spacer(), // 빈 공간 추가 (회원가입과 나머지 버튼 간의 간격 조정)
                  // 오른쪽 정렬된 버튼들
                  Padding(
                    padding: const EdgeInsets.only(right: 40), // 오른쪽 여백 추가
                    child: Row(
                      children: [
                        // 아이디 찾기 버튼
                        TextButton(
                          onPressed: () {
                            // 아이디 찾기 로직
                          },
                          child: const Text(
                            '아이디 찾기',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        // 구분자 텍스트
                        const Text(
                          '|',
                          style: TextStyle(color: Colors.grey),
                        ),
                        // 비밀번호 변경 버튼
                        TextButton(
                          onPressed: () {
                            // 비밀번호 변경 로직
                          },
                          child: const Text(
                            '비밀번호 변경',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
