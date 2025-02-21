import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rankingData = [
      {'rank': 1, 'name': 'Dog12', 'score': 177, 'medal': '🥇'},
      {'rank': 2, 'name': 'Pig3', 'score': 175, 'medal': '🥈'},
      {'rank': 3, 'name': 'Dog45', 'score': 174, 'medal': '🥉'},
      {'rank': 4, 'name': 'Cat67', 'score': 171, 'medal': ''},
      {'rank': 5, 'name': 'Bird89', 'score': 168, 'medal': ''},
      {'rank': 6, 'name': 'Horse10', 'score': 167, 'medal': ''},
      {'rank': 7, 'name': 'Wolf0', 'score': 165, 'medal': ''},
      {'rank': 8, 'name': 'Tiger55', 'score': 163, 'medal': ''},
      {'rank': 9, 'name': 'Lion22', 'score': 160, 'medal': ''},
      {'rank': 10, 'name': 'Rabbit7', 'score': 158, 'medal': ''},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE7E4E2),
      appBar: CustomAppBar(
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('내 순위 🏆', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: rankingData.length,
          itemBuilder: (context, index) {
            final item = rankingData[index];
            return _buildRankingItem(item['rank'], item['name'], item['score']);
          },
        ),
      ),
    );
  }

  Widget _buildRankingItem(int rank, String name, int score) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              rank <= 3 ? _getMedalEmoji(rank) : '$rank',
              style: TextStyle(
                color: Colors.black,
                fontSize: rank <= 3 ? 26 : 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.black,
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
