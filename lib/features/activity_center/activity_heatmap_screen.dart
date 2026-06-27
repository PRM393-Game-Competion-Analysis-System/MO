import 'package:flutter/material.dart';

class ActivityHeatmapScreen extends StatelessWidget {
  const ActivityHeatmapScreen({super.key});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Activity Heatmap",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top User Filter Row Component
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage("https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=100"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("VIEWING DATA FOR", style: TextStyle(color: Colors.grey.shade400, fontSize: 9, fontWeight: FontWeight.bold)),
                        Row(
                          children: const [
                            Text("Global Analytics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                            Icon(Icons.arrow_drop_down, color: darkText, size: 18),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.tune, color: darkText, size: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Heatmap Grid Analytics Card Block
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.calendar_month_outlined, color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text("Upload Frequency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(8)),
                        child: const Text("LAST 35 DAYS", style: TextStyle(color: secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Daily AI analysis volume across all servers", style: TextStyle(color: secondaryText, fontSize: 12)),
                  const SizedBox(height: 24),

                  // Heatmap Grid Matrix (7 columns represent S M T W T F S)
                  _buildHeatmapGrid(),
                  const SizedBox(height: 16),

                  // Heatmap Density Legend Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("Less", style: TextStyle(color: secondaryText, fontSize: 11)),
                      const SizedBox(width: 6),
                      _buildLegendSquare(0.15),
                      _buildLegendSquare(0.4),
                      _buildLegendSquare(0.65),
                      _buildLegendSquare(1.0),
                      const SizedBox(width: 6),
                      const Text("More", style: TextStyle(color: secondaryText, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // DAILY SUMMARY FOOTER CARDS SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Daily Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                          SizedBox(height: 2),
                          Text("Wednesday, June 21, 2026", style: TextStyle(color: secondaryText, fontSize: 12)),
                        ],
                      ),
                      Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildSummaryMetaCard("TOTAL SCREENS", "1,284", "+12%")),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSummaryMetaCard("PEAK HOUR", "20:00", "↗")),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    // Simulated matrix load values to reproduce layout intensity color squares
    final List<double> matrixWeights = [
      0.4, 0.65, 0.65, 0.15, 0.4, 0.65, 0.65,
      0.15, 0.4, 0.65, 0.4, 0.15, 1.0, 0.15,
      1.0, 0.65, 1.0, 0.15, 0.15, 0.4, 0.15,
      0.4, 0.65, 0.65, 0.15, 0.65, 0.5, 1.0,
      0.15, 0.4, 0.15, 0.65, 1.0, 0.65, 0.4
    ];

    final daysHeader = ["S", "M", "T", "W", "T", "F", "S"];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: daysHeader.map((d) => Expanded(
            child: Center(child: Text(d, style: const TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.bold))),
          )).toList(),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: matrixWeights.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            double weight = matrixWeights[index];
            return Container(
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: weight),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendSquare(double alpha) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(
        color: primaryBlue.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSummaryMetaCard(String label, String value, String rate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: secondaryText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Row(
            textBaseline: TextBaseline.alphabetic,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(width: 6),
              Text(rate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
            ],
          )
        ],
      ),
    );
  }
}