import 'package:flutter/material.dart';

class RankingList extends StatelessWidget {
  const RankingList({super.key});

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
        _buildRankCard("ShadowWalker", "Apex Legends", "9,850", Colors.green, true),
        const SizedBox(height: 12),
        _buildRankCard("CrimsonViper", "Red Dragon Clan", "9,420", Colors.orange, false),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade200), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Show All 12 Results", style: TextStyle(color: secondaryText, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildRankCard(String name, String detail, String score, Color statusColor, bool isBlueShield) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
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