import 'package:flutter/material.dart';

class RegistrationScreen2 extends StatelessWidget {
  const RegistrationScreen2({super.key});

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

                // 이름 입력 필드
                TextField(
                  decoration: InputDecoration(
                    hintText: '이름',
                    filled: true,
                    fillColor: const Color(0xFFFFF5DC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 생년월일 입력 필드
                TextField(
                  decoration: InputDecoration(
                    hintText: '생년월일',
                    filled: true,
                    fillColor: const Color(0xFFFFF5DC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 성별 선택 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // 남자 선택 로직
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF5DC),
                        foregroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('남자'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 여자 선택 로직
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF5DC),
                        foregroundColor: Colors.brown,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('여자'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // 회원가입 로직
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBEADA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
