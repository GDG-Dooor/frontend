import 'package:flutter/material.dart';
import 'package:flutter_project_final/loading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //디버그 배너 제거
      title: 'DOOOR',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFE7E4E2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF75553E),
          surface: const Color(0xFFE7E4E2),
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}
