import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RankingService {
  static const String _baseUrl = '${ApiConfig.baseUrl}/ranking';
  static final TokenService _tokenService = TokenService();

  // 전체 랭킹 조회
  static Future<List<Map<String, dynamic>>> getAllRankings() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('랭킹 조회 응답 상태: ${response.statusCode}');
      debugPrint('랭킹 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return [];
        }
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('랭킹 조회에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('랭킹 조회 오류: $e');
      return [];
    }
  }

  // 개인 랭킹 조회
  static Future<Map<String, dynamic>> getUserRanking(int userId) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user').replace(
          queryParameters: {
            'userId': userId.toString(),
          },
        ),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      debugPrint('개인 랭킹 조회 응답 상태: ${response.statusCode}');
      debugPrint('개인 랭킹 조회 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('랭킹 데이터가 없습니다.');
        }
        final Map<String, dynamic> ranking =
            jsonDecode(response.body) as Map<String, dynamic>;
        final user = ranking['user'] as Map<String, dynamic>;
        final name = user['name'] as String;
        final score = ranking['score'] as int;
        return ranking;
      } else if (response.statusCode == 404) {
        throw Exception('랭킹을 찾을 수 없습니다.');
      } else {
        throw Exception('개인 랭킹 조회에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('개인 랭킹 조회 오류: $e');
      rethrow;
    }
  }

  // 랭킹 점수 업데이트
  static Future<void> updateRankingScore(int userId) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/update').replace(
          queryParameters: {
            'userId': userId.toString(),
          },
        ),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
          'Accept': '*/*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('랭킹 점수 업데이트에 실패했습니다: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('랭킹 점수 업데이트 오류: $e');
      rethrow;
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
