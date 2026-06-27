import 'package:flutter/material.dart';

class AnalysisHistoryScreen extends StatelessWidget {
  const AnalysisHistoryScreen({super.key});

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
          "Analysis History",
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Logs Section Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: const [
                        Icon(Icons.verified_user_outlined, color: primaryBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          "Security Logs",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: darkText),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildLogItem("New Admin Account: 'alex_ops'", "2 mins ago", false),
                  _buildLogItem("Failed Login Attempt (IP: 192.x.x.x)", "15 mins ago", true),
                  _buildLogItem("Model Update: V4.2 Deployed", "1 hour ago", false),
                  _buildLogItem("Sync Task: Global Ranking Refresh", "3 hours ago", false),
                  _buildLogItem("Scheduled Maintenance Success", "6 hours ago", false),

                  // View Full Audit Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF).withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "View Full Audit Trail",
                        style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Recent Analysis Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.history_toggle_off, size: 20, color: darkText),
                    SizedBox(width: 8),
                    Text("Recent Analysis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("View All", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Analysis Sample Card (Genshin Impact)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=200",
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
                            const Text("Genshin Impact", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                            Text("2 hours ago", style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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
                            const Text("5200 pts", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
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
            const SizedBox(height: 24),

            // Simulated Dotted Load More Container
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 1, style: BorderStyle.solid),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.more_horiz, color: secondaryText, size: 20),
                    SizedBox(width: 8),
                    Text("Load More History", style: TextStyle(color: secondaryText, fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLogItem(String title, String time, bool isAlert) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          if (isAlert)
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle))
          else
            const SizedBox(width: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: darkText)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(64, 30),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              side: BorderSide(color: Colors.grey.shade200),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              foregroundColor: darkText,
            ),
            child: const Text("Details", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildTagBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}