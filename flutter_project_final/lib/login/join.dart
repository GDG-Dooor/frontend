import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'join2.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  // StatelessWidget에서 StatefulWidget으로 변경
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  bool _isIdAvailable = false; // 아이디 사용 가능 여부
  String _selectedGender = '';

  Future<void> _checkId() async {
    if (_idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력해주세요.')),
      );
      return;
    }

    try {
      print('중복 체크 시작 - 아이디: ${_idController.text}');
      final response = await ApiService.checkId(_idController.text);
      print('서버 응답 받음');

      if (response.statusCode == 200) {
        setState(() {
          _isIdAvailable = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('사용 가능한 아이디입니다.')),
          );
        }
      } else if (response.statusCode == 409) {
        setState(() {
          _isIdAvailable = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미 사용 중인 아이디입니다.')),
          );
        }
      } else {
        print('예상치 못한 상태 코드: ${response.statusCode}');
        print('응답 내용: ${response.body}');
        setState(() {
          _isIdAvailable = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('중복 확인 중 오류가 발생했습니다. (상태 코드: ${response.statusCode})'),
            ),
          );
        }
      }
    } catch (e) {
      print('중복 체크 에러 상세: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  Future<void> _signup() async {
    try {
      if (_isIdAvailable &&
          _passwordController.text == _confirmPasswordController.text) {
        final response = await ApiService.signup({
          'id': _idController.text,
          'password': _passwordController.text,
          'name': _nameController.text,
          'birthDate': _birthDateController.text,
          'gender': _selectedGender,
        });

        if (response.statusCode >= 200 && response.statusCode < 300) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RegistrationScreen2()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('회원가입에 실패했습니다. 다시 시도해주세요.')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('입력 정보를 확인해주세요.')),
        );
      }
    } catch (e) {
      print('회원가입 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 처리 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FEFF), // 배경 색상
      appBar: AppBar(
        leading: IconButton(
          // 뒤로가기 버튼 추가
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 고정 로고 이미지
              Padding(
                padding: const EdgeInsets.only(top: 50), // 상단 여백 줄임
                child: Center(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 아이디 입력
              const Text(
                '아이디',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        hintText: '전화번호, 이메일을 적어주세요',
                        hintStyle: TextStyle(color: Color(0x8049454F)),
                        filled: true,
                        fillColor: const Color(0xCCFFF5DC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: _isIdAvailable
                            ? const Icon(Icons.check_circle,
                                color: Colors.green)
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _checkId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBEADA0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('중복확인'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 비밀번호 입력
              const Text(
                '비밀번호',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController, // 컨트롤러 연결
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '문자, 숫자 포함(8~20자)',
                  hintStyle: TextStyle(color: Color(0x8049454F)),
                  filled: true,
                  fillColor: const Color(0xCCFFF5DC),
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
                controller: _confirmPasswordController, // 컨트롤러 연결
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호 재입력',
                  hintStyle: TextStyle(color: Color(0x8049454F)),
                  filled: true,
                  fillColor: const Color(0xCCFFF5DC),
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
                    if (!_isIdAvailable) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('아이디 중복 확인을 해주세요.')),
                      );
                      return;
                    }
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      _signup(); // API 호출
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                      );
                    }
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
    );
  }
}
