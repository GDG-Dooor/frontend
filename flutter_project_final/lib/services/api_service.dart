import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'dart:async';
import 'dart:io';
import '../models/stage.dart';

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
  /// 로그인 API
  static Future<http.Response> login(String email, String password) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/user/login')
          .replace(queryParameters: {
        'email': email.trim(),
        'password': password,
      });

      print('로그인 시도 - URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('서버 응답 시간이 초과되었습니다.');
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 헤더: ${response.headers}');
      print('응답 데이터: ${response.body}');

      switch (response.statusCode) {
        case 200:
          return response;
        case 403:
          throw Exception('이메일 또는 비밀번호가 일치하지 않습니다.');
        case 400:
          throw Exception('잘못된 요청입니다. 입력 정보를 확인해주세요.');
        default:
          throw Exception(
              '로그인 처리 중 오류가 발생했습니다. (상태 코드: ${response.statusCode})');
      }
    } catch (e) {
      print('로그인 에러 상세: $e');
      if (e is TimeoutException) {
        throw Exception('서버 응답 시간이 초과되었습니다. 잠시 후 다시 시도해주세요.');
      } else if (e is SocketException) {
        throw Exception('서버 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
      }
      rethrow;
    }
  }

  /// 사용자 정보 조회 API
  static Future<UserInfo> getUserInfo(int userId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/id')
          .replace(queryParameters: {
        'userId': userId.toString(),
      });

      print('사용자 정보 조회 요청 - URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
      final url = Uri.parse('${ApiConfig.baseUrl}/user/check-email');

      print('이메일 중복 체크 요청 - URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
        }),
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('개인화 메시지 조회 에러: $e');
      rethrow;
    }
  }
}
