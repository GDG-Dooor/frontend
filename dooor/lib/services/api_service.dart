import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/quest.dart';
import '../models/stage.dart';
import '../models/user.dart';
import 'package:flutter/foundation.dart';
import 'token_service.dart';

class ApiService {
  static const int maxRetries = ApiConfig.maxRetries;
  static const Duration timeout =
      Duration(seconds: ApiConfig.connectionTimeout);
  static String? _userId;
  static final TokenService tokenService = TokenService();

  static String? get userId => _userId;
  static set userId(String? value) => _userId = value;
  static String? get authToken => tokenService.currentToken;

  static Future<Map<String, String>> _getHeaders() async {
    final token = tokenService.currentToken;
    if (token == null) {
      throw Exception('인증 토큰이 없습니다.');
    }

    if (await tokenService.isTokenExpired()) {
      final refreshed = await tokenService.refreshAccessToken();
      if (!refreshed) {
        throw Exception('토큰이 만료되었고 재발급에 실패했습니다.');
      }
    }

    return {
      'Authorization': 'Bearer ${tokenService.currentToken}',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// 로그인 API
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    debugPrint('로그인 시도 시작 - 이메일: $email');

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        debugPrint('로그인 시도 ${retryCount + 1}/$maxRetries');

        // API 명세서에 맞게 POST 요청 구성
        final response = await http.post(
          Uri.parse(ApiConfig.login).replace(
            queryParameters: {
              'email': email,
              'password': password,
            },
          ),
          headers: {
            'Accept': '*/*',
          },
        ).timeout(timeout);

        debugPrint('로그인 응답 상태 코드: ${response.statusCode}');
        debugPrint('로그인 응답 데이터: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final accessToken = responseData['accessToken'];
          final refreshToken = responseData['refreshToken'];

          if (accessToken != null && refreshToken != null) {
            await tokenService.saveTokens(accessToken, refreshToken);

            // 토큰에서 사용자 ID 추출
            final parts = accessToken.split('.');
            if (parts.length == 3) {
              final payload = json.decode(
                  utf8.decode(base64.decode(base64.normalize(parts[1]))));
              userId = payload['sub'].toString();
            }

            debugPrint('로그인 성공 - 사용자 ID: $userId');
            return {
              'success': true,
              'message': '로그인 성공',
            };
          } else {
            throw Exception('토큰이 응답에 포함되어 있지 않습니다.');
          }
        } else if (response.statusCode == 400) {
          throw Exception('이메일 또는 비밀번호가 올바르지 않습니다.');
        } else if (response.statusCode == 403) {
          throw Exception('접근 권한이 없습니다.');
        } else {
          throw Exception('로그인 실패: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        debugPrint('로그인 시도 실패: $e');
        if (retryCount < maxRetries) {
          debugPrint('${ApiConfig.retryDelay}초 후 재시도...');
          await Future.delayed(Duration(seconds: ApiConfig.retryDelay));
        } else {
          rethrow;
        }
      }
    }
    throw Exception('로그인 시도가 모두 실패했습니다.');
  }

  /// 랭킹 정보 조회
  static Future<Map<String, dynamic>> getRankings(
      {required Map<String, String> headers}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ranking/all'),
        headers: headers,
      );

      debugPrint('전체 랭킹 조회 응답 상태: ${response.statusCode}');
      debugPrint('전체 랭킹 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'rankings': jsonDecode(response.body),
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'message': '인증이 필요합니다.',
        };
      } else {
        return {
          'success': false,
          'message': '랭킹 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      debugPrint('랭킹 조회 오류: $e');
      return {
        'success': false,
        'message': '랭킹 조회 중 오류가 발생했습니다.',
      };
    }
  }

  /// 퀘스트 점수 계산
  int calculateQuestScore(Quest quest) {
    int baseScore = 5; // 기본 점수
    int stageBonus = quest.stageId * 2; // 단계별 보너스 (2점씩 증가)
    int verificationBonus = quest.needImage ? 3 : 0; // 이미지 인증 보너스

    return baseScore + stageBonus + verificationBonus;
  }

