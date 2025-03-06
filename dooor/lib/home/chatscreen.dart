import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_project_final/config/api_config.dart';
import 'package:flutter_project_final/home/HomePage.dart';
import 'package:flutter_project_final/home/home_bottom.dart';
import 'package:flutter_project_final/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
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
      // final url = Uri.parse('${ApiConfig.baseUrl}/chat/message');
      // final token = ApiService.authToken;
      // print(token);
      // final headers = {
      //   'Content-Type': 'application/json',
      //   'Accept': 'application/json',
      //   if (token != null)
      //     'Authorization':
      //         token.startsWith('Bearer ') ? token : 'Bearer $token',
      // };

      // final response = await http.get(
      //   url,
      //   headers: headers,
      //   body: jsonEncode({"message": text}),
      // );
      final url = Uri.parse('http://15.164.103.136:8080/api/chat/message');
      // .replace(queryParameters: {'message': text});
      final token = ApiService.authToken;
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null)
          'Authorization':
              token.startsWith('Bearer ') ? token : 'Bearer $token',
      };
      final response = await http.get(
        url,
        headers: headers,
      );

      print(response.statusCode);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = jsonDecode(utf8.decode(response.bodyBytes));
        print(responseData);
        print(response.body);
        final botResponse = responseData['poi'];
        if (botResponse != null) {
          setState(() {
            messages.add({"text": botResponse.toString(), "isUser": false});
          });
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _scrollToBottom());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('메시지 전송 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류 발생')),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                todayDate,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Align(
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
                        msg["text"].toString(),
                        style: TextStyle(
                          color: msg["isUser"] == true
                              ? Colors.white
                              : Colors.black,
                          fontSize: 16,
                        ),
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
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: " 메시지를 입력하세요...",
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  _isLoading
                      ? const CircularProgressIndicator()
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
