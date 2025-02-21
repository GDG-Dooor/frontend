import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class RegistrationScreen2 extends StatefulWidget {
  const RegistrationScreen2({super.key});

  @override
  State<RegistrationScreen2> createState() => _RegistrationScreen2State();
}

class _RegistrationScreen2State extends State<RegistrationScreen2> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  String selectedGender = '';

  @override
  void dispose() {
    nameController.dispose();
    birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEFF), // 배경 색상
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 고정 로고 이미지
              Padding(
                padding: const EdgeInsets.only(top: 150), // 상단 여백 추가
                child: Center(
                  child: Image.asset(
                    'assets/images/좌측상단 로고.png', // 로고 경로
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 이름 입력 필드
              const Text(
                ' 이름',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFFF5DC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 생년월일 입력 필드
              const Text(
                "생년월일을 입력하세요 (YYYY-MM-DD 형식)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: birthDateController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // 숫자만 입력
                ],
                decoration: const InputDecoration(
                  labelText: '생년월일',
                  hintText: 'YYYYMMDD',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // 성별 선택 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => selectedGender = '남자'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGender == '남자'
                          ? Colors.brown[200]
                          : const Color(0xFFFFF5DC),
                      foregroundColor: Colors.brown,
                    ),
                    child: const Text('남자'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => selectedGender = '여자'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedGender == '여자'
                          ? Colors.brown[200]
                          : const Color(0xFFFFF5DC),
                      foregroundColor: Colors.brown,
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
                  onPressed: () async {
                    try {
                      final response = await ApiService.signup({
                        'name': nameController.text,
                        'birthDate': birthDateController.text,
                        'gender': selectedGender,
                      });

                      if (response.statusCode == 200) {
                        if (mounted) {
                          // 회원가입 성공 시 로그인 페이지로 이동
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('회원가입이 완료되었습니다.')),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const login()),
                            (route) => false, // 스택의 모든 화면 제거
                          );
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
                          );
                        }
                      }
                    } catch (e) {
                      print('회원가입 에러: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEADA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '회원가입',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
