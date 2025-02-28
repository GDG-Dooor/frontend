//포이 누르고 들어갔을때 채팅 화면

import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'HomePage.dart';
import 'home_bottom.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [
    {"text": "안녕", "isUser": false},
    {"text": "난 포이야", "isUser": false},
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String _userName = '사용자';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    _initializeChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (_isInitialized) return;
    try {
      await _loadUserName();
      _isInitialized = true;
    } catch (e) {
      debugPrint('초기화 중 오류 발생: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadUserName() async {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      debugPrint('사용자 이름 로드 중 오류 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 정보를 불러오는데 실패했습니다.')),
      );
    }
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": text, "isUser": true});
      _isLoading = true;
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      debugPrint('전송하는 메시지: $text');
      final response = await http.post(
        Uri.parse('http://43.202.174.46:5000/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': text,
          'user_name': _userName,
        }),
      );

      if (!mounted) return;

      debugPrint('서버 응답 상태 코드: ${response.statusCode}');
      debugPrint('서버 응답 내용: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          debugPrint('파싱된 응답 데이터: $responseData');

          if (responseData is Map<String, dynamic>) {
            final botResponse =
                responseData['poi']; // 'response' 대신 'poi' 필드 사용
            if (botResponse != null) {
              setState(() {
                messages.add({"text": botResponse.toString(), "isUser": false});
              });
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => _scrollToBottom());
            } else {
              debugPrint('응답에 poi 필드가 없습니다: $responseData');
              setState(() {
                messages.add({"text": "죄송합니다. 응답을 받지 못했습니다.", "isUser": false});
              });
            }
          } else {
            debugPrint('예상치 못한 응답 형식입니다: $responseData');
            setState(() {
              messages
                  .add({"text": "죄송합니다. 응답 형식이 올바르지 않습니다.", "isUser": false});
            });
          }
        } catch (e) {
          debugPrint('응답 파싱 중 오류 발생: $e');
          setState(() {
            messages.add(
                {"text": "죄송합니다. 응답을 처리하는 중 오류가 발생했습니다.", "isUser": false});
          });
        }
      } else {
        debugPrint('서버 오류 응답: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지 전송에 실패했습니다.')),
        );
      }
    } catch (e) {
      debugPrint('네트워크 오류 발생: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
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
                MaterialPageRoute(builder: (context) => const Homebasic()),
              );
            },
          ),
        ),
        body: Column(
          children: [
            // 날짜 표시
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                todayDate,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),

            // 채팅 메시지 리스트
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final messageText =
                      msg["text"]?.toString() ?? "메시지를 불러올 수 없습니다.";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: msg["isUser"] == true
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: msg["isUser"] == true
                              ? const Color(0xFF816856)
                              : const Color(0xFFEDE1D5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          messageText,
                          style: TextStyle(
                            color: msg["isUser"] == true
                                ? Colors.white
                                : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 입력창
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE1D5),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: " 메시지를 입력하세요...",
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          onSubmitted: (text) => _sendMessage(text),
                          textInputAction: TextInputAction.send,
                        ),
                      ),
                    ),
                  ),
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.brown),
                            ),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.brown),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
