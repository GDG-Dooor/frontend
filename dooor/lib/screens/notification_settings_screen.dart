//알림 설정 화면

import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('데일리 브리핑')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '푸시를 하루에 한 번 알려드려요.',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            _buildSettingSection('수신 방법', '푸시'),
            _buildSettingSection('알림 시각', '오전 9시'),
            const SizedBox(height: 16),
            _buildChatSection(),
            const SizedBox(height: 16),
            _buildNoticeSection(),
            const SizedBox(height: 16),
            _buildEtcSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSection(String title, String value) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(title), Text(value)],
      ),
    );
  }

  Widget _buildChatSection() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('채팅'),
          const SizedBox(height: 8),
          const Text(
            '채팅방에 메시지를 받았을 때 알려드려요.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('수신 방법'), const Text('푸시')],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('알림에 메시지 내용 포함'), const Text('예')],
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeSection() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('공지'),
          const SizedBox(height: 8),
          const Text(
            '서비스 공지, 계정 상태 등 꼭 필요한 공지사항을 알려드려요.',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('수신 방법'), const Text('알림 페이지')],
          ),
        ],
      ),
    );
  }

  Widget _buildEtcSection() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('기타 설정'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [const Text('푸시 알림 방식')],
          ),
        ],
      ),
    );
  }
}
