import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Khai báo bảng màu chuẩn theo thiết kế thống nhất của dự án
  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);
  static const Color accentPurple = Color(0xFFEEF2FF);

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
          "Dashboard",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // 1. THANH TÌM KIẾM (Search Bar)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search player or ID...",
                  hintStyle: TextStyle(color: secondaryText, fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: secondaryText, size: 22),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. PHẦN NGƯỜI CHƠI GẦN ĐÂY (Recent Players)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.people_outline, size: 20, color: darkText),
                    SizedBox(width: 8),
                    Text(
                      "Recent Players",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    "View All",
                    style: TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _buildPlayerAvatar("Zenix_Gamer", "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200", Colors.green),
                  _buildPlayerAvatar("ShadowMist", "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200", Colors.orange),
                  _buildPlayerAvatar("Lunar_Ace", "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?q=80&w=200", Colors.orange),
                  _buildPlayerAvatar("ViperKing", "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200", Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. THẺ TIẾN TRÌNH ĐIỂM SỐ & BIỂU ĐỒ TRỰC QUAN (Score Progression Card)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart, color: primaryBlue, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        "Score Progression",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Global Top 1%",
                          style: TextStyle(color: primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Performance over last 7 sessions",
                    style: TextStyle(color: secondaryText, fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // Khung hiển thị các thông số nhỏ (Current Score & Avg Growth)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FF),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("CURRENT SCORE", style: TextStyle(color: secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("2,850", style: TextStyle(color: primaryBlue, fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("AVG. GROWTH", style: TextStyle(color: secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text("+12.4%", style: TextStyle(color: darkText, fontSize: 20, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 4),
                                  Icon(Icons.north_east, size: 16, color: darkText),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Khu vực tự vẽ biểu đồ hình sóng cao cấp chuẩn Figma mockup
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: ScoreLinePainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. PHẦN PHÂN TÍCH GẦN ĐÂY (Recent Analysis)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_toggle_off, size: 20, color: darkText),
                    SizedBox(width: 8),
                    Text(
                      "Recent Analysis",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    "View All",
                    style: TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thẻ phân tích game Genshin Impact
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=500",
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Genshin Impact",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText),
                            ),
                            Text(
                              "2 hours ago",
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildTagBadge("Asia-01"),
                            const SizedBox(width: 6),
                            _buildTagBadge("Rank #12"),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Thanh hiển thị tiến trình điểm số (Progress Bar)
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 0.75,
                                  backgroundColor: Color(0xFFF0F2F5),
                                  valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "5200 pts",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 120), // Tạo khoảng trống cuộn cho thanh navbar cố định ở ngoài
          ],
        ),
      ),
    );
  }

  // Widget bổ trợ: Tạo khối Avatar người chơi kèm chấm tròn báo trạng thái online/offline
  Widget _buildPlayerAvatar(String name, String imgUrl, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  image: DecorationImage(
                    image: NetworkImage(imgUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: darkText),
          ),
        ],
      ),
    );
  }

  // Widget bổ trợ: Tạo tag nhỏ đi kèm bài phân tích (ví dụ: Asia-01)
  Widget _buildTagBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// --- BỘ TỰ VẼ BIỂU ĐỒ ĐƯỜNG CONG GRADIENT CHUẨN ĐẸP ---
class ScoreLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Trục tọa độ các mốc thời gian từ Thứ 2 -> Chủ Nhật
    final List<double> xPoints = [
      0.0,
      width * 0.16,
      width * 0.33,
      width * 0.5,
      width * 0.66,
      width * 0.83,
      width,
    ];

    // Tỷ lệ các đỉnh sóng mượt mà mô phỏng chính xác theo hình ảnh Visily thiết kế
    final List<double> yPoints = [
      height * 0.9,  // Mon
      height * 0.72, // Tue
      height * 0.85, // Wed
      height * 0.55, // Thu
      height * 0.62, // Fri
      height * 0.35, // Sat
      height * 0.1,  // Sun
    ];

    final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    final List<String> scores = ["2000", "2250", "2500", "2750", "3000"];

    // 1. Vẽ các đường lưới ngang nhạt và trục tọa độ Y bên trái
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;

    final textStyle = TextStyle(color: Colors.grey.shade400, fontSize: 10);

    for (int i = 0; i < scores.length; i++) {
      double yPos = height - (i * (height * 0.22)) - 20;
      // Tránh vẽ tràn tiêu đề chữ số xuống đáy
      if (yPos > 0 && yPos < height - 15) {
        canvas.drawLine(Offset(35, yPos), Offset(width, yPos), gridPaint);

        final textPainter = TextPainter(
          text: TextSpan(text: scores[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(0, yPos - 6));
      }
    }

    // 2. Tạo đường nối Bezier mượt mà (Cubic Spline Curves)
    final path = Path()..moveTo(35, yPoints[0]);
    for (int i = 0; i < xPoints.length - 1; i++) {
      double x1 = xPoints[i] < 35 ? 35 : xPoints[i];
      double y1 = yPoints[i];
      double x2 = xPoints[i + 1];
      double y2 = yPoints[i + 1];

      // Tính toán điểm điều khiển (Control Points) để uốn mượt sóng
      double controlX1 = x1 + (x2 - x1) / 2;
      double controlY1 = y1;
      double controlX2 = x1 + (x2 - x1) / 2;
      double controlY2 = y2;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
    }

    // 3. Đổ màu Gradient phủ dưới chân đường cong đồ thị
    final fillPath = Path.from(path)
      ..lineTo(width, height - 20)
      ..lineTo(35, height - 20)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1129A4).withValues(alpha: 0.25),
          const Color(0xFF1129A4).withValues(alpha: 0.00),
        ],
      ).createShader(Rect.fromLTWH(35, 0, width - 35, height - 20));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF1129A4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // 5. Viết chữ hiển thị các ngày dưới trục hoành X
    for (int i = 0; i < days.length; i++) {
      double xPos = xPoints[i] < 35 ? 35 : xPoints[i];
      final dayPainter = TextPainter(
        text: TextSpan(text: days[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      dayPainter.paint(canvas, Offset(xPos - (dayPainter.width / 2), height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}