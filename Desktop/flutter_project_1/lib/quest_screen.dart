import 'package:flutter/material.dart';

class QuestScreen extends StatelessWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 퀘스트')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(
            leading: Icon(Icons.check_box_outline_blank),
            title: Text('물 한 잔 마시기'),
          ),
          ListTile(
            leading: Icon(Icons.check_box_outline_blank),
            title: Text('창문 열고 바깥 공기 마시기'),
          ),
          ListTile(
            leading: Icon(Icons.check_box_outline_blank),
            title: Text('30초 동안 밖에 나가보기'),
          ),
        ],
      ),
    );
  }
}
