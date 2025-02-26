import 'package:flutter/material.dart';
import 'withdrawal_screen.dart';
import 'notification_settings_screen.dart';
import 'terms_of_service_screen.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8),
              child: Text(
                '내 프로필',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            // 프로필 이미지
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '도라에몽',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // 계정 섹션
            _buildSection('계정', ['아이디', '비밀번호 변경', '이메일 변경', '회원탈퇴', '로그아웃']),
            const SizedBox(height: 16),
            // 기타 섹션
            _buildSection('기타', ['공지사항', '정보 등의 설정', '서비스 이용약관', '알림 설정']),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
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
        ...items.map((item) => _buildMenuItem(item)).toList(),
      ],
    );
  }

  Widget _buildMenuItem(String title) {
    return InkWell(
      onTap: () {
        if (title == '로그아웃') {
          _logout();
        } else if (title == '회원탈퇴') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WithdrawalScreen()),
          );
        } else if (title == '알림 설정') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationSettingsScreen(),
            ),
          );
        } else if (title == '서비스 이용약관') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsOfServiceScreen(),
            ),
          );
        }
      },
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

  Future<void> _logout() async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/user/logout'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // 로그아웃 성공
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const login()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중 오류가 발생했습니다.')),
      );
    }
  }
}
