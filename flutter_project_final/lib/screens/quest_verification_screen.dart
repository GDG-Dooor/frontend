import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuestVerificationScreen extends StatefulWidget {
  final String questId;
  final String questTitle;
  final String verificationType;

  const QuestVerificationScreen({
    Key? key,
    required this.questId,
    required this.questTitle,
    required this.verificationType,
  }) : super(key: key);

  @override
  _QuestVerificationScreenState createState() =>
      _QuestVerificationScreenState();
}

class _QuestVerificationScreenState extends State<QuestVerificationScreen> {
  bool _isVerifying = false;

  Future<void> _verifyQuest() async {
    setState(() {
      _isVerifying = true;
    });

    try {
      // 인증 타입에 따른 검증 로직
      switch (widget.verificationType) {
        case 'sky':
          // 하늘 사진 검증
          break;
        case 'egg':
          // 계란 요리 검증
          break;
        case 'library':
          // 도서관 대출증 검증
          break;
        case 'movie':
          // 영화 티켓 검증
          break;
        case 'mountain':
          // 등산 인증 검증
          break;
        case 'microphone':
          // 마이크 검증
          break;
        default:
          // 기본 검증
          break;
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
        backgroundColor: Colors.brown[300],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('퀘스트 인증: ${widget.questTitle}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isVerifying ? null : _verifyQuest,
              child: _isVerifying
                  ? const CircularProgressIndicator()
                  : const Text('인증하기'),
            ),
          ],
        ),
      ),
    );
  }
}
