// 필요한 패키지와 화면 파일들을 import 합니다.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'withdrawal_screen.dart'; // 회원탈퇴 화면
import 'notification_settings_screen.dart'; // 알림 설정 화면
import 'terms_of_service_screen.dart'; // 이용약관 화면
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위해 사용
import '../config/api_config.dart'; // API 서버 주소 설정이 담긴 파일
import '../login/login_screen.dart'; // 로그인 화면

// ProfileScreen은 상태(State)가 변경될 수 있는 화면이므로 StatefulWidget을 사용합니다.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// 실제로 상태를 관리하고 UI를 구성하는 클래스
class _ProfileScreenState extends State<ProfileScreen> {
  String? userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 전체 배경색 설정
      backgroundColor: const Color(0xFFE7E4E2),
      body: SingleChildScrollView(
        // 화면이 작을 때 스크롤 가능하게 만듦
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 제목 "내 프로필"
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Text(
                '내 프로필',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20), // 공간 띄우기

            // 프로필 이미지와 닉네임
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    // 동그란 프로필 이미지
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50), // 기본 아이콘
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName ?? '',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // '계정' 관련 메뉴 섹션 (아이디, 비밀번호 변경 등)
            _buildSection('계정', ['아이디', '비밀번호 변경', '이메일 변경', '회원탈퇴', '로그아웃']),

            const SizedBox(height: 16),

            // '기타' 관련 메뉴 섹션 (공지사항, 알림설정 등)
            _buildSection('기타', ['공지사항', '정보 등의 설정', '서비스 이용약관', '알림 설정']),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserName(); // 저장된 이름 불러오기
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '이름 없음';
    });
  }

  // 섹션을 그리는 위젯 ('계정', '기타' 제목과 각각의 메뉴 리스트)
  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
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
        // 메뉴 항목들을 하나씩 생성해서 리스트로 반환
        ...items.map((item) => _buildMenuItem(item)).toList(),
      ],
    );
  }

  // 메뉴 항목 하나를 그리는 위젯
  Widget _buildMenuItem(String title) {
    return InkWell(
      // 클릭(터치) 가능한 영역을 만듦
      onTap: () {
        // 메뉴 클릭 시 어떤 기능을 수행할지 조건문으로 처리
        if (title == '로그아웃') {
          _logout(); // 로그아웃 기능 실행
        } else if (title == '회원탈퇴') {
          // 회원탈퇴 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
          );
        } else if (title == '알림 설정') {
          // 알림 설정 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationSettingsScreen(),
            ),
          );
        } else if (title == '서비스 이용약관') {
          // 이용약관 화면으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsOfServiceScreen(),
            ),
          );
        }
        // 다른 메뉴는 아직 기능 연결 안 되어 있음
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 메뉴 제목
            Text(title, style: const TextStyle(fontSize: 16)),
            // 오른쪽 화살표 아이콘
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // 로그아웃을 처리하는 비동기 함수
  Future<void> _logout() async {
    try {
      // 서버에 로그아웃 요청 보내기
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/logout'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 로그아웃 성공: 로그인 화면으로 이동 (기존 화면 모두 제거)
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const login()),
          (route) => false,
        );
      }
    } catch (e) {
      // 에러 발생 시 사용자에게 메시지 보여주기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
      );
    }
  }
}
