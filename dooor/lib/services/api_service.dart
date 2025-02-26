import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'dart:async';
import 'dart:io';
import '../models/quest.dart';

// UserInfo 클래스를 최상위 레벨로 이동
class UserInfo {
  final int userId;
  final String email;
  final String password;
  final String name;
  final DateTime createdAt;
  final String role;
  final int rank;
  final GradeInfo currentGrade;
  final int currentQuestId;
  final bool currentQuestCleared;

  UserInfo({
    required this.userId,
    required this.email,
    required this.password,
    required this.name,
    required this.createdAt,
    required this.role,
    required this.rank,
    required this.currentGrade,
    required this.currentQuestId,
    required this.currentQuestCleared,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userId: json['userId'] as int,
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      role: json['role'] as String,
      rank: json['rank'] as int,
      currentGrade: GradeInfo.fromJson(json['currentGrade']),
      currentQuestId: json['currentQuestId'] as int,
      currentQuestCleared: json['currentQuestCleared'] as bool,
    );
  }
}

// GradeInfo 클래스를 최상위 레벨로 이동
class GradeInfo {
  final int gradeId;
  final String gradeName;
  final int requiredStage;
  final String description;
  final List<String> users;

  GradeInfo({
    required this.gradeId,
    required this.gradeName,
    required this.requiredStage,
    required this.description,
    required this.users,
  });

  factory GradeInfo.fromJson(Map<String, dynamic> json) {
    return GradeInfo(
      gradeId: json['gradeId'] as int,
      gradeName: json['gradeName'] as String,
      requiredStage: json['requiredStage'] as int,
      description: json['description'] as String,
      users: (json['users'] as List).map((e) => e as String).toList(),
    );
  }
}

class ApiService {
  static String? _authToken;
  static int? _userId; // 사용자 ID 저장을 위한 변수 추가

  // 토큰 getter 추가
  static String? get authToken => _authToken;
  static int? get userId => _userId;

  /// 공통 헤더 생성 메서드
  static Map<String, String> _getHeaders({bool requiresAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = _authToken!;
    }

    return headers;
  }

  /// 로그인 API
  static Future<http.Response> login(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/login').replace(
        queryParameters: {
          'email': email.trim(),
          'password': password,
        },
      );

      print('로그인 시도 - URL: $url');
      print('로그인 요청 헤더: ${_getHeaders(requiresAuth: false)}');

      try {
        final response = await http
            .post(
          url,
          headers: _getHeaders(requiresAuth: false),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('서버 연결 타임아웃: 30초 초과');
            throw TimeoutException('서버 응답 시간이 초과되었습니다. (30초)');
          },
        );

