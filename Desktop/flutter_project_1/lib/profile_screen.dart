import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 프로필')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            SizedBox(height: 10),
            Text('사용자 닉네임', style: TextStyle(fontSize: 20)),
            Text('레벨: 3', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
