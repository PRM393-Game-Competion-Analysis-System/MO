import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnalysisResultModel> _historyList = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String _selectedGameFilter = "All Games";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final history = await LocalHistoryService.getHistory();
      setState(() {
        _historyList = history;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<AnalysisResultModel> _getFilteredHistory() {
    return _historyList.where((item) {
      // 1. Game filter
      if (_selectedGameFilter != "All Games") {
        if (item.gameName.toLowerCase() != _selectedGameFilter.toLowerCase()) {
          return false;
        }
      }

      // 2. Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesGame = item.gameName.toLowerCase().contains(query);
        final matchesServer = item.serverName.toLowerCase().contains(query);
        final matchesId = "ANL-${item.analysisId}".toLowerCase().contains(query);
        if (!matchesGame && !matchesServer && !matchesId) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _showHistoryDetailsModal(AnalysisResultModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.history, color: HistoryScreen.primaryBlue, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${item.gameName} - Analysis Summary",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: HistoryScreen.darkText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              "Server: ${item.serverName} | Processed: ${item.processedTime.split('T').first}",
              style: const TextStyle(color: HistoryScreen.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: item.leaderboard.length,
                itemBuilder: (context, index) {
                  final p = item.leaderboard[index];
                  Widget rankWidget;
                  if (p.rank == 1) {
                    rankWidget = const Icon(Icons.emoji_events, color: Colors.orange, size: 22);
                  } else if (p.rank == 2) {
                    rankWidget = const Icon(Icons.emoji_events, color: Colors.grey, size: 22);
                  } else if (p.rank == 3) {
                    rankWidget = const Icon(Icons.emoji_events, color: Colors.brown, size: 22);
                  } else {
                    rankWidget = CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.grey.shade100,
                      child: Text(
                        p.rank.toString(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: HistoryScreen.secondaryText),
                      ),
                    );
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 28, child: Center(child: rankWidget)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: HistoryScreen.darkText)),
                              const SizedBox(height: 2),
                              Text("Guild: ${p.guildName.isEmpty ? 'N/A' : p.guildName}", style: const TextStyle(color: HistoryScreen.secondaryText, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              p.score.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: HistoryScreen.primaryBlue),
                            ),
                            const Text("Score", style: TextStyle(color: HistoryScreen.secondaryText, fontSize: 10)),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredHistory = _getFilteredHistory();

    return Scaffold(
      backgroundColor: HistoryScreen.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: HistoryScreen.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Analyze History",
          style: TextStyle(color: HistoryScreen.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: HistoryScreen.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.history, size: 20, color: HistoryScreen.darkText),
                  const SizedBox(width: 8),
                  const Text(
                    "RECENT LOGS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: HistoryScreen.darkText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _loadHistory,
                    icon: const Icon(Icons.refresh, size: 16, color: HistoryScreen.primaryBlue),
                    label: const Text(
                      "Reload",
                      style: TextStyle(color: HistoryScreen.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    "All Games",
                    "Genshin Impact",
                    "Honor of Kings",
                    "VALORANT"
                  ].map((label) => _buildFilterChip(label, _selectedGameFilter == label)).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search by ID or Game name...",
                    hintStyle: TextStyle(color: HistoryScreen.secondaryText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: HistoryScreen.secondaryText, size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_isLoading && _historyList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator(color: HistoryScreen.primaryBlue)),
                )
              else if (filteredHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      "No matching analysis logs found.",
                      style: TextStyle(color: HistoryScreen.secondaryText, fontSize: 14),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredHistory.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = filteredHistory[index];
                    final dateStr = item.processedTime.split('T').first;

                    return _buildHistoryCard(item, dateStr);
                  },
                ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {
          setState(() {
            _selectedGameFilter = label;
          });
        },
        selectedColor: HistoryScreen.primaryBlue,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : HistoryScreen.darkText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildHistoryCard(AnalysisResultModel item, String dateStr) {
    // Generate an display ID
    final idDisplay = "ANL-${item.analysisId.toString().substring(0, Uri.encodeComponent(item.analysisId.toString()).length.clamp(0, 5))}";

    // Set a default logo url if empty
    final logoUrl = item.gameName.toLowerCase().contains("genshin")
        ? "https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=500"
        : "https://images.unsplash.com/photo-1538481199705-c710c4e965fc?q=80&w=500";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: HistoryScreen.bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.videogame_asset, color: HistoryScreen.secondaryText),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.gameName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: HistoryScreen.darkText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "ID: $idDisplay",
                      style: const TextStyle(color: HistoryScreen.secondaryText, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 12, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      "COMPLETED",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: HistoryScreen.darkText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SERVER", style: TextStyle(color: HistoryScreen.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.serverName, style: const TextStyle(color: HistoryScreen.darkText, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("DATE PROCESSED", style: TextStyle(color: HistoryScreen.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(color: HistoryScreen.darkText, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Detected Rows", style: TextStyle(color: HistoryScreen.secondaryText, fontSize: 12)),
                  Text(
                    "${item.leaderboard.length}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: HistoryScreen.primaryBlue),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showHistoryDetailsModal(item),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HistoryScreen.bgColor,
                  foregroundColor: HistoryScreen.darkText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Row(
                  children: [
                    Text("View Detail", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}