import 'dart:convert';
import 'package:flutter/foundation.dart';

class JwtUtils {
  static Map<String, dynamic> parseJwt(String token) {
    try {
      debugPrint('JWT 토큰 파싱 시작: $token');

      // Bearer 접두사 제거
      if (token.startsWith('Bearer ')) {
        token = token.substring(7);
        debugPrint('Bearer 접두사 제거 후: $token');
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        throw Exception('유효하지 않은 토큰 형식입니다.');
      }
      debugPrint('토큰 파트 개수: ${parts.length}');

      final payload = _decodeBase64(parts[1]);
      debugPrint('디코딩된 페이로드: $payload');

      final payloadMap = json.decode(payload);
      if (payloadMap is! Map<String, dynamic>) {
        throw Exception('유효하지 않은 페이로드 형식입니다.');
      }

      debugPrint('파싱된 페이로드 맵: $payloadMap');
      debugPrint('페이로드 키들: ${payloadMap.keys.toList()}');
      return payloadMap;
    } catch (e) {
      debugPrint('JWT 파싱 오류: $e');
      rethrow;
    }
  }

  static String _decodeBase64(String str) {
    try {
      debugPrint('Base64 디코딩 시작: $str');
      String output = str.replaceAll('-', '+').replaceAll('_', '/');

      switch (output.length % 4) {
        case 0:
          break;
        case 2:
          output += '==';
          break;
        case 3:
          output += '=';
          break;
        default:
          throw Exception('유효하지 않은 base64url 문자열입니다!');
      }

      debugPrint('패딩 추가 후: $output');
      final decoded = utf8.decode(base64Url.decode(output));
      debugPrint('Base64 디코딩 결과: $decoded');
      return decoded;
    } catch (e) {
      debugPrint('Base64 디코딩 오류: $e');
      rethrow;
    }
  }

  static String? getUserIdFromToken(String token) {
    try {
      final payload = parseJwt(token);
      debugPrint('JWT 페이로드 전체: $payload');
      debugPrint('JWT 페이로드 키들: ${payload.keys.toList()}');

      final userId = payload['sub'];
      if (userId != null) {
        debugPrint('추출된 사용자 ID: $userId');
        return userId.toString();
      } else {
        debugPrint('sub 클레임을 찾을 수 없습니다. 페이로드 키들: ${payload.keys.toList()}');
        return null;
      }
    } catch (e) {
      debugPrint('사용자 ID 추출 오류: $e');
      return null;
    }
  }
}
