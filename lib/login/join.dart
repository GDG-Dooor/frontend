import 'package:dooor_1/home/join2.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEFF), // 배경 색상
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 로고 이미지
                Center(
                  child: Image.asset(
                    'assets/images/좌측상단 로고.png', // 로고 경로
                    height: 100, fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 40),

                // 아이디 입력
                const Text(
                  '아이디',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: '전화번호, 이메일을 적어주세요',
                    filled: true,
                    fillColor: const Color(0xFFFFF5DC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력
                const Text(
                  '비밀번호',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '문자, 숫자 포함(8~20자)',
                    filled: true,
                    fillColor: const Color(0xFFFFF5DC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 비밀번호 확인
                const Text(
                  '비밀번호 확인',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호 재입력',
                    filled: true,
                    fillColor: const Color(0xFFFFF5DC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 다음 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegistrationScreen2()),
                      );
                      // 다음 버튼 로직
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBEADA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '다음',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: RegistrationScreen(),
  ));
}
