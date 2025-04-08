import 'package:flutter/material.dart';
import 'package:flutter_project_final/loading.dart';
import 'package:flutter_project_final/services/token_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 토큰 서비스 초기화 및 토큰 로드
  final tokenService = TokenService();
  await tokenService.loadToken();

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
