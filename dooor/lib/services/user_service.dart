import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  static const String baseUrl = 'http://localhost:8080/api';

  // 유저의 현재 퀘스트 ID 조회
  Future<int> getCurrentQuestId() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/quest-id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return int.parse(response.body);
      } else {
        throw Exception('현재 퀘스트 ID 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('현재 퀘스트 ID 조회 중 오류 발생: $e');
    }
  }

  // 유저의 퀘스트 완료 여부 조회
  Future<bool> isQuestCleared() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/quest-cleared'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('퀘스트 완료 여부 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('퀘스트 완료 여부 조회 중 오류 발생: $e');
    }
  }

  // 유저 정보 조회
  Future<Map<String, dynamic>> getUserInfo(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/id?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('유저 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('유저 정보 조회 중 오류 발생: $e');
    }
  }
}

final userService = UserService();
