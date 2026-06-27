import 'package:flutter/material.dart';

class ActivityCenterScreen extends StatelessWidget {
  const ActivityCenterScreen({super.key});

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
          "Activity Center",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Live Data Badge
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryBlue.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  "Live Data",
                  style: TextStyle(color: primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Top Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildSmallStatCard(
                    icon: Icons.square,
                    title: "Total Players",
                    value: "12,842",
                    percentage: "+14%",
                    iconColor: const Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmallStatCard(
                    icon: Icons.bolt,
                    title: "Analyses Run",
                    value: "4,920",
                    percentage: "+8.2%",
                    iconColor: primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Engine Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.layers_outlined, color: primaryBlue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "ENGINE STATUS",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                      Text(
                        "Operational",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "AI Queue Load",
                        style: TextStyle(fontSize: 12, color: secondaryText),
                      ),
                      const Text(
                        "24%",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(
                      value: 0.24,
                      backgroundColor: Color(0xFFE0E0E0),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildEngineStat("Active Nodes", "12/12"),
                      Container(width: 1, height: 24, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16)),
                      _buildEngineStat("Latency", "84ms"),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(80, 36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Refresh", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Management Cards
            _buildManagementCard(
              icon: Icons.person_outline,
              title: "User Management",
              subtitle: "Review accounts, roles, and permissions.",
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.history,
              title: "Analysis History",
              subtitle: "Audit all processed screenshots.",
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.grid_view_outlined,
              title: "Activity Trends",
              subtitle: "Main analytics and growth charts.",
            ),
            const SizedBox(height: 12),
            _buildManagementCard(
              icon: Icons.show_chart_outlined,
              title: "Activity Heatmap",
              subtitle: "Visualize regional traffic patterns.",
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatCard({required IconData icon, required String title, required String value, required String percentage, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        // ĐÃ SỬA CÚ PHÁP CHUẨN TẠI ĐÂY 👇
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Text(
                percentage,
                style: const TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: secondaryText, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: darkText)),
        ],
      ),
    );
  }

  Widget _buildEngineStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: secondaryText, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: darkText)),
      ],
    );
  }

  Widget _buildManagementCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F2F5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primaryBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: secondaryText)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}