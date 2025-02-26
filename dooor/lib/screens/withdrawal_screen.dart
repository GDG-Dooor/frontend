//회원 탈퇴 화면

import 'package:flutter/material.dart';

class WithdrawalScreen extends StatelessWidget {
  const WithdrawalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('계정 비밀번호')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 비밀번호 입력 필드
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '계정 비밀번호',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 안내 텍스트
            const Text(
              '※ 탈퇴 및 가입을 반복할 경우, 서비스 악용 방지를 위해 재가입이 제한됩니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              '최초 탈퇴 시에는 가입 시점을 기준으로 1일간 제한되며, 2회 이상 탈퇴를 반복할 경우 30일간 제한됩니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 탈퇴 후 개인정보, 시간표 등의 데이터가 삭제되며, 복구할 수 없습니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 다시 가입하여도, 계시판 등 이용 제한 기록은 초기화되지 않습니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 작성한 게시물은 삭제되지 않으며, (알수없음)으로 닉네임이 표시됩니다.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            const Text(
              '※ 자세한 내용은 개인정보처리방침을 확인해주세요.',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const Spacer(),
            // 회원 탈퇴 버튼
            ElevatedButton(
              onPressed: () {
                // 회원 탈퇴 로직 구현
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE45D5D),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '회원 탈퇴',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
