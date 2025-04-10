import 'package:flutter/material.dart';
import '../services/ranking_service.dart';
import '../services/token_service.dart';
import 'package:flutter/foundation.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> _rankings = [];
  Map<String, dynamic>? _myRanking;
  bool _isLoading = true;
  bool _showMyRanking = false;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final rankings = await RankingService.getAllRankings();
      final userIdStr = await TokenService.getUserId();

      if (userIdStr != null) {
        final userId = int.tryParse(userIdStr);
        if (userId != null) {
          try {
            final myRanking = await RankingService.getUserRanking(userId);
            setState(() {
              _myRanking = myRanking;
              _rankings = rankings;
            });
          } catch (e) {
            debugPrint('개인 랭킹 조회 실패: $e');
            setState(() {
              _rankings = rankings;
            });
          }
        } else {
          debugPrint('유효하지 않은 사용자 ID: $userIdStr');
          setState(() {
            _rankings = rankings;
          });
        }
      } else {
        setState(() {
          _rankings = rankings;
        });
      }
    } catch (e) {
      debugPrint('랭킹 로드 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('랭킹을 불러오는데 실패했습니다: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleMyRanking() {
    setState(() {
      _showMyRanking = !_showMyRanking;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        onPressed: _toggleMyRanking,
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
                      itemCount: _showMyRanking && _myRanking != null
                          ? _rankings.length + 2
                          : _rankings.length,
                      itemBuilder: (context, index) {
                        if (_showMyRanking && _myRanking != null) {
                          if (index == 0) {
                            return _buildRankingItem(_myRanking!, true);
                          } else if (index == 1) {
                            return const SizedBox(height: 20);
                          } else {
                            return _buildRankingItem(
                                _rankings[index - 2], false);
                          }
                        }
                        return _buildRankingItem(_rankings[index], false);
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRankingItem(Map<String, dynamic> ranking, bool isMyRanking) {
    final user = ranking['user'] as Map<String, dynamic>;
    final name = user['name'] as String;
    final score = ranking['score'] as int;
    final rank = ranking['rank'] as int;

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
            name,
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
