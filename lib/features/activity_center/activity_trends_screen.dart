import 'package:flutter/material.dart';

class ActivityTrendsScreen extends StatelessWidget {
  const ActivityTrendsScreen({super.key});

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
          "Activity Trends",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top User Selection Filter Row
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

            // Main Growth Trends Mixed Chart Card
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
                    children: const [
                      Icon(Icons.stacked_line_chart, color: primaryBlue, size: 20),
                      SizedBox(width: 8),
                      Text("Growth Trends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Monthly analysis volume vs. AI confidence score", style: TextStyle(color: secondaryText, fontSize: 12)),
                  const SizedBox(height: 28),

                  // Custom Painter Combined Chart Block
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: CustomPaint(painter: TrendsMixedPainter()),
                  ),
                  const SizedBox(height: 20),

                  // Chart Custom Legend Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(primaryBlue, "Total Uploads", isBar: true),
                      const SizedBox(width: 24),
                      _buildLegendItem(const Color(0xFF2563EB), "Avg Confidence", isBar: false),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GLOBAL INSIGHTS SECTION
            const Text(
              "GLOBAL INSIGHTS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryText, letterSpacing: 0.8),
            ),
            const SizedBox(height: 12),
            _buildInsightRow("Most Active Game", "Warhammer 40k"),
            const SizedBox(height: 10),
            _buildInsightRow("Top Region", "North America"),
            const SizedBox(height: 10),
            _buildInsightRow("Avg AI Confidence", "94.2%"),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {required bool isBar}) {
    return Row(
      children: [
        Container(
          width: isBar ? 14 : 12,
          height: isBar ? 14 : 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isBar ? 4 : 0),
            shape: isBar ? BoxShape.rectangle : BoxShape.rectangle,
          ),
        ),
        if (!isBar)
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: secondaryText, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildInsightRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// --- CUSTOM PAINTER FOR COMBINED BAR & LINE CHART ---
class TrendsMixedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const leftPadding = 35.0;
    final graphW = w - leftPadding;
    final graphH = h - 20.0;

    final gridPaint = Paint()..color = Colors.grey.shade100..strokeWidth = 1;
    final textStyle = TextStyle(color: Colors.grey.shade400, fontSize: 10);

    // 1. Draw horizontal grid rows and Y-Axis texts
    final yLabels = ["800", "600", "400", "200", "0"];
    for (int i = 0; i < yLabels.length; i++) {
      double yPos = (graphH / (yLabels.length - 1)) * i;
      canvas.drawLine(Offset(leftPadding, yPos), Offset(w, yPos), gridPaint);

      final tp = TextPainter(text: TextSpan(text: yLabels[i], style: textStyle), textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(0, yPos - 6));
    }

    // Chart mock parameters mapped to layout coordinate nodes
    final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
    final barHeights = [graphH * 0.55, graphH * 0.65, graphH * 0.6, graphH * 0.75, graphH * 0.72, graphH * 0.9];
    final linePointsY = [graphH * 0.85, graphH * 0.82, graphH * 0.84, graphH * 0.81, graphH * 0.82, graphH * 0.78];

    final double stepX = graphW / months.length;
    const double barWidth = 28.0;

    // 2. Render Vertical Columns (Total Uploads)
    final barPaint = Paint()..color = const Color(0xFF1129A4)..style = PaintingStyle.fill;

    for (int i = 0; i < months.length; i++) {
      double centerX = leftPadding + (stepX * i) + (stepX / 2);

      // Draw Column rectangle bars
      RRect barRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(centerX - (barWidth / 2), graphH - barHeights[i], barWidth, barHeights[i]),
        topLeft: const Radius.circular(6),
        topRight: const Radius.circular(6),
      );
      canvas.drawRRect(barRect, barPaint);

      // Render bottom horizontal axis month titles
      final monthTp = TextPainter(text: TextSpan(text: months[i], style: textStyle), textDirection: TextDirection.ltr)..layout();
      monthTp.paint(canvas, Offset(centerX - (monthTp.width / 2), graphH + 6));
    }

    // 3. Render Trend Line Overlay (Avg Confidence)
    final linePaint = Paint()..color = const Color(0xFF2563EB)..style = PaintingStyle.stroke..strokeWidth = 2.5..strokeCap = StrokeCap.round;
    final path = Path();

    for (int i = 0; i < months.length; i++) {
      double centerX = leftPadding + (stepX * i) + (stepX / 2);
      if (i == 0) {
        path.moveTo(centerX, linePointsY[i]);
      } else {
        path.lineTo(centerX, linePointsY[i]);
      }
    }
    canvas.drawPath(path, linePaint);

    // Draw joint dot pointers on the path line
    final dotPaint = Paint()..color = const Color(0xFF2563EB)..style = PaintingStyle.fill;
    final borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2;

    for (int i = 0; i < months.length; i++) {
      double centerX = leftPadding + (stepX * i) + (stepX / 2);
      canvas.drawCircle(Offset(centerX, linePointsY[i]), 4.5, dotPaint);
      canvas.drawCircle(Offset(centerX, linePointsY[i]), 4.5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}