  /// 사용자의 총 점수 계산
  Future<int> calculateUserTotalScore(String userId) async {
    try {
      final quests = await getQuests();
      final progress = await getUserQuestProgress();

      int totalScore = 0;
      for (var quest in quests) {
        if (quest.stageId <= progress) {
          totalScore += calculateQuestScore(quest);
        }
      }

      return totalScore;
    } catch (e) {
      debugPrint('점수 계산 실패: $e');
      return 0;
    }
  }

  /// 퀘스트 진행 상태 조회
  static Future<List<bool>> getQuestProgress() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/quest/progress');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e as bool).toList();
      }
      return List.filled(10, false); // 기본값 반환
    } catch (e) {
      print('퀘스트 진행 상태 조회 에러: $e');
      return List.filled(10, false);
    }
  }

  /// 퀘스트 목록 조회
  static Future<List<Quest>> getQuests({Map<String, String>? headers}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Quest.fromJson(json)).toList();
      } else {
        throw Exception('퀘스트 목록을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('퀘스트 목록 조회 오류: $e');
      rethrow;
    }
  }

  /// 특정 퀘스트 정보 조회
  static Future<Quest> getQuest(int questId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/quests/$questId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Quest.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('퀘스트를 찾을 수 없습니다.');
    } else {
      throw Exception('퀘스트 정보를 불러오는데 실패했습니다.');
    }
  }

  /// 퀘스트 생성
  static Future<Quest> createQuest({
    required String title,
    required String description,
    required int stageId,
    required bool needImage,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/quests/make');
      debugPrint('퀘스트 생성 요청: $url');

      final response = await http.post(
        url,
        headers: headers ?? await _getHeaders(),
        body: jsonEncode({
          'title': title,
          'description': description,
          'stageId': stageId,
          'needImage': needImage,
        }),
      );

      debugPrint('퀘스트 생성 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 생성 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return Quest.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 400) {
        throw Exception('잘못된 요청입니다.');
      } else {
        throw Exception('퀘스트 생성 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('퀘스트 생성 오류: $e');
      rethrow;
    }
  }

  /// 퀘스트 정보 업데이트
  static Future<Quest> updateQuest({
    required int questId,
    required String title,
    required String description,
    required int stageId,
    required bool needImage,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/quests/update');
      debugPrint('퀘스트 정보 업데이트 요청: $url');

      final response = await http.patch(
        url,
        headers: headers ?? await _getHeaders(),
        body: jsonEncode({
          'questId': questId,
          'title': title,
          'description': description,
          'stageId': stageId,
          'needImage': needImage,
        }),
      );

      debugPrint('퀘스트 정보 업데이트 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 정보 업데이트 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return Quest.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('퀘스트 정보 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('퀘스트 정보 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 퀘스트 이미지 검증
  static Future<bool> validateQuestImage(String image) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/quests/validate'),
      headers: await _getHeaders(),
      body: jsonEncode({'image': image}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('이미지 검증에 실패했습니다.');
    }
  }

  /// 퀘스트 시작
  static Future<bool> startQuest(int userId, int questId) async {
    final response = await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/quests/start?userId=$userId&questId=$questId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('사용자 또는 퀘스트를 찾을 수 없습니다.');
    } else {
      throw Exception('퀘스트 시작에 실패했습니다.');
    }
  }

  /// 퀘스트 완료
  static Future<bool> completeQuest({
    required int questId,
    required int userId,
    Map<String, String>? headers,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/quests/complete').replace(
        queryParameters: {
          'userId': userId.toString(),
          'questId': questId.toString(),
        },
      ),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  /// 사용자 퀘스트 진행상황 조회
  static Future<int> getUserQuestProgress() async {
    try {
      final headers = await _getHeaders();
      debugPrint('퀘스트 진행 상황 조회 요청 URL: ${ApiConfig.baseUrl}/user/quest-id');
      debugPrint('퀘스트 진행 상황 조회 요청 헤더: $headers');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/quest-id'),
        headers: headers,
      );

      debugPrint('퀘스트 진행 상황 조회 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 진행 상황 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('퀘스트 진행 상황을 찾을 수 없습니다.');
      } else {
        throw Exception('퀘스트 진행 상황을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('퀘스트 진행 상황 조회 오류: $e');
      rethrow;
    }
  }

  /// 사용자 진행중 퀘스트 성공여부 조회
  static Future<bool> getUserQuestCleared() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user/quest-cleared'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception('퀘스트 완료 여부를 확인하는데 실패했습니다.');
    }
  }

  /// 사용자 정보 조회
  static Future<User> getUserInfo(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user/id?userId=$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('사용자를 찾을 수 없습니다.');
    } else {
      throw Exception('사용자 정보를 불러오는데 실패했습니다.');
    }
  }

  /// 닉네임 변경
  static Future<bool> updateUserName(int userId, String newName) async {
    final response = await http.patch(
      Uri.parse(
          '${ApiConfig.baseUrl}/user/name?userId=$userId&newName=$newName'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception('닉네임 변경 실패: 현재 사용중인 이름 또는 권한 없음');
    } else if (response.statusCode == 404) {
      throw Exception('사용자를 찾을 수 없습니다.');
    } else {
      throw Exception('닉네임 변경에 실패했습니다.');
    }
  }

  /// 비밀번호 변경
  static Future<bool> resetPassword(String email, String newPassword) async {
    final response = await http.post(
      Uri.parse(
          '${ApiConfig.baseUrl}/user/password?email=$email&newPassword=$newPassword'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403) {
      throw Exception('비밀번호 재설정 실패: 현재 비밀번호와 동일');
    } else if (response.statusCode == 404) {
      throw Exception('사용자를 찾을 수 없습니다.');
    } else {
      throw Exception('비밀번호 재설정에 실패했습니다.');
    }
  }

  /// 회원 탈퇴
  static Future<bool> deleteUser() async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/user/delete'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('회원 탈퇴 실패');
    }
  }

  /// 로그아웃
  static Future<bool> logout() async {
    try {
      await tokenService.revokeToken();
      userId = null;
      return true;
    } catch (e) {
      debugPrint('로그아웃 오류: $e');
      return false;
    }
  }

  /// 회원가입 API
  static Future<Map<String, dynamic>> signup(
      Map<String, dynamic> userData) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/signup');
      print('회원가입 시도 - URL: $url');
      print('회원가입 요청 데이터: ${jsonEncode(userData)}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      print('회원가입 응답 상태 코드: ${response.statusCode}');
      print('회원가입 응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'message': '회원가입이 완료되었습니다.',
            'userId': responseData['userId'],
          };
        } catch (e) {
          print('응답 데이터 파싱 에러: $e');
          return {
            'success': false,
            'message': '서버 응답 형식이 올바르지 않습니다.',
          };
        }
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? '회원가입에 실패했습니다.',
          };
        } catch (e) {
          return {
            'success': false,
            'message': '회원가입에 실패했습니다.',
          };
        }
      } else {
        print('예상치 못한 상태 코드: ${response.statusCode}');
        return {
          'success': false,
          'message': '서버 오류가 발생했습니다. (상태 코드: ${response.statusCode})',
        };
      }
    } catch (e) {
      print('회원가입 에러 상세: $e');
      if (e is SocketException) {
        return {
          'success': false,
          'message': '서버에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.',
        };
      } else if (e is TimeoutException) {
        return {
          'success': false,
          'message': '서버 응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.',
        };
      } else {
        return {
          'success': false,
          'message': '회원가입 처리 중 오류가 발생했습니다. ($e)',
        };
      }
    }
  }

  /// 이메일 중복 확인 API
  static Future<http.Response> checkId(String email) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/check-email').replace(
        queryParameters: {
          'email': email,
        },
      );

      print('이메일 중복 확인 시도 - URL: $url');
      print('이메일 중복 확인 요청 데이터: email=$email');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('이메일 중복 확인 응답 상태 코드: ${response.statusCode}');
      print('이메일 중복 확인 응답 데이터: ${response.body}');

      return response;
    } catch (e) {
      print('이메일 중복 확인 에러: $e');
      return http.Response('', 500);
    }
  }

  /// 전체 단계 조회
  static Future<List<Stage>> getStages({Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/stage');
      debugPrint('전체 단계 조회 요청: $url');

      final response = await http.get(
        url,
        headers: headers ?? await _getHeaders(),
      );

      debugPrint('전체 단계 조회 응답 상태: ${response.statusCode}');
      debugPrint('전체 단계 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Stage.fromJson(json)).toList();
      } else {
        throw Exception('단계 목록 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('단계 목록 조회 오류: $e');
      rethrow;
    }
  }

  /// 특정 단계 조회
  static Future<Stage> getStageById(int stageId,
      {Map<String, String>? headers}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/stage/$stageId');
      debugPrint('특정 단계 조회 요청: $url');

      final response = await http.get(
        url,
        headers: headers ?? await _getHeaders(),
      );

      debugPrint('특정 단계 조회 응답 상태: ${response.statusCode}');
      debugPrint('특정 단계 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return Stage.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('단계를 찾을 수 없습니다.');
      } else {
        throw Exception('단계 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('단계 정보 조회 오류: $e');
      rethrow;
    }
  }

  /// 단계 정보 업데이트
  static Future<Stage> updateStage({
    required int stageId,
    required String title,
    required String description,
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/stage/update');
      debugPrint('단계 정보 업데이트 요청: $url');

      final response = await http.patch(
        url,
        headers: headers ?? await _getHeaders(),
        body: jsonEncode({
          'stageId': stageId,
          'title': title,
          'description': description,
        }),
      );

      debugPrint('단계 정보 업데이트 응답 상태: ${response.statusCode}');
      debugPrint('단계 정보 업데이트 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return Stage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('단계 정보 업데이트 실패: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('단계 정보 업데이트 오류: $e');
      rethrow;
    }
  }

  /// 사용자 개인 랭킹 조회
  static Future<Map<String, dynamic>> getUserRanking({
    required int userId,
    required Map<String, String> headers,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ranking/user?userId=$userId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('사용자 랭킹을 찾을 수 없습니다.');
    } else {
      throw Exception('랭킹 조회에 실패했습니다.');
    }
  }

  /// 전체 랭킹 조회
  static Future<Map<String, dynamic>> getAllRankings() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/ranking/all');
      debugPrint('전체 랭킹 조회 요청: $url');

      final headers = await _getHeaders();
      debugPrint('랭킹 조회 요청 헤더: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      debugPrint('전체 랭킹 조회 응답 상태: ${response.statusCode}');
      debugPrint('전체 랭킹 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> rankings = jsonDecode(response.body);
        return {
          'success': true,
          'data': rankings
              .map((ranking) => {
                    'rank': ranking['rank'],
                    'name': ranking['user']['name'],
                    'score': ranking['score'],
                    'userId': ranking['user']['userId'],
                  })
              .toList()
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': '랭킹이 존재하지 않습니다.',
        };
      } else {
        return {
          'success': false,
          'message': '랭킹 조회 실패: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('전체 랭킹 조회 오류: $e');
      return {
        'success': false,
        'message': '랭킹 조회 중 오류가 발생했습니다.',
      };
    }
  }

  /// 랭킹 점수 업데이트
  static Future<bool> updateRanking(int userId) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ranking/update?userId=$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 404) {
      throw Exception('사용자 랭킹을 찾을 수 없습니다.');
    } else {
      throw Exception('랭킹 업데이트에 실패했습니다.');
    }
  }
}

/// 사용자 정보 모델
class UserInfo {
  final int userId;
  final String email;
  final String name;

  UserInfo({
    required this.userId,
    required this.email,
    required this.name,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
    );
  }
}
