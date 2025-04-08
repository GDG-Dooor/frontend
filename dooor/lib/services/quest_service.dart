import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quest.dart';
import '../config/api_config.dart';
import '../services/token_service.dart';
import '../models/quest_progress.dart';
import 'package:flutter/foundation.dart';

class QuestService {
  final TokenService _tokenService = TokenService();

  // 모든 퀘스트 목록 조회
  static Future<List<Map<String, dynamic>>> getQuests() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('토큰이 없습니다. 로그인이 필요합니다.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((quest) => quest as Map<String, dynamic>).toList();
      } else if (response.statusCode == 401) {
        // 토큰이 만료된 경우 로그인 페이지로 이동
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      } else {
        throw Exception('퀘스트 목록을 가져오는데 실패했습니다.');
      }
    } catch (e) {
      print('퀘스트 목록 가져오기 실패: $e');
      rethrow;
    }
  }

  // 특정 퀘스트 정보 조회
  Future<Quest> getQuest(int questId) async {
    try {
      final token = await TokenService.getAccessToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/quests/$questId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Quest.fromJson(data);
      } else {
        throw Exception('퀘스트 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('퀘스트 정보 조회 중 오류 발생: $e');
    }
  }

  // 퀘스트 시작
  Future<Map<String, dynamic>> startQuest(int userId, int questId) async {
    try {
      final token = await TokenService.getAccessToken();
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quests/start')
            .replace(queryParameters: {
          'userId': userId.toString(),
          'questId': questId.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('퀘스트 시작 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('퀘스트 시작 중 오류 발생: $e');
    }
  }

  // 퀘스트 완료
  Future<bool> completeQuest({
    required int questId,
    required int userId,
    required Map<String, String> headers,
  }) async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/quests/complete')
            .replace(queryParameters: {
          'userId': userId.toString(),
          'questId': questId.toString(),
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      debugPrint('퀘스트 완료 요청 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 완료 요청 응답 본문: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('퀘스트 완료 요청 오류: $e');
      return false;
    }
  }

  // 퀘스트 이미지 검증
  Future<Map<String, dynamic>> validateQuestImage(String imageUrl) async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/quests/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: json.encode({'image': imageUrl}),
      );

      debugPrint('이미지 검증 응답 상태: ${response.statusCode}');
      debugPrint('이미지 검증 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('이미지 검증에 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('이미지 검증 오류: $e');
      rethrow;
    }
  }

  // 현재 퀘스트 ID 조회
  Future<int> getCurrentQuestId() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/quest-id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      debugPrint('퀘스트 진행 상황 조회 요청 URL: ${ApiConfig.baseUrl}/api/user/quest-id');
      debugPrint('퀘스트 진행 상황 조회 요청 헤더: ${response.request?.headers}');
      debugPrint('퀘스트 진행 상황 조회 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 진행 상황 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('퀘스트 진행 상황을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('퀘스트 진행 상황 조회 오류: $e');
      rethrow;
    }
  }

  // 퀘스트 완료 여부 조회
  Future<bool> isQuestCleared() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/user/quest-cleared'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      debugPrint('퀘스트 완료 여부 조회 응답 상태: ${response.statusCode}');
      debugPrint('퀘스트 완료 여부 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return response.body.toLowerCase() == 'true';
      } else {
        throw Exception('퀘스트 완료 여부를 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('퀘스트 완료 여부 조회 오류: $e');
      rethrow;
    }
  }

  // 퀘스트 진행 상태 조회
  Future<List<bool>> getQuestProgress() async {
    try {
      final currentQuestId = await getCurrentQuestId();
      final isCleared = await isQuestCleared();

      // 임시로 7개의 퀘스트가 있다고 가정
      final List<bool> progress = List.filled(7, false);

      // 현재 퀘스트까지 완료된 것으로 표시
      for (int i = 0; i < currentQuestId - 1; i++) {
        progress[i] = true;
      }

      // 현재 퀘스트의 완료 여부 반영
      if (currentQuestId > 0 && currentQuestId <= progress.length) {
        progress[currentQuestId - 1] = isCleared;
      }

      return progress;
    } catch (e) {
      debugPrint('퀘스트 진행 상태 조회 오류: $e');
      rethrow;
    }
  }
}

final questService = QuestService();
