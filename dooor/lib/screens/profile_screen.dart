// 필요한 패키지와 화면 파일들을 import 합니다.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/token_service.dart';
import '../models/user.dart';
import 'withdrawal_screen.dart'; // 회원탈퇴 화면
import 'notification_settings_screen.dart'; // 알림 설정 화면
import 'terms_of_service_screen.dart'; // 이용약관 화면
import '../login/login_screen.dart'; // 로그인 화면

// ProfileScreen은 상태(State)가 변경될 수 있는 화면이므로 StatefulWidget을 사용합니다.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// 실제로 상태를 관리하고 UI를 구성하는 클래스
class _ProfileScreenState extends State<ProfileScreen> {
  final TokenService _tokenService = TokenService();
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';
  int? _currentQuestId;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadCurrentQuestId();
  }

  Future<void> _loadUserInfo() async {
    try {
      // 토큰 만료 체크 및 갱신
      if (_tokenService.isTokenExpired()) {
        final refreshed = await _tokenService.refreshAccessToken();
        if (!refreshed) {
          throw Exception('토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
        }
      }

      // API 요청 헤더 설정
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = _tokenService.currentToken!;
      }

      // 사용자 정보 조회
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/id').replace(
          queryParameters: {
            'userId': _tokenService.currentUserId.toString(),
          },
        ),
        headers: headers,
      );

      debugPrint('사용자 정보 조회 응답 상태: ${response.statusCode}');
      debugPrint('사용자 정보 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isEmpty) {
          throw Exception('서버에서 빈 응답을 받았습니다.');
        }
        try {
          final userData = jsonDecode(responseBody);
          setState(() {
            _user = User.fromJson(userData);
            _isLoading = false;
          });
        } catch (e) {
          debugPrint('JSON 파싱 오류: $e');
          throw Exception('서버 응답 형식이 올바르지 않습니다: $e');
        }
      } else if (response.statusCode == 404) {
        throw Exception('사용자를 찾을 수 없습니다.');
      } else {
        throw Exception('사용자 정보를 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('사용자 정보 조회 오류: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _changePassword(String newPassword) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = 'Bearer ${_tokenService.currentToken}';
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/password').replace(
          queryParameters: {
            'email': _user?.email,
            'newPassword': newPassword,
          },
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')),
        );
      } else if (response.statusCode == 403) {
        throw Exception('현재 비밀번호와 동일합니다.');
      } else if (response.statusCode == 404) {
        throw Exception('사용자를 찾을 수 없습니다.');
      } else {
        throw Exception('비밀번호 변경에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _changeName(String newName) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = 'Bearer ${_tokenService.currentToken}';
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/user/name').replace(
          queryParameters: {
            'userId': _tokenService.currentUserId.toString(),
            'newName': newName,
          },
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        setState(() {
          _user = User.fromJson({
            ..._user!.toJson(),
            'name': newName,
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('닉네임이 성공적으로 변경되었습니다.')),
        );
      } else if (response.statusCode == 403) {
        throw Exception('현재 사용중인 이름이거나 권한이 없습니다.');
      } else if (response.statusCode == 404) {
        throw Exception('사용자를 찾을 수 없습니다.');
      } else {
        throw Exception('닉네임 변경에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _logout() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = _tokenService.currentToken!;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/user/logout'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        await _tokenService.clearTokens();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        throw Exception('로그아웃에 실패했습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showUserIdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('아이디'),
        content: Text(_user?.email ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCurrentQuestId() async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = _tokenService.currentToken!;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/quest-id'),
        headers: headers,
      );

      debugPrint('퀘스트 ID 조회 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 ID 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody.isNotEmpty) {
          try {
            // 응답이 단순 숫자이므로 int로 직접 파싱
            final questId = int.tryParse(responseBody);
            if (questId != null) {
              setState(() {
                _currentQuestId = questId;
              });
              debugPrint('파싱된 퀘스트 ID: $questId');
            } else {
              debugPrint('퀘스트 ID 파싱 실패: 유효하지 않은 숫자 형식');
            }
          } catch (e) {
            debugPrint('퀘스트 ID 파싱 오류: $e');
          }
        } else {
          debugPrint('퀘스트 ID 응답이 비어있습니다.');
        }
      } else {
        debugPrint('퀘스트 ID 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('퀘스트 ID 조회 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16, top: 8),
                        child: Text(
                          '내 프로필',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.person, size: 50),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _user?.name ?? '',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _user?.email ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                            if (_currentQuestId != null) ...[
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSection('계정', [
                        _buildMenuItem('아이디', _showUserIdDialog),
                        _buildMenuItem('비밀번호 변경', () {
                          _showPasswordChangeDialog();
                        }),
                        _buildMenuItem('닉네임 변경', () {
                          _showNameChangeDialog();
                        }),
                        _buildMenuItem('회원탈퇴', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WithdrawalScreen()),
                          );
                        }),
                        _buildMenuItem('로그아웃', _logout),
                      ]),
                      const SizedBox(height: 16),
                      _buildSection('기타', [
                        _buildMenuItem('공지사항', () {
                          // TODO: 공지사항 화면으로 이동
                        }),
                        _buildMenuItem('정보 등의 설정', () {
                          // TODO: 정보 설정 화면으로 이동
                        }),
                        _buildMenuItem('서비스 이용약관', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const TermsOfServiceScreen()),
                          );
                        }),
                        _buildMenuItem('알림 설정', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const NotificationSettingsScreen()),
                          );
                        }),
                      ]),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showPasswordChangeDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: '새 비밀번호',
            hintText: '8~12자리의 비밀번호를 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.length >= 8 && controller.text.length <= 12) {
                _changePassword(controller.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('비밀번호는 8~12자리여야 합니다.')),
                );
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showNameChangeDialog() {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('닉네임 변경'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '새 닉네임',
            hintText: '새로운 닉네임을 입력하세요',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _changeName(controller.text);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('닉네임을 입력해주세요.')),
                );
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }
}
