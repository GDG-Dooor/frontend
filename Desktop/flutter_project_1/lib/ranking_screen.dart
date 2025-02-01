import 'package:flutter/material.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('랭킹')),
      body: ListView(
        children: const [
          ListTile(leading: CircleAvatar(child: Text('1')), title: Text('사용자A - 150점')),
          ListTile(leading: CircleAvatar(child: Text('2')), title: Text('사용자B - 140점')),
          ListTile(leading: CircleAvatar(child: Text('3')), title: Text('사용자C - 130점')),
        ],
      ),
    );
  }
}

