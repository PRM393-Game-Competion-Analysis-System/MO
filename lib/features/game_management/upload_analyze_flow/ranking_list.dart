import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';

class RankingList extends StatelessWidget {
  final List<LeaderboardItem> leaderboard;

  const RankingList({super.key, required this.leaderboard});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("DETECTED RANKINGS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText, letterSpacing: 0.5)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
              child: const Text("Live Preview", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (leaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Center(
              child: Text(
                "No ranking records found in this screenshot.",
                style: TextStyle(color: secondaryText, fontSize: 14),
              ),
            ),
          )
        else
          ...leaderboard.map((item) {
            final isTop1 = item.rank == 1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildRankCard(
                item.playerName,
                item.guildName.isNotEmpty ? item.guildName : "No Guild",
                item.score.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"),
                isTop1 ? Colors.amber : Colors.green,
                isTop1,
                item.rank,
              ),
            );
          }),
      ],
    );
  }

  Widget _buildRankCard(String name, String detail, String score, Color statusColor, bool isBlueShield, int rank) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 32,
            child: Text(
              "#$rank",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: rank == 1 ? Colors.amber : (rank <= 3 ? Colors.green : secondaryText),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.verified_outlined, color: isBlueShield ? primaryBlue : Colors.grey, size: 28),
          const SizedBox(width: 12),
          Stack(
            children: [
              Container(width: 44, height: 44, decoration: const BoxDecoration(color: bgColor, shape: BoxShape.circle, image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100"), fit: BoxFit.cover))),
              Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                const SizedBox(height: 2),
                Row(children: [
                  Text(detail, style: const TextStyle(color: secondaryText, fontSize: 12)),
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(4)), child: const Text("verified", style: TextStyle(color: primaryBlue, fontSize: 9, fontWeight: FontWeight.bold))),
                ]),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("SCORE", style: TextStyle(fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
              Text(score, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryBlue)),
              Container(width: 40, height: 3, color: primaryBlue, margin: const EdgeInsets.only(top: 4)),
            ],
          ),
        ],
      ),
    );
  }
}