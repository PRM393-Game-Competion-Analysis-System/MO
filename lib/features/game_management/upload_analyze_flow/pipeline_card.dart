import 'package:flutter/material.dart';

class PipelineCard extends StatelessWidget {
  final VoidCallback onClearAll;

  const PipelineCard({super.key, required this.onClearAll});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("AI PIPELINE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: darkText)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                    child: const Text("v2.4 Neural", style: TextStyle(color: primaryBlue, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPipelineRow("Character Recognition", true, false),
              _buildPipelineRow("Score Validation", false, true),
              _buildPipelineRow("Global Ranking Sync", false, false),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Overall Progress", style: TextStyle(color: secondaryText, fontSize: 12)),
                  Text("65%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: darkText)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(value: 0.65, backgroundColor: Color(0xFFE0E0E0), valueColor: AlwaysStoppedAnimation<Color>(primaryBlue), minHeight: 6),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade200), foregroundColor: secondaryText, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Analyzing...", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onClearAll,
          child: const Text("Clear & Upload New", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPipelineRow(String title, bool isDone, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        children: [
          if (isDone) const Icon(Icons.check_circle_outline, color: Colors.green, size: 18) else if (isLoading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue)) else const Icon(Icons.circle, color: Color(0xFFE0E0E0), size: 12),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 14, fontWeight: isDone || isLoading ? FontWeight.w600 : FontWeight.w500, color: isDone || isLoading ? darkText : secondaryText)),
        ],
      ),
    );
  }
}