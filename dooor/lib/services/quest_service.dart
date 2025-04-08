import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quest.dart';
import '../config/api_config.dart';
import '../services/token_service.dart';
import '../models/quest_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        Uri.parse('${ApiConfig.baseUrl}/quests/complete')
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
  Future<bool> validateQuestImage(String imageUrl) async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/quests/validate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode({'image': imageUrl}),
      );

      debugPrint('이미지 검증 응답 상태: ${response.statusCode}');
      debugPrint('이미지 검증 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['is_receipt'] == true;
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
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/quest-id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': token,
        },
      );

      debugPrint('현재 퀘스트 ID 조회 응답 상태: ${response.statusCode}');
      debugPrint('현재 퀘스트 ID 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('현재 퀘스트 ID를 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      debugPrint('현재 퀘스트 ID 조회 오류: $e');
      rethrow;
    }
  }

  // 퀘스트 완료 여부 조회
  Future<bool> isQuestCleared() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/user/quest-cleared'),
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
      final token = await TokenService.getAccessToken();
      if (token == null) {
        debugPrint('인증 토큰이 없습니다. 로그인이 필요합니다.');
        return _getLocalQuestProgress();
      }

      // 현재 퀘스트 ID와 완료 여부를 가져옵니다
      final currentQuestId = await getCurrentQuestId();
      final isCurrentQuestCleared = await isQuestCleared();

      debugPrint('현재 퀘스트 ID: $currentQuestId');
      debugPrint('현재 퀘스트 완료 여부: $isCurrentQuestCleared');

      // 퀘스트 진행 상태 리스트 생성
      final List<bool> progress = List.filled(7, false); // 임시로 7개로 설정

      // 현재 퀘스트 이전까지는 모두 완료 처리
      for (int i = 0; i < currentQuestId - 1; i++) {
        progress[i] = true;
      }

      // 현재 퀘스트의 완료 여부 설정
      if (currentQuestId > 0 && currentQuestId <= progress.length) {
        progress[currentQuestId - 1] = isCurrentQuestCleared;
      }

      // 로컬 저장소에도 저장
      await _saveLocalQuestProgress(progress);

      return progress;
    } catch (e) {
      debugPrint('퀘스트 진행 상태 조회 오류: $e');
      return _getLocalQuestProgress();
    }
  }

  // 로컬 퀘스트 진행 상태 저장
  Future<void> _saveLocalQuestProgress(List<bool> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, bool> completedQuests = {};
      for (int i = 0; i < progress.length; i++) {
        completedQuests[(i + 1).toString()] = progress[i];
      }
      await prefs.setString('completed_quests', jsonEncode(completedQuests));
    } catch (e) {
      debugPrint('로컬 퀘스트 진행 상태 저장 오류: $e');
    }
  }

  // 로컬 퀘스트 진행 상태 조회
  List<bool> _getLocalQuestProgress() {
    try {
      final prefs = SharedPreferences.getInstance();
      final completedQuestsJson =
          prefs.then((prefs) => prefs.getString('completed_quests'));
      if (completedQuestsJson != null) {
        final Map<String, dynamic> decoded =
            jsonDecode(completedQuestsJson as String);
        final List<bool> progress = List.filled(7, false);
        decoded.forEach((key, value) {
          final index = int.parse(key) - 1;
          if (index >= 0 && index < progress.length) {
            progress[index] = value as bool;
          }
        });
        return progress;
      }
    } catch (e) {
      debugPrint('로컬 퀘스트 진행 상태 조회 오류: $e');
    }
    return List.filled(7, false);
  }
}

final questService = QuestService();
