import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_service.dart';

class RankingService {
  final TokenService _tokenService = TokenService();

  // 전체 랭킹 조회
  Future<List<Map<String, dynamic>>> getAllRankings() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ranking/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _tokenService.currentToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          final user = item['user'] ?? {};
          return {
            'userId': user['userId'] ?? 0,
            'name': user['name'] ?? 'Unknown',
            'score': item['score'] ?? 0,
            'rank': item['rank'] ?? 0,
            'updatedAt': item['updatedAt'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
      } else {
        throw Exception('랭킹을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('랭킹 조회 중 오류가 발생했습니다: $e');
    }
  }

  // 내 랭킹 조회
  Future<Map<String, dynamic>?> getMyRanking() async {
    try {
      final userId = _tokenService.currentUserId;
      if (userId == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ranking/user').replace(
          queryParameters: {'userId': userId.toString()},
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _tokenService.currentToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'] ?? {};
        return {
          'userId': user['userId'] ?? 0,
          'name': user['name'] ?? 'Unknown',
          'score': data['score'] ?? 0,
          'rank': data['rank'] ?? 0,
          'updatedAt': data['updatedAt'] ?? DateTime.now().toIso8601String(),
        };
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('내 랭킹을 불러오는데 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('내 랭킹 조회 중 오류가 발생했습니다: $e');
    }
  }

  // 랭킹 점수 업데이트
  Future<void> updateRankingScore(int score) async {
    try {
      final userId = _tokenService.currentUserId;
      if (userId == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/ranking/update').replace(
          queryParameters: {
            'userId': userId.toString(),
            'score': score.toString(),
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _tokenService.currentToken ?? '',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('랭킹 점수 업데이트에 실패했습니다. (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('랭킹 점수 업데이트 중 오류가 발생했습니다: $e');
    }
  }

  // 퀘스트 점수 계산
  int calculateQuestScore(int stageId, bool needImage) {
    int baseScore = 5;
    int stageBonus = stageId - 1; // 스테이지가 높을수록 보너스 점수 증가
    int imageBonus = needImage ? 2 : 0; // 이미지 인증이 필요한 경우 보너스 점수

    return baseScore + stageBonus + imageBonus;
  }
}
