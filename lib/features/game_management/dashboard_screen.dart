import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';
import 'package:mo/widgets/main_layout.dart';
import 'package:mo/widgets/app_tab.dart';

class ExtractedPlayer {
  final int rank;
  final String name;
  final String guild;
  final int power;

  ExtractedPlayer({
    required this.rank,
    required this.name,
    required this.guild,
    required this.power,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  // Khai báo bảng màu chuẩn theo thiết kế thống nhất của dự án
  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);
  static const Color accentPurple = Color(0xFFEEF2FF);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<PlayerModel> _recentPlayers = [];
  List<LeaderboardModel> _leaderboards = [];
  bool _isLoading = true;
  String _errorMessage = "";
  String _searchQuery = "";
  int _currentPage = 0;
  static const int _pageSize = 10;
  String _tournamentSort = "none";

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final players = await ApiService.getPlayers();
      final leaderboards = await ApiService.getLeaderboards();
      setState(() {
        _recentPlayers = players;
        _leaderboards = leaderboards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  List<LeaderboardModel> _getFilteredLeaderboards() {
    List<LeaderboardModel> list = List.from(_leaderboards);
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((l) {
        final matchesTitle = l.title.toLowerCase().contains(query);
        final matchesEvent = l.eventName.toLowerCase().contains(query);
        return matchesTitle || matchesEvent;
      }).toList();
    }
    if (_tournamentSort == "asc") {
      list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_tournamentSort == "desc") {
      list.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }
    return list;
  }

  Future<void> _confirmAndDeleteLeaderboard(LeaderboardModel item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa bảng xếp hạng \"${item.title.startsWith('Bảng xếp hạng [') ? 'Bảng Xếp Hạng Chiến Lực' : item.title}\" không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Hủy", style: TextStyle(color: DashboardScreen.secondaryText)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Xóa", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: DashboardScreen.primaryBlue),
        ),
      );

      try {
        await ApiService.deleteLeaderboard(item.leaderboardId);
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã xóa bảng xếp hạng thành công.")),
          );
          _fetchDashboardData();
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi khi xóa bảng xếp hạng: $e")),
          );
        }
      }
    }
  }

  Future<void> _fetchAndShowLeaderboardDetails(LeaderboardModel item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: DashboardScreen.primaryBlue),
      ),
    );

    try {
      final entries = await ApiService.getLeaderboardEntries(item.leaderboardId);
      if (mounted) {
        Navigator.of(context).pop();
        _showLeaderboardDetailsModal(item, entries);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi tải chi tiết bảng xếp hạng: $e")),
        );
      }
    }
  }

  void _showLeaderboardDetailsModal(LeaderboardModel item, List<LeaderboardItem> entries) {
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String modalSearch = "";
        String modalSort = "rank";

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<LeaderboardItem> filtered = List.from(entries);
            if (modalSearch.isNotEmpty) {
              final query = modalSearch.toLowerCase();
              filtered = filtered.where((p) {
                return p.playerName.toLowerCase().contains(query) ||
                    p.guildName.toLowerCase().contains(query);
              }).toList();
            }

            if (modalSort == "asc") {
              filtered.sort((a, b) => a.playerName.toLowerCase().compareTo(b.playerName.toLowerCase()));
            } else if (modalSort == "desc") {
              filtered.sort((a, b) => b.playerName.toLowerCase().compareTo(a.playerName.toLowerCase()));
            } else if (modalSort == "rank") {
              filtered.sort((a, b) => a.rank.compareTo(b.rank));
            }

            return Container(
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
                      const Icon(Icons.emoji_events_outlined, color: Colors.orange, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title.startsWith('Bảng xếp hạng [') ? "Bảng Xếp Hạng Chiến Lực" : item.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: DashboardScreen.darkText),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Sự kiện: ${item.eventName.startsWith('[') ? 'Giải Đấu Mở Rộng' : item.eventName}",
                    style: const TextStyle(color: DashboardScreen.secondaryText, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: DashboardScreen.secondaryText, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (val) {
                                    setModalState(() {
                                      modalSearch = val;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Tìm kiếm cao thủ hoặc bang hội...",
                                    hintStyle: TextStyle(color: DashboardScreen.secondaryText, fontSize: 13),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              if (modalSearch.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    setModalState(() {
                                      modalSearch = "";
                                    });
                                  },
                                  child: const Icon(Icons.close, color: DashboardScreen.secondaryText, size: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.sort_by_alpha,
                          color: modalSort == "rank"
                              ? DashboardScreen.secondaryText
                              : DashboardScreen.primaryBlue,
                        ),
                        tooltip: "Sắp xếp",
                        onSelected: (value) {
                          setModalState(() {
                            modalSort = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: "rank", child: Text("Sắp xếp: Thứ hạng")),
                          const PopupMenuItem(value: "asc", child: Text("Tên: A-Z")),
                          const PopupMenuItem(value: "desc", child: Text("Tên: Z-A")),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(
                            child: Text("Không tìm thấy kết quả phù hợp.",
                                style: TextStyle(color: DashboardScreen.secondaryText)))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final p = filtered[index];
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
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: DashboardScreen.secondaryText),
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
                                          Text(p.playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: DashboardScreen.darkText)),
                                          const SizedBox(height: 2),
                                          Text("Guild: ${p.guildName.isEmpty ? 'Không Bang' : p.guildName}", style: const TextStyle(color: DashboardScreen.secondaryText, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          p.score.toString(),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: DashboardScreen.primaryBlue),
                                        ),
                                        Text(
                                          item.metricType.isNotEmpty ? item.metricType : "Chiến Lực",
                                          style: const TextStyle(color: DashboardScreen.secondaryText, fontSize: 10),
                                        ),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeaderboards = _getFilteredLeaderboards();

    return Scaffold(
      backgroundColor: DashboardScreen.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: DashboardScreen.darkText, size: 20),
          onPressed: () => MainLayout.of(context)?.setTab(AppTab.home),
        ),
        title: const Text(
          "Dashboard",
          style: TextStyle(color: DashboardScreen.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: DashboardScreen.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _currentPage = 0;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search tournaments, events or players...",
                    hintStyle: TextStyle(color: DashboardScreen.secondaryText, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: DashboardScreen.secondaryText, size: 22),
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
                      Icon(Icons.people_outline, size: 20, color: DashboardScreen.darkText),
                      SizedBox(width: 8),
                      Text(
                        "Registered High Rollers",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: DashboardScreen.darkText),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _fetchDashboardData,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "Refresh",
                      style: TextStyle(color: DashboardScreen.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoading && _recentPlayers.isEmpty)
                const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator(color: DashboardScreen.primaryBlue)),
                )
              else if (_recentPlayers.isEmpty)
                const SizedBox(
                  height: 80,
                  child: Center(child: Text("No registered players yet.", style: TextStyle(color: DashboardScreen.secondaryText))),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  child: Row(
                    children: _recentPlayers.take(6).map((player) {
                      final imgUrl = player.playerId % 2 == 0
                          ? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200"
                          : "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200";
                      return _buildPlayerAvatar(
                        player.playerName,
                        imgUrl,
                        player.latestScore > 100 ? Colors.green : Colors.orange,
                        player.latestScore.toString(),
                      );
                    }).toList(),
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
                        const Icon(Icons.show_chart, color: DashboardScreen.primaryBlue, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          "Score Progression",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DashboardScreen.darkText),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: DashboardScreen.accentPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Global Live Standings",
                            style: TextStyle(color: DashboardScreen.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Historical average combat score levels",
                      style: TextStyle(color: DashboardScreen.secondaryText, fontSize: 12),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("HIGHEST RECORD", style: TextStyle(color: DashboardScreen.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(
                                  _recentPlayers.isEmpty
                                      ? "0"
                                      : _recentPlayers.map((p) => p.latestScore).reduce((a, b) => a > b ? a : b).toString(),
                                  style: const TextStyle(color: DashboardScreen.primaryBlue, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("AVERAGE RECORD", style: TextStyle(color: DashboardScreen.secondaryText, fontSize: 10, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _recentPlayers.isEmpty
                                          ? "0"
                                          : (_recentPlayers.map((p) => p.latestScore).reduce((a, b) => a + b) / _recentPlayers.length).toStringAsFixed(0),
                                      style: const TextStyle(color: DashboardScreen.darkText, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

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

              // 4. BẢNG XẾP HẠNG GIẢI ĐẤU (Tournament Leaderboards)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history_toggle_off, size: 20, color: DashboardScreen.darkText),
                      const SizedBox(width: 8),
                      const Text(
                        "Tournament Standings",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: DashboardScreen.darkText),
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.sort_by_alpha,
                          size: 18,
                          color: _tournamentSort == "none"
                              ? DashboardScreen.secondaryText
                              : DashboardScreen.primaryBlue,
                        ),
                        tooltip: "Sắp xếp",
                        onSelected: (value) {
                          setState(() {
                            _tournamentSort = value;
                            _currentPage = 0;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: "none", child: Text("Mặc định")),
                          const PopupMenuItem(value: "asc", child: Text("Tên: A-Z")),
                          const PopupMenuItem(value: "desc", child: Text("Tên: Z-A")),
                        ],
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _fetchDashboardData,
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text(
                      "View All",
                      style: TextStyle(color: DashboardScreen.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isLoading && _leaderboards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: CircularProgressIndicator(color: DashboardScreen.primaryBlue)),
                )
              else if (_errorMessage.isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text("Error: $_errorMessage", style: const TextStyle(color: Colors.redAccent)),
                  ),
                )
              else if (filteredLeaderboards.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(child: Text("No standings found.", style: TextStyle(color: DashboardScreen.secondaryText))),
                )
              else
                Builder(
                  builder: (context) {
                    final totalPages = (filteredLeaderboards.length / _pageSize).ceil();
                    int activePage = _currentPage;
                    if (activePage >= totalPages && totalPages > 0) {
                      activePage = totalPages - 1;
                    }
                    if (activePage < 0) activePage = 0;

                    final startIndex = activePage * _pageSize;
                    final endIndex = (startIndex + _pageSize) < filteredLeaderboards.length
                        ? (startIndex + _pageSize)
                        : filteredLeaderboards.length;
                    final pageItems = filteredLeaderboards.sublist(startIndex, endIndex);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (totalPages > 1) ...[
                          Container(
                            height: 36,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: totalPages,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final isSelected = index == activePage;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? DashboardScreen.primaryBlue : Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: isSelected ? DashboardScreen.primaryBlue : Colors.grey.shade200,
                                        width: 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: DashboardScreen.primaryBlue.withValues(alpha: 0.15),
                                                blurRadius: 6,
                                                offset: const Offset(0, 3),
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Trang ${index + 1}",
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : DashboardScreen.darkText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity != null) {
                              if (details.primaryVelocity! < -300) {
                                // Swiped left -> Next page
                                if (activePage < totalPages - 1) {
                                  setState(() {
                                    _currentPage = activePage + 1;
                                  });
                                }
                              } else if (details.primaryVelocity! > 300) {
                                // Swiped right -> Previous page
                                if (activePage > 0) {
                                  setState(() {
                                    _currentPage = activePage - 1;
                                  });
                                }
                              }
                            }
                          },
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pageItems.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = pageItems[index];

                              // Beautify display title
                              String titleDisplay = item.title;
                              if (titleDisplay.startsWith('Bảng xếp hạng [')) {
                                titleDisplay = "Bảng Xếp Hạng Chiến Lực";
                              }

                              return GestureDetector(
                                onTap: () => _fetchAndShowLeaderboardDetails(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.leaderboard_outlined,
                                          color: DashboardScreen.primaryBlue,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          titleDisplay,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: DashboardScreen.darkText,
                                          ),
                                        ),
                                      ),
                                      if (ApiService.currentUserRole == 'admin') ...[
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                          onPressed: () => _confirmAndDeleteLeaderboard(item),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (totalPages > 1) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.swap_horizontal_circle_outlined, size: 14, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Text(
                                  "Vuốt ngang danh sách hoặc chọn trang để xem tiếp",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(String name, String imgUrl, Color statusColor, String score) {
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
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DashboardScreen.darkText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            "$score pts",
            style: const TextStyle(fontSize: 10, color: DashboardScreen.primaryBlue, fontWeight: FontWeight.bold),
          ),
        ],
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