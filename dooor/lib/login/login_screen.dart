import 'package:flutter/material.dart';
import 'package:flutter_project_final/home/home_bottom.dart';
import 'Password_change.dart';
import 'join.dart';
import '../services/api_service.dart';

class login extends StatelessWidget {
  const login({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await ApiService.login(
        _idController.text,
        _passwordController.text,
      );

      if (response.statusCode == 200) {
        // 로그인 성공
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Homebasic()),
          );
        }
      } else {
        // 로그인 실패
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('아이디 또는 비밀번호가 일치하지 않습니다.')),
          );
        }
      }
    } catch (e) {
      print('로그인 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
              Image.asset('assets/images/Logo.png', height: 250),

              const SizedBox(height: 20),
              // 아이디 입력 필드
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _idController,
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
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    hintStyle: const TextStyle(color: Color(0xE6BEADA0)),
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
                width: 300,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEADA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 0),

              // 하단 텍스트 회원가입 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 왼쪽 정렬
                children: [
                  // 회원가입 버튼
                  Padding(
                    padding: const EdgeInsets.only(left: 30), // 왼쪽 여백 추가
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
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
                    padding: const EdgeInsets.only(right: 30), // 오른쪽 여백 추가
                    child: Row(
                      children: [
                        // 비밀번호 변경 버튼
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
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