        print('응답 상태 코드: ${response.statusCode}');
        print('응답 헤더: ${response.headers}');
        print('응답 데이터: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final responseData = jsonDecode(response.body);
            print('파싱된 응답 데이터: $responseData');

            // accessToken 추출
            String? token = responseData['accessToken'];

            if (token != null) {
              _authToken =
                  token.startsWith('Bearer ') ? token : 'Bearer $token';
              print('저장된 토큰: $_authToken');

              // 토큰이 있으면 사용자 정보도 저장
              if (responseData['userId'] != null) {
                _userId = responseData['userId'] as int;
                print('사용자 ID 저장됨: $_userId');
              }
            } else {
              print('경고: 토큰을 찾을 수 없습니다.');
              print('전체 응답 데이터: $responseData');
              throw Exception('로그인은 성공했지만 인증 토큰을 찾을 수 없습니다.');
            }
          } catch (e, stackTrace) {
            print('토큰 파싱 에러: $e');
            print('스택 트레이스: $stackTrace');
            rethrow;
          }
        } else if (response.statusCode == 400) {
          throw Exception('이메일 또는 비밀번호가 일치하지 않습니다.');
        } else {
          throw Exception(
              '로그인 처리 중 오류가 발생했습니다. (상태 코드: ${response.statusCode})');
        }

        return response;
      } on SocketException catch (e) {
        print('서버 연결 에러 (SocketException): $e');
        throw Exception('서버에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.');
      } catch (e) {
        print('HTTP 요청 에러: $e');
        rethrow;
      }
    } catch (e) {
      print('로그인 에러 상세: $e');
      rethrow;
    }
  }

  /// 사용자 정보 조회 API
  static Future<UserInfo> getUserInfo(int userId) async {
    try {
      final url =
          Uri.parse('${ApiConfig.baseUrl}/user/id').replace(queryParameters: {
        'userId': userId.toString(),
      });

      print('사용자 정보 조회 요청 - URL: $url');

      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 데이터: ${response.body}');

      if (response.statusCode == 200) {
        return UserInfo.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('사용자를 찾을 수 없습니다.');
      } else {
        throw Exception('사용자 정보 조회 중 오류가 발생했습니다.');
      }
    } catch (e) {
      print('사용자 정보 조회 에러: $e');
      rethrow;
    }
  }

  /// 이메일 중복 체크 API
  static Future<http.Response> checkId(String email) async {
    try {
      final url = Uri.parse(
          '${ApiConfig.baseUrl}/user/check-id?email=${Uri.encodeComponent(email.trim())}');

      print('이메일 중복 체크 요청 - URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('이메일 중복 체크 에러: $e');
      rethrow;
    }
  }

  /// 회원가입 API
  static Future<http.Response> signup(Map<String, dynamic> signupData) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/signup');

      print('회원가입 요청 - URL: $url');
      print('회원가입 데이터: $signupData');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(signupData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('회원가입 에러: $e');
      rethrow;
    }
  }

  /// 채팅 메시지 전송 API
  static Future<http.Response> sendMessage(
      Map<String, dynamic> messageData) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/send');

      print('메시지 전송 요청 - URL: $url');

      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(messageData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('메시지 전송 에러: $e');
      rethrow;
    }
  }

  /// 개인화된 메시지 조회 API
  static Future<http.Response> getPersonalizedMessage() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/chat/personalized');

      print('개인화 메시지 요청 - URL: $url');

      final response = await http.get(
        url,
        headers: _getHeaders(),
      );

      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('개인화 메시지 조회 에러: $e');
      rethrow;
    }
  }

  /// 퀘스트 시작 API
  static Future<http.Response> startQuest(int userId, int questId) async {
    try {
      if (_authToken == null) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/quests/start').replace(
        queryParameters: {
          'userId': userId.toString(),
          'questId': questId.toString(),
        },
      );

      print('퀘스트 시작 요청 URL: $url');
      print('퀘스트 시작 요청 헤더: ${_getHeaders()}');

      final response = await http.post(url, headers: _getHeaders());

      print('퀘스트 시작 응답 상태 코드: ${response.statusCode}');
      print('퀘스트 시작 응답 헤더: ${response.headers}');
      print('퀘스트 시작 응답 내용: ${response.body}');

      if (response.statusCode == 403) {
        throw Exception('인증이 만료되었거나 유효하지 않습니다. 다시 로그인해주세요.');
      } else if (response.statusCode == 404) {
        throw Exception('사용자 또는 퀘스트를 찾을 수 없습니다.');
      } else if (response.statusCode != 200) {
        throw Exception('퀘스트 시작 중 오류가 발생했습니다. (상태 코드: ${response.statusCode})');
      }

      return response;
    } catch (e) {
      print('퀘스트 시작 에러: $e');
      rethrow;
    }
  }

  /// 퀘스트 완료 API
  static Future<http.Response> completeQuest(int userId, int questId) async {
    try {
      if (_authToken == null) {
        throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/quests/complete').replace(
        queryParameters: {
          'userId': userId.toString(),
          'questId': questId.toString(),
        },
      );

      print('퀘스트 완료 요청 URL: $url');
      print('퀘스트 완료 요청 헤더: ${_getHeaders()}');

      final response = await http.post(url, headers: _getHeaders());

      print('퀘스트 완료 응답 상태 코드: ${response.statusCode}');
      print('퀘스트 완료 응답 헤더: ${response.headers}');
      print('퀘스트 완료 응답 내용: ${response.body}');

      if (response.statusCode == 403) {
        throw Exception('인증이 만료되었거나 유효하지 않습니다. 다시 로그인해주세요.');
      }

      return response;
    } catch (e) {
      print('퀘스트 완료 에러: $e');
      rethrow;
    }
  }

// /// 카메라 api
// const express = require('express');
// const multer = require('multer');

// const app = express();
// const upload = multer({ dest: 'uploads/' });

// app.post('/api/upload', upload.single('image'), (req, res) => {
//     console.log("✅ 이미지 업로드 성공:", req.file);
//     res.json({ success: true, file: req.file });
// });

// app.listen(3000, () => console.log('서버 실행 중...'));

  /// 퀘스트 생성 API
  static Future<http.Response> createQuest(QuestCreateRequest request) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/quests/make');

    try {
      final response = await http.post(
        url,
        headers: _getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('퀘스트 생성 응답: ${response.body}');
      return response;
    } catch (e) {
      print('퀘스트 생성 에러: $e');
      rethrow;
    }
  }
}
