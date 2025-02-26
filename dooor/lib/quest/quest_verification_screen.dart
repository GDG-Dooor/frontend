//퀘스트 인증화면

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuestVerificationScreen extends StatefulWidget {
  final int questId;
  final String questTitle;
  final String verificationType;

  const QuestVerificationScreen({
    super.key,
    required this.questId,
    required this.questTitle,
    required this.verificationType,
  });

  @override
  State<QuestVerificationScreen> createState() =>
      _QuestVerificationScreenState();
}

class _QuestVerificationScreenState extends State<QuestVerificationScreen> {
  bool _isVerifying = false;

  Future<void> _verifyQuest() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      // TODO: userId는 실제 로그인된 사용자 ID로 변경해야 합니다
      final response = await ApiService.completeQuest(1, widget.questId);

      if (!mounted) return;

      if (response.statusCode == 200) {
        // 퀘스트 완료 성공
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('퀘스트 인증이 완료되었습니다!')),
        );
        Navigator.pop(context, true); // 완료 상태를 반환
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('퀘스트를 완료할 수 없습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 처리 중 오류가 발생했습니다.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.questTitle),
        backgroundColor: const Color(0xFFE7E4E2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 퀘스트 정보 표시
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.questTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF75553E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '인증 유형: ${widget.verificationType}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 인증 안내 메시지
            Text(
              '퀘스트를 완료하셨나요?',
              style: TextStyle(
                fontSize: 18,
                color: Colors.brown[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '아래 버튼을 눌러 인증을 완료해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.brown[600],
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),

            // 인증하기 버튼
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyQuest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9E8976),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '인증 완료하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
