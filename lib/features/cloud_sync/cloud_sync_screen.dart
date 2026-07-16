import 'package:flutter/material.dart';
import 'package:mo/widgets/main_layout.dart';
import 'package:mo/widgets/app_tab.dart';
import 'package:mo/API/api.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  bool _isAnalyzing = false;

  Future<void> _handleAutomaticAnalyze() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Gọi API phân tích tự động
      final result = await ApiService.analyzeAutomatic(gameId: 0);
      
      // Lưu vào lịch sử local để người dùng có thể xem lại sau
      await LocalHistoryService.saveResult(result);

      if (!mounted) return;

      // Hiển thị kết quả ngay lập tức bằng Modal
      _showResultModal(result);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analysis complete and saved to history!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm helper để parse dữ liệu từ chuỗi eventName nếu leaderboard bị trống (giống Dashboard)
  List<LeaderboardItem> _parseLeaderboardFromText(String text) {
    final List<LeaderboardItem> items = [];
    final regExp = RegExp(
      r'\{\s*"Hạng"\s*:\s*(\d+|"[^"]*")\s*,\s*"Tên"\s*:\s*"([^"]*)"\s*,\s*"Bang Hội"\s*:\s*"([^"]*)"\s*,\s*"Lực Chiến"\s*:\s*"([^"]*)"\s*\}',
      caseSensitive: false,
    );

    final matches = regExp.allMatches(text);
    for (final match in matches) {
      try {
        final rawRank = match.group(1)?.replaceAll('"', '') ?? '0';
        final rank = int.tryParse(rawRank) ?? 0;
        final name = match.group(2) ?? 'Unknown';
        final guild = match.group(3) ?? '';
        final rawPower = match.group(4) ?? '0';
        final power = int.tryParse(rawPower) ?? 0;

        items.add(LeaderboardItem(
          rank: rank,
          playerName: name,
          guildName: guild.isEmpty ? 'Không Bang' : guild,
          score: power,
          value: power,
        ));
      } catch (_) {}
    }
    return items;
  }

  void _showResultModal(AnalysisResultModel result) {
    // Nếu leaderboard trả về trống, ta thử parse từ eventName (chuỗi JSON thô từ OCR)
    List<LeaderboardItem> displayList = result.leaderboard;
    if (displayList.isEmpty && result.eventName.isNotEmpty) {
      displayList = _parseLeaderboardFromText(result.eventName);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: primaryBlue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.gameName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: darkText),
                        ),
                        Text(
                          "Analysis completed at ${result.processedTime.split('T').last.substring(0, 5)}",
                          style: const TextStyle(color: secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: secondaryText),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Hiển thị ảnh đã phân tích
            if (result.imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () => _showFullScreenImage(context, result.imageUrl),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(result.imageUrl),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text("ANALYSIS RESULTS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: secondaryText, letterSpacing: 1.1)),
                  Spacer(),
                  Icon(Icons.sort, size: 16, color: secondaryText),
                  SizedBox(width: 4),
                  Text("By Rank", style: TextStyle(fontSize: 12, color: secondaryText)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: displayList.isEmpty
                  ? const Center(child: Text("Không tìm thấy dữ liệu bảng xếp hạng trong ảnh.", style: TextStyle(color: secondaryText)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final item = displayList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: index < 3 ? primaryBlue : Colors.white,
                                child: Text(
                                  item.rank.toString(),
                                  style: TextStyle(
                                    color: index < 3 ? Colors.white : darkText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkText)),
                                    Text(item.guildName, style: const TextStyle(color: secondaryText, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item.score.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => "${m[1]},"),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryBlue),
                                  ),
                                  const Text("Lực chiến", style: TextStyle(color: secondaryText, fontSize: 10)),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
          onPressed: () => MainLayout.of(context)?.setTab(AppTab.home),
        ),
        title: const Text(
          "Cloud Sync",
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Google Photos Linked Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.cloud_outlined, color: primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Cloudinary Image Linked",
                              style: TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Live Sync Enabled",
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: primaryBlue),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 18, color: secondaryText),
                        SizedBox(width: 8),
                        Text(
                          "Auto-detection found new screenshots.",
                          style: TextStyle(fontSize: 12, color: darkText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Analyze Latest Sync Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAnalyzing ? null : _handleAutomaticAnalyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isAnalyzing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "Analyze Latest Sync",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  "Automatically identifies and ranks players from the most recent screenshot detected in your cloud storage.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryText, fontSize: 12, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 32),




            // Bottom Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: secondaryText, size: 28),
                  SizedBox(height: 12),
                  Text(
                    "Cloud images are managed by your connected accounts. Use the Analyze Latest button to process them into your history.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryText, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildScreenshotCard(String title, String syncTime, String imageUrl, {bool isNew = false}) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageUrl),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                if (isNew)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.access_time, size: 10, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "NEW",
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.videogame_asset_outlined, size: 14, color: primaryBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    syncTime,
                    style: const TextStyle(color: secondaryText, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
