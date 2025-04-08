import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/token_service.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../home/HomePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  late TokenService _tokenService;

  @override
  void initState() {
    super.initState();
    _tokenService = TokenService();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;

    // Form 상태 체크
    final formState = _formKey.currentState;
    if (formState == null) {
      debugPrint('Form이 초기화되지 않았습니다.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 양식을 초기화하는데 실패했습니다.')),
      );
      return;
    }

    // Form 유효성 검사
    if (!formState.validate()) {
      debugPrint('Form 유효성 검사 실패');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        throw Exception('이메일과 비밀번호를 모두 입력해주세요.');
      }

      debugPrint('로그인 시도 - 이메일: $email');
      debugPrint('로그인 시도 - 비밀번호 길이: ${password.length}');

      final response = await http.post(
        Uri.parse('http://15.164.103.136:8080/api/user/login')
            .replace(queryParameters: {
          'email': email,
          'password': password,
        }),
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('로그인 응답 상태 코드: ${response.statusCode}');
      debugPrint('로그인 응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final accessToken = responseData['accessToken'];
        final refreshToken = responseData['refreshToken'];

        if (accessToken != null && refreshToken != null) {
          await _tokenService.saveTokens(accessToken, refreshToken);
          debugPrint('로그인 성공 - 토큰 저장됨');

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인 성공')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          throw Exception('토큰이 응답에 포함되어 있지 않습니다.');
        }
      } else if (response.statusCode == 400) {
        throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
      } else {
        throw Exception('로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('로그인 오류: $e');
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
      });

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Image.asset(
                  'assets/images/logo.png',
                  height: 100,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이메일을 입력해주세요';
                    }
                    if (!value.contains('@')) {
                      return '올바른 이메일 형식을 입력해주세요';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요';
                    }
                    if (value.length < 8 || value.length > 12) {
                      return '비밀번호는 8~12자여야 합니다';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF75553E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
