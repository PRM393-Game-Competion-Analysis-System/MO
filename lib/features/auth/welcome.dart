import 'package:flutter/material.dart';
import 'package:mo/features/auth/login.dart';

class GameAnalyzeWelcomeScreen extends StatelessWidget {
  const GameAnalyzeWelcomeScreen({super.key}); // Tối ưu constructor chuẩn Flutter mới

  // Định nghĩa các mã màu chính xác từ thiết kế
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color darkText = Color(0xFF1A1D20);
  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color dividerColor = Color(0xFFC6D0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              // Giới hạn chiều rộng tối đa giống như giao diện web/bản thiết kế
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Logo Icon ---
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: darkText,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bolt, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 24),

                  // --- Tiêu đề (Sử dụng RichText để đổi màu chữ) ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        height: 1.2,
                        fontFamily: 'sans-serif',
                      ),
                      children: [
                        TextSpan(text: "Analyze Game\n"),
                        TextSpan(
                          text: "Screenshots",
                          style: TextStyle(color: primaryBlue),
                        ),
                        TextSpan(text: " with AI"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Đoạn mô tả ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "The world's first AI-powered gaming analytics tool. Upload your scores and instantly see your rank among global elites.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Thanh phân tách CORE CAPABILITIES ---
                  Row(
                    children: [
                      Text(
                        "CORE CAPABILITIES",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade400,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Divider(
                          color: dividerColor,
                          thickness: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Lưới 4 Thẻ Tính năng (Grid) ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: [
                      _buildCapabilityCard(
                        icon: Icons.auto_awesome,
                        title: "AI Accuracy",
                        desc: "OCR trained on 1M+ game screenshots.",
                        badge: "99.8%",
                      ),
                      _buildCapabilityCard(
                        icon: Icons.bolt,
                        title: "Real-time",
                        desc: "Process images in under 2.5 seconds.",
                      ),
                      _buildCapabilityCard(
                        icon: Icons.gamepad,
                        title: "Multi-Game",
                        desc: "Supports MOBA, FPS, and MMO titles.",
                      ),
                      _buildCapabilityCard(
                        icon: Icons.bar_chart,
                        title: "Insights",
                        desc: "Deep dive into your skill progression.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- Nút Upload Screenshot (Primary) ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_upload_outlined, size: 18),
                          SizedBox(width: 8),
                          Text("Upload Screenshot", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- Nút Watch Demo (Secondary) ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: darkText,
                        side: BorderSide(color: Colors.grey.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_circle_outline, color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text("Watch Demo", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Footer Đăng nhập ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- Đã cập nhật các nút Mạng xã hội chuẩn thiết kế ở đây 👇 ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIconFromNetwork(
                        'https://cdn-icons-png.flaticon.com/512/2991/2991148.png', // Google Logo màu gốc
                        size: 22,
                        isColor: true,
                      ),
                      const SizedBox(width: 28),
                      _buildSocialIconFromNetwork(
                        'https://cdn-icons-png.flaticon.com/512/25/25231.png', // GitHub Logo chuẩn tối màu
                        size: 24,
                      ),
                      const SizedBox(width: 28),
                      _buildSocialIconFromIcon(Icons.apple, size: 26), // Apple Logo hệ thống
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm tạo Widget Thẻ Tính năng (Card)
  Widget _buildCapabilityCard({
    required IconData icon,
    required String title,
    required String desc,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Stack(
        children: [
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: primaryBlue, size: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey.shade400,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget hiển thị logo từ internet (Google, GitHub)
  Widget _buildSocialIconFromNetwork(String url, {double size = 24, bool isColor = false}) {
    return IconButton(
      onPressed: () {},
      icon: Image.network(
        url,
        width: size,
        height: size,
        color: isColor ? null : darkText, // Tự động đổi màu logo GitHub sang màu tối giống thiết kế
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 20),
      ),
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
    );
  }

  // Widget hiển thị logo hệ thống (Apple)
  Widget _buildSocialIconFromIcon(IconData icon, {double size = 24}) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, color: darkText, size: size),
      constraints: const BoxConstraints(),
      padding: EdgeInsets.zero,
    );
  }
}