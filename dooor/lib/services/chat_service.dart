import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_service.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/chat';
  static final TokenService _tokenService = TokenService();

  // 개인화된 메시지 가져오기
  static Future<String> getPersonalizedMessage(int userId) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/personalized/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['poi'] as String;
      } else if (response.statusCode == 404) {
        throw Exception('사용자를 찾을 수 없습니다. (userId: $userId)');
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('개인화된 메시지 가져오기 오류: $e');
      rethrow;
    }
  }

  // 메시지 전송 및 응답 받기
  static Future<String> sendMessage(String message) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      debugPrint('메시지 전송 요청 URL: $_baseUrl/message');
      debugPrint('전송할 메시지: $message');
      debugPrint('사용 토큰: $token');

      final response = await http.get(
        Uri.parse('$_baseUrl/message').replace(
          queryParameters: {
            'chatRequestDTO': json.encode({
              'message': message,
            }),
          },
        ),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('메시지 전송 응답 상태: ${response.statusCode}');
      debugPrint('메시지 전송 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['poi'] as String;
      } else if (response.statusCode == 400) {
        throw Exception('잘못된 요청입니다.');
      } else if (response.statusCode == 404) {
        throw Exception('API 엔드포인트를 찾을 수 없습니다.');
      } else {
        throw Exception('서버 오류: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('메시지 전송 오류: $e');
      rethrow;
    }
  }

  // 토큰 만료 시간 체크
  static Future<bool> _checkTokenExpiration(String token) async {
    try {
      // JWT 토큰 디코딩
      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('잘못된 토큰 형식입니다.');
      }

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      // 만료 시간 확인
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeUntilExpiration = exp - now;

      // 만료 5분 전이면 true 반환
      return timeUntilExpiration < 300;
    } catch (e) {
      debugPrint('토큰 만료 시간 체크 오류: $e');
      return false;
    }
  }
}
