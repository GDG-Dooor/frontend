import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/jwt_utils.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _accessTokenKey = 'access_token';
  static const String _completedQuestsKey = 'completed_quests';
  static const String _currentStageKey = 'current_stage';

  String? _token;
  String? _userId;
  String? _userName;
  String? _refreshToken;
  int? _currentQuestId;

  String? get currentToken => _token;
  String? get currentUserId => _userId;
  String? get currentUserName => _userName;
  String? get currentRefreshToken => _refreshToken;
  int? get currentQuestId => _currentQuestId;

  set currentToken(String? value) {
    _token = value;
    if (value != null) {
      saveToken(value);
    }
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    debugPrint('토큰 저장 완료: $token');
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
    debugPrint('리프레시 토큰 저장 완료: $refreshToken');
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      _token = accessToken.startsWith('Bearer ')
          ? accessToken
          : 'Bearer $accessToken';
      _refreshToken = refreshToken;

      final prefs = await SharedPreferences.getInstance();
      // _tokenKey와 _accessTokenKey 모두에 저장
      await prefs.setString(_tokenKey, _token!);
      await prefs.setString(_accessTokenKey, _token!);
      await prefs.setString(_refreshTokenKey, refreshToken);

      debugPrint('액세스 토큰 저장 완료: $_token');
      debugPrint('리프레시 토큰 저장 완료: $_refreshToken');
    } catch (e) {
      debugPrint('토큰 저장 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      debugPrint('저장된 토큰 조회: $token');
      return token;
    } catch (e) {
      debugPrint('토큰 조회 중 오류 발생: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      debugPrint('리프레시 토큰 조회 중 오류 발생: $e');
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_completedQuestsKey);
      await prefs.remove(_currentStageKey);
      debugPrint('모든 토큰 삭제 완료');
    } catch (e) {
      debugPrint('토큰 삭제 중 오류 발생: $e');
      rethrow;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      debugPrint('사용자 ID 저장 완료: $userId');
    } catch (e) {
      debugPrint('사용자 ID 저장 중 오류 발생: $e');
      rethrow;
    }
  }

  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('사용자 ID 조회 중 오류 발생: $e');
      return null;
    }
  }

  Future<void> loadToken() async {
    try {
      debugPrint('토큰 로드 시작');
      final prefs = await SharedPreferences.getInstance();

      // 저장된 토큰 로드 (_tokenKey와 _accessTokenKey 모두 확인)
      _token = prefs.getString(_accessTokenKey) ?? prefs.getString(_tokenKey);
      debugPrint('저장소에서 로드된 토큰: $_token');

      // 저장된 사용자 ID 로드
      _userId = prefs.getString(_userIdKey);
      debugPrint('저장소에서 로드된 사용자 ID: $_userId');

      // 저장된 리프레시 토큰 로드
      _refreshToken = prefs.getString(_refreshTokenKey);
      debugPrint('저장소에서 로드된 리프레시 토큰: $_refreshToken');

      // 저장된 현재 퀘스트 ID 로드
      _currentQuestId = prefs.getInt('current_quest_id');
      debugPrint('저장소에서 로드된 현재 퀘스트 ID: $_currentQuestId');

      if (_token != null) {
        try {
          // 토큰 유효성 검증 및 사용자 정보 재추출
          final cleanToken = _token!.replaceAll('Bearer ', '');
          final parts = cleanToken.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decodedPayload = utf8.decode(base64Url.decode(normalized));
            final payloadJson = jsonDecode(decodedPayload);

            debugPrint('토큰 페이로드: $payloadJson');

            if (payloadJson['sub'] != null) {
              _userId = payloadJson['sub'].toString();
              debugPrint('토큰에서 추출된 사용자 ID: $_userId');
              await saveUserId(_userId!);
            }

            if (payloadJson['userName'] != null) {
              _userName = payloadJson['userName'].toString();
              debugPrint('토큰에서 추출된 사용자 이름: $_userName');
            }

            // 토큰 만료 체크 및 갱신
            if (isTokenExpired()) {
              debugPrint('토큰이 만료되었습니다. 재발급을 시도합니다.');
              final refreshed = await refreshAccessToken();
              if (!refreshed) {
                debugPrint('토큰 재발급 실패');
                await clearTokens();
              }
            }
          } else {
            debugPrint('유효하지 않은 토큰 형식입니다.');
            await clearTokens();
          }
        } catch (e) {
          debugPrint('토큰 검증 중 오류: $e');
          await clearTokens();
        }
      } else {
        debugPrint('저장된 토큰이 없습니다.');
        // 앱 시작 시 토큰이 없는 경우 로그인 화면으로 이동
        if (prefs.getBool('is_first_run') ?? true) {
          await prefs.setBool('is_first_run', false);
        }
      }
    } catch (e) {
      debugPrint('토큰 로드 중 오류: $e');
      await clearTokens();
    }
  }

  Future<void> clearToken() async {
    try {
      debugPrint('토큰 초기화 시작');
      _token = null;
      _userId = null;
      _refreshToken = null;
      _currentQuestId = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove('current_quest_id');

      debugPrint('토큰 초기화 완료');
    } catch (e) {
      debugPrint('토큰 초기화 중 오류: $e');
    }
  }

  bool isTokenExpired() {
    final token = currentToken;
    if (token == null) return true;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      // 현재 시간보다 5분 이내로 남은 경우도 만료로 처리
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp - now < 300; // 5분
    } catch (e) {
      debugPrint('토큰 만료 확인 중 오류: $e');
      return true;
    }
  }

  bool isRefreshTokenExpired() {
    final refreshToken = currentRefreshToken;
    if (refreshToken == null) return true;

    try {
      final parts = refreshToken.split('.');
      if (parts.length != 3) return true;

      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );

      final exp = payload['exp'] as int?;
      if (exp == null) return true;

      // 현재 시간보다 1일 이내로 남은 경우도 만료로 처리
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp - now < 86400; // 1일
    } catch (e) {
      debugPrint('리프레시 토큰 만료 확인 중 오류: $e');
      return true;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = currentRefreshToken;
      if (refreshToken == null) {
        debugPrint('리프레시 토큰이 없습니다.');
        return false;
      }

      if (isRefreshTokenExpired()) {
        debugPrint('리프레시 토큰이 만료되었습니다.');
        await clearTokens();
        return false;
      }

      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/token'),
        headers: headers,
        body: json.encode({'refreshToken': refreshToken}),
      );

      debugPrint('토큰 갱신 응답 상태: ${response.statusCode}');
      debugPrint('토큰 갱신 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newAccessToken = data['accessToken'] as String?;

        if (newAccessToken != null) {
          await saveToken('Bearer $newAccessToken');
          debugPrint('토큰 갱신 성공');
          return true;
        }
      }

      debugPrint('토큰 갱신 실패');
      await clearTokens();
      return false;
    } catch (e) {
      debugPrint('토큰 갱신 중 오류: $e');
      await clearTokens();
      return false;
    }
  }

  Future<void> revokeToken() async {
    try {
      debugPrint('토큰 폐기 시도');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/token/revoke'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('토큰 폐기 응답 상태: ${response.statusCode}');
      debugPrint('토큰 폐기 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('토큰 폐기 성공');
        await clearTokens();
      } else {
        debugPrint('토큰 폐기 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('토큰 폐기 실패: $e');
    }
  }

  Future<bool> validateReceipt(String imageUrl) async {
    try {
      if (_currentQuestId == null) {
        debugPrint('현재 진행중인 퀘스트가 없습니다.');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quests/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': _token ?? '',
        },
        body: jsonEncode({
          'questId': _currentQuestId,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_receipt'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('영수증 검증 중 오류: $e');
      return false;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // _tokenKey와 _accessTokenKey 모두 확인
      String? token =
          prefs.getString(_accessTokenKey) ?? prefs.getString(_tokenKey);

      if (token == null) {
        debugPrint('저장된 토큰이 없습니다.');
        return null;
      }

      // Bearer 토큰 형식으로 반환
      if (!token.startsWith('Bearer ')) {
        token = 'Bearer $token';
      }

      return token;
    } catch (e) {
      debugPrint('토큰 가져오기 오류: $e');
      return null;
    }
  }

  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  static Future<Map<int, bool>> getCompletedQuests() async {
    final prefs = await SharedPreferences.getInstance();
    final completedQuestsJson = prefs.getString(_completedQuestsKey);

    if (completedQuestsJson == null) {
      return {};
    }

    try {
      final Map<String, dynamic> decoded = jsonDecode(completedQuestsJson);
      return decoded
          .map((key, value) => MapEntry(int.parse(key), value as bool));
    } catch (e) {
      return {};
    }
  }

  static Future<void> saveCompletedQuests(
      Map<int, bool> completedQuests) async {
    final prefs = await SharedPreferences.getInstance();
    final completedQuestsJson = jsonEncode(
        completedQuests.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString(_completedQuestsKey, completedQuestsJson);
  }

  static Future<int> getCurrentStage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_currentStageKey) ?? 1;
  }

  static Future<void> saveCurrentStage(int stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStageKey, stage);
  }
}

final tokenService = TokenService();

/*
사용 예시:
// 토큰 발급
try {
  final tokenData = await tokenService.getToken();
  final accessToken = tokenData['accessToken'];
  final userId = tokenData['userId'];
  print('발급된 토큰: $accessToken');
  print('사용자 ID: $userId');
} catch (e) {
  print('토큰 발급 실패: $e');
}

// 토큰 폐기
try {
  await tokenService.revokeToken();
  print('토큰이 성공적으로 폐기되었습니다.');
} catch (e) {
  print('토큰 폐기 실패: $e');
}
*/
