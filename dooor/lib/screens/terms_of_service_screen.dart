//이용약관 화면

import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서비스이용약관')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '제1조(목적)',
              '도어 서비스 이용약관은 Dooor(이하 "회사"라 합니다)가 제공하는 도어 서비스 및 캠퍼스픽 서비스의 이용 과 관련하여 회사와 이용자 간의 권리, 의무 및 책임 사항 등을 규정 함을 목적으로 합니다.',
            ),
            const SizedBox(height: 24),
            _buildSection(
              '제2조(정의)',
              '1. 이 약관에서 사용하는 용어의 정의는 다음과 같습니다.',
              bulletPoints: [
                '"서비스"란, 회사가 제공하는 모든 서비스 및 기능을 말합니다',
                '"이용자"란, 이 약관에 따라 서비스를 이용하는 회원 및 비 회원을 말합니다.',
                '"회원"이란, 서비스에 회원등록을 하고 서비스를 이용하는 자를 말합니다.',
                '"비회원"이란, 서비스에 회원등록을 하지 않고 서비스를 이 용하는 자를 말합니다.',
                '"게시물"이란, 서비스에 게재된 문자, 사진, 영상, 첨부파일, 광고 등을 말합니다.',
                '"커뮤니티"란, 게시물을 게시할 수 있는 공간을 말합니다.',
                '"이용 기록"이란, 이용자가 서비스를 이용하면서 직접 생성 한 시간표, 친구, 학점 정보 등을 말합니다.',
                '"로그 기록"이란, 이용자가 서비스를 이용하면서 자동으로 생성된 IP 주소, 접속 시간 등을 말합니다.',
                '"기기 정보"란, 이용자의 통신 기기에서 수집된 유저 에이전트, ADID 등을 말합니다.',
                '"계정"이란, 이용계약을 통해 생성된 회원의 고유 아이디와 이에 수반하는 정보를 말합니다.',
                '"서비스 내부 알림 수단"이란, 팝업, 알림, 1:1 대화, 내 정보 메뉴 등을 말합니다.',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String content, {
    List<String>? bulletPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(content),
        if (bulletPoints != null) ...[
          const SizedBox(height: 8),
          ...bulletPoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('• '), Expanded(child: Text(point))],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
