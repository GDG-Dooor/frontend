import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  // StatelessWidget에서 StatefulWidget으로 변경
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _idController =
      TextEditingController(); // 아이디 입력 필드 컨트롤러
  final TextEditingController _passwordController =
      TextEditingController(); // 비밀번호 입력 필드 컨트롤러
  final TextEditingController _confirmPasswordController =
      TextEditingController(); // 비밀번호 확인 입력 필드 컨트롤러
  final TextEditingController _nameController =
      TextEditingController(); // 이름 입력 필드 컨트롤러
  bool _isIdAvailable = false; // 아이디 사용 가능 여부
  bool _isLoading = false; // 회원가입 중 로딩 여부

  @override
  void initState() {
    super.initState();
  }

  // 아이디 중복 확인
  Future<void> _checkId() async {
    if (_idController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력해주세요.')), // 아이디 입력 안했을 때
      );
      return;
    }

    // 중복 확인 요청
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
          _isIdAvailable = false; // 중복 확인 실패 시 사용 불가로 변경
        });

        if (mounted) // 화면이 그려진 상태에서만 실행
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '중복 확인 중 오류가 발생했습니다. (상태 코드: ${response.statusCode})'), // 중복 확인 중 오류 발생 시 메시지 출력
            ),
          );
        }
      }
    } catch (e) {
      // 예외 처리
      print('중복 체크 에러 상세: $e'); // 에러 상세 출력
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.')),
        ); // 서버 연결 실패 시 메시지 출력
      }
    }
  }

  Future<void> _signup() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // 1. 입력값 검증
      if (_nameController.text.isEmpty) {
        throw Exception('이름을 입력해주세요.');
      }
      if (_idController.text.isEmpty) {
        throw Exception('이메일을 입력해주세요.');
      }
      if (_passwordController.text.isEmpty) {
        throw Exception('비밀번호를 입력해주세요.');
      }
      if (_confirmPasswordController.text.isEmpty) {
        throw Exception('비밀번호 확인을 입력해주세요.');
      }

      if (!_isIdAvailable) {
        throw Exception('이메일 중복 확인을 해주세요.');
      }

      // 2. 비밀번호 확인
      if (_passwordController.text != _confirmPasswordController.text) {
        throw Exception('비밀번호가 일치하지 않습니다.');
      }

      // 3. 회원가입 요청
      final signupResponse = await ApiService.signup({
        'email': _idController.text.trim(),
        'password': _passwordController.text,
        'passwordConfirm': _confirmPasswordController.text,
        'name': _nameController.text.trim(),
      });

      if (!mounted) return;

      if (signupResponse['success'] == true) {
        // 성공 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signupResponse['message'])),
        );

        // ✅ 이름 저장 (SharedPreferences 사용)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', _nameController.text.trim());

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        Navigator.pop(context);
      } else {
        // 실패 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signupResponse['message'])),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('회원가입 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _idController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
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
              Padding(
                padding: EdgeInsets.zero, // 상단 여백 줄임
                child: Center(
                  child: Image.asset(
                    'assets/images/Logo.png',
                    height: 230,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                ' 이름',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: '이름을 입력해주세요',
                  hintStyle: TextStyle(color: Color(0x8049454F)),
                  filled: true,
                  fillColor: Color(0xCCFFF5DC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  // 입력값 검증
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요';
                  }
                  final nameRegExp = RegExp(r'^[a-zA-Z가-힣]+$');
                  if (!nameRegExp.hasMatch(value)) {
                    return '이름은 한글 또는 영문만 입력 가능합니다';
                  }
                  if (value.length < 2 || value.length > 10) {
                    return '이름은 2자 이상 10자 이하로 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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
                        hintText: '이메일을 적어주세요',
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

                  // 중복확인 버튼
                  ElevatedButton(
                    onPressed: _checkId, // 중복확인 함수 연결
                    style: ElevatedButton.styleFrom // 버튼 스타일
                        (
                      backgroundColor: const Color(0xFFBEADA0), // 배경색
                      shape: RoundedRectangleBorder(
                        // 모양
                        borderRadius: BorderRadius.circular(8), // 모서리 둥글기
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

              // 회원가입 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBEADA0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '회원가입',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              // 로그인 실패 시 비밀번호 재설정 옵션 표시
            ],
          ),
        ),
      ),
    );
  }
}
