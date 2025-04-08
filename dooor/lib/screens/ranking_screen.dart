import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../services/token_service.dart';
import '../models/ranking.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final TokenService _tokenService = TokenService();
  List<Ranking> _rankings = [];
  Ranking? _myRanking;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _showMyRanking = false;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  // 퀘스트 점수 계산
  int _calculateQuestScore(int stageId, bool needImage) {
    int baseScore = 5;
    int stageBonus = stageId - 1; // 스테이지가 높을수록 보너스 점수 증가
    int imageBonus = needImage ? 2 : 0; // 이미지 인증이 필요한 경우 보너스 점수

    return baseScore + stageBonus + imageBonus;
  }

  Future<void> _updateRankingScore(int userId) async {
    try {
      // 토큰 만료 체크 및 갱신
      if (_tokenService.isTokenExpired()) {
        final refreshed = await _tokenService.refreshAccessToken();
        if (!refreshed) {
          throw Exception('토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
        }
      }

      // API 요청 헤더 설정
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = _tokenService.currentToken!;
      }

      // 랭킹 점수 업데이트
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ranking/update').replace(
          queryParameters: {
            'userId': userId.toString(),
          },
        ),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception('랭킹 점수 업데이트에 실패했습니다.');
      }
    } catch (e) {
      print('랭킹 점수 업데이트 실패: $e');
    }
  }

  Future<void> _loadRankings() async {
    try {
      // 토큰 만료 체크 및 갱신
      if (_tokenService.isTokenExpired()) {
        final refreshed = await _tokenService.refreshAccessToken();
        if (!refreshed) {
          throw Exception('토큰 갱신에 실패했습니다. 다시 로그인해주세요.');
        }
      }

      // API 요청 헤더 설정
      final headers = {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

      if (_tokenService.currentToken != null) {
        headers['Authorization'] = _tokenService.currentToken!;
      }

      // 내 랭킹 조회
      final currentUserId = int.tryParse(_tokenService.currentUserId ?? '');
      if (currentUserId == null) {
        throw Exception('사용자 ID가 올바르지 않습니다.');
      }

      final myRankingResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ranking/user').replace(
          queryParameters: {
            'userId': currentUserId.toString(),
          },
        ),
        headers: headers,
      );

      if (myRankingResponse.statusCode == 200) {
        final responseBody = myRankingResponse.body;
        if (responseBody.isEmpty) {
          throw Exception('서버에서 빈 응답을 받았습니다.');
        }
        try {
          final myRankingData = jsonDecode(responseBody);
          setState(() {
            _myRanking = Ranking.fromJson(myRankingData);
          });
        } catch (e) {
          throw Exception('서버 응답 형식이 올바르지 않습니다: $e');
        }
      } else if (myRankingResponse.statusCode == 404) {
        // 랭킹이 없는 경우 새로 생성
        await _updateRankingScore(currentUserId);
        // 다시 내 랭킹 조회
        final retryResponse = await http.get(
          Uri.parse('${ApiConfig.baseUrl}/ranking/user').replace(
            queryParameters: {
              'userId': currentUserId.toString(),
            },
          ),
          headers: headers,
        );
        if (retryResponse.statusCode == 200) {
          final myRankingData = jsonDecode(retryResponse.body);
          setState(() {
            _myRanking = Ranking.fromJson(myRankingData);
          });
        } else {
          throw Exception('내 랭킹을 불러오는데 실패했습니다.');
        }
      } else {
        throw Exception('내 랭킹을 불러오는데 실패했습니다.');
      }

      // 전체 랭킹 조회
      final rankingsResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/ranking/all'),
        headers: headers,
      );

      if (rankingsResponse.statusCode == 200) {
        final responseBody = rankingsResponse.body;
        if (responseBody.isEmpty) {
          setState(() {
            _rankings = [];
            _isLoading = false;
          });
          return;
        }
        try {
          final List<dynamic> rankingsData = jsonDecode(responseBody);
          setState(() {
            _rankings =
                rankingsData.map((data) => Ranking.fromJson(data)).toList();
            // 점수에 따라 정렬
            _rankings.sort((a, b) => b.score.compareTo(a.score));
            // 순위 부여
            for (int i = 0; i < _rankings.length; i++) {
              _rankings[i].rank = i + 1;
            }
            _isLoading = false;
          });
        } catch (e) {
          throw Exception('서버 응답 형식이 올바르지 않습니다: $e');
        }
      } else if (rankingsResponse.statusCode == 404) {
        setState(() {
          _rankings = [];
          _isLoading = false;
        });
      } else {
        throw Exception('랭킹을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16, bottom: 24, left: 24, right: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ranking',
                            style: TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 12, 12, 12),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _showMyRanking = !_showMyRanking;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FEFF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '내 순위 🏆',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(overscroll: false),
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: _showMyRanking
                              ? _rankings.length + 2
                              : _rankings.length,
                          itemBuilder: (context, index) {
                            if (_showMyRanking && index == 0) {
                              return _buildRankingItem(
                                _myRanking!.rank,
                                _myRanking!.user.userId,
                                _myRanking!.score,
                                isMyRanking: true,
                              );
                            } else if (_showMyRanking && index == 1) {
                              return const SizedBox(height: 20);
                            } else {
                              final adjustedIndex =
                                  _showMyRanking ? index - 2 : index;
                              final ranking = _rankings[adjustedIndex];
                              return _buildRankingItem(
                                ranking.rank,
                                ranking.user.userId,
                                ranking.score,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildRankingItem(int rank, int userId, int score,
      {bool isMyRanking = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isMyRanking ? const Color(0xFFF9FEFF) : const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
        border: isMyRanking ? Border.all(color: Colors.blue, width: 2) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              rank <= 3 ? _getMedalEmoji(rank) : '$rank',
              style: TextStyle(
                color: isMyRanking ? Colors.blue : Colors.black,
                fontSize: rank <= 3 ? 26 : 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'User $userId',
            style: TextStyle(
              color: isMyRanking ? Colors.blue : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '$score',
            style: TextStyle(
              color: isMyRanking ? Colors.blue : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
