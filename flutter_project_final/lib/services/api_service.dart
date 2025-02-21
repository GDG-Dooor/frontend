import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class ApiService {
  // 회원 관련 API
  static Future<http.Response> checkId(String id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/user/check-id')
          .replace(queryParameters: {'id': id});

      print('요청 URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 바디: ${response.body}');

      // 실제 서버 응답 구조 확인
      if (response.statusCode != 200 && response.statusCode != 409) {
        print('서버 응답 전체: ${response.toString()}');
        print('응답 헤더: ${response.headers}');
      }

      return response;
    } catch (e) {
      print('API 호출 에러 상세: $e');
      print('스택 트레이스: ${StackTrace.current}');
      rethrow;
    }
  }

  static Future<http.Response> signup(Map<String, dynamic> userData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );
  }

  static Future<http.Response> login(String id, String password) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'password': password}),
    );
  }

  static Future<http.Response> findId(String email) async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/user/id').replace(
        queryParameters: {'email': email},
      ),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> changePassword(
      Map<String, String> passwordData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(passwordData),
    );
  }

  static Future<http.Response> logout() async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/user/logout'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> withdrawal() async {
    return await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/user'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> changeName(String newName) async {
    return await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/user/name'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': newName}),
    );
  }

  // 퀘스트 관련 API 수정
  static Future<http.Response> getQuests() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/quests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print('퀘스트 목록 요청 URL: ${ApiConfig.baseUrl}/api/quests');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 바디: ${response.body}');
      return response;
    } catch (e) {
      print('퀘스트 목록 조회 에러: $e');
      rethrow;
    }
  }

  static Future<http.Response> getQuestDetails(String questId) async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/quests/$questId'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // 퀘스트 시작
  static Future<http.Response> startQuest(String questId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/quests/start'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'questId': questId}),
      );
      print('퀘스트 시작 요청 - questId: $questId');
      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('퀘스트 시작 에러: $e');
      rethrow;
    }
  }

  // 퀘스트 완료
  static Future<http.Response> completeQuest(String questId) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/quests/complete'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'questId': questId}),
      );
      print('퀘스트 완료 요청 - questId: $questId');
      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('퀘스트 완료 에러: $e');
      rethrow;
    }
  }

  // 퀘스트 인증 이미지 검증
  static Future<http.Response> verifyQuestImage(
      String questId, String imageData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/quests/verify-image'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'questId': questId,
          'image': imageData,
        }),
      );
      print('이미지 검증 요청 - questId: $questId');
      print('응답 상태 코드: ${response.statusCode}');
      return response;
    } catch (e) {
      print('이미지 검증 에러: $e');
      rethrow;
    }
  }

  // 이미지 검증 관련 API들
  static Future<http.Response> verifyOcr(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ocr'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifySky(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/sky'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyMountain(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/mountain'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyMovie(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/movie'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyPositiveText(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/positive'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyEgg(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/egg'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyLibrary(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/library'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyPaper(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/paper'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  static Future<http.Response> verifyMicrophone(String imageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/microphone'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageData}),
    );
  }

  // 영수증 검증 API
  static Future<http.Response> verifyReceipt(
      String imageData, String type) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ocr'), // URL 변경
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'image': imageData, 'type': type}),
      );

      print('영수증 검증 요청 URL: ${ApiConfig.baseUrl}/ocr');
      print('영수증 타입: $type');
      print('응답 상태 코드: ${response.statusCode}');

      return response;
    } catch (e) {
      print('영수증 검증 에러: $e');
      rethrow;
    }
  }

  // 랭킹 관련 API
  static Future<http.Response> getAllRankings() async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ranking/all'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> getUserRanking() async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/ranking'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> updateRanking(
      Map<String, dynamic> rankingData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/ranking'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(rankingData),
    );
  }

  // 챗봇 관련 API
  static Future<http.Response> sendMessage(
      Map<String, dynamic> messageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/message'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(messageData),
    );
  }

  static Future<http.Response> getPersonalizedMessage() async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/personalized'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // 스테이지 관련 API
  static Future<http.Response> createStage(
      Map<String, dynamic> stageData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/stage/make'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(stageData),
    );
  }

  static Future<http.Response> getAllStages() async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/stage'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  static Future<http.Response> getStageDetails(String stageId) async {
    return await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/stage/$stageId'),
      headers: {'Content-Type': 'application/json'},
    );
  }

  // 사용자 퀘스트 진행 상태 조회
  static Future<http.Response> getUserQuestStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/progress'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('퀘스트 상태 조회 URL: ${ApiConfig.baseUrl}/api/user/progress');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 바디: ${response.body}');

      return response;
    } catch (e) {
      print('퀘스트 상태 조회 에러: $e');
      rethrow;
    }
  }

  // 퀘스트 생성 API
  static Future<http.Response> createQuest(
      Map<String, dynamic> questData) async {
    return await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/quests/make'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(questData),
    );
  }
}
