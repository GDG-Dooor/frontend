import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

import '../config/api_config.dart';
import '../services/token_service.dart';
import '../home/HomePage.dart';
import '../home/home_bottom.dart';
import '../services/quest_service.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': '안녕! 난 포이야!',
      'isUser': false,
    });
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userIdStr = await TokenService.getUserId();
      if (userIdStr == null) {
        throw Exception('사용자 ID를 가져올 수 없습니다.');
      }

      final userId = int.tryParse(userIdStr);
      if (userId == null) {
        throw Exception('유효하지 않은 사용자 ID입니다: $userIdStr');
      }

      final message = await ChatService.getPersonalizedMessage(userId);
      setState(() {
        _messages.add({
          'text': message,
          'isUser': false,
        });
      });
    } catch (e) {
      debugPrint('채팅 기록 로드 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('채팅 기록을 불러오는데 실패했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    _messageController.clear();

    setState(() {
      _messages.add({
        'text': message,
        'isUser': true,
      });
    });

    try {
      final response = await ChatService.sendMessage(message);
      setState(() {
        _messages.add({
          'text': response,
          'isUser': false,
        });
      });
    } catch (e) {
      debugPrint('메시지 전송 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송에 실패했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF9E8976),
          title: const Text("dooor", style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                todayDate,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('채팅 기록을 불러오는 중...'),
                        ],
                      ),
                    )
                  : _messages.isEmpty
                      ? const Center(
                          child: Text(
                            '채팅 기록이 없습니다.\n새로운 메시지를 보내보세요!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Align(
                              alignment: message['isUser']
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                padding: const EdgeInsets.all(12),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                  minWidth: 0,
                                ),
                                decoration: BoxDecoration(
                                  color: message['isUser']
                                      ? Colors.blue[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  message['text'],
                                  style: const TextStyle(fontSize: 16),
                                  softWrap: true,
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
