import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';

class PlayerLookupScreen extends StatefulWidget {
  const PlayerLookupScreen({super.key});

  @override
  State<PlayerLookupScreen> createState() => _PlayerLookupScreenState();
}

class _PlayerLookupScreenState extends State<PlayerLookupScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PlayerModel> _allPlayers = [];
  List<PlayerModel> _searchResultPlayers = [];
  List<PlayerModel> _filteredPlayers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedServer = "Global";
  String _selectedFilter = "Rank";

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Set<String> get _servers {
    final set = <String>{'Global'};
    for (var p in _allPlayers) {
      if (p.serverName.isNotEmpty) {
        set.add(p.serverName);
      }
    }
    return set;
  }

  void _applyLocalFilters() {
    setState(() {
      List<PlayerModel> list = List.from(_searchResultPlayers);

      // Server Filter
      if (_selectedServer != "Global") {
        list = list.where((p) => p.serverName == _selectedServer).toList();
      }

      // Sort Type Filter
      if (_selectedFilter == "Rank") {
        list.sort((a, b) => a.latestRank.compareTo(b.latestRank));
      } else if (_selectedFilter == "Score") {
        list.sort((a, b) => b.latestScore.compareTo(a.latestScore));
      } else if (_selectedFilter == "Name") {
        list.sort((a, b) => a.playerName.toLowerCase().compareTo(b.playerName.toLowerCase()));
      }

      _filteredPlayers = list;
    });
  }

  Future<void> _fetchPlayers() async {
    try {
      final players = await ApiService.getPlayers();
      if (mounted) {
        setState(() {
          _allPlayers = players;
          _searchResultPlayers = players;
          _isLoading = false;
        });
        _applyLocalFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResultPlayers = _allPlayers;
        _errorMessage = '';
      });
      _applyLocalFilters();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final numericId = int.tryParse(query);
      if (numericId != null) {
        final player = await ApiService.getPlayerById(numericId);
        if (mounted) {
          setState(() {
            _searchResultPlayers = player != null ? [player] : [];
            _isLoading = false;
          });
          _applyLocalFilters();
        }
      } else {
        final players = await ApiService.searchPlayers(query);
        if (mounted) {
          setState(() {
            _searchResultPlayers = players;
            _isLoading = false;
          });
          _applyLocalFilters();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
          _searchResultPlayers = [];
        });
        _applyLocalFilters();
      }
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Player Lookup",
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: darkText),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: darkText),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PLAYER NAME",
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryText, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => _performSearch(), // dynamic instant search
                    decoration: InputDecoration(
                      hintText: "Enter username...",
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SERVER REGION",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryText),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedServer,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.public, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                              items: _servers.map((server) {
                                return DropdownMenuItem(
                                  value: server,
                                  child: Text(
                                    server,
                                    style: const TextStyle(fontSize: 11),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedServer = val;
                                  });
                                  _applyLocalFilters();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "FILTER TYPE",
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: secondaryText),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedFilter,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.filter_alt_outlined, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                              items: const [
                                DropdownMenuItem(value: "Rank", child: Text("Rank", style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: "Score", child: Text("Score", style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: "Name", child: Text("Name", style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedFilter = val;
                                  });
                                  _applyLocalFilters();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search, size: 20),
                      label: const Text("Search Players", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Search Results Summary
            Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    const TextSpan(text: "Search Results | "),
                    TextSpan(text: "${_filteredPlayers.length}", style: const TextStyle(color: primaryBlue)),
                    TextSpan(text: " players"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results Listing
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(color: primaryBlue),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Text("Error: $_errorMessage", style: const TextStyle(color: Colors.red)),
                ),
              )
            else if (_filteredPlayers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Text("No players found.", style: TextStyle(color: secondaryText, fontSize: 15)),
                ),
              )
            else
              Column(
                children: _filteredPlayers.map((player) => _buildPlayerCard(player)).toList(),
              ),

            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Show Next 20 Players",
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerModel player) {
    final int level = 99 - player.latestRank;
    final String avatarUrl = player.latestRank == 1
        ? "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200"
        : "https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          player.playerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkText),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "Lvl $level",
                            style: const TextStyle(color: primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: secondaryText),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            player.serverName,
                            style: const TextStyle(color: secondaryText, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("RANK", style: TextStyle(fontSize: 10, color: secondaryText, fontWeight: FontWeight.bold)),
                  Text(
                    "#${player.latestRank}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: player.latestRank == 1 ? Colors.amber : Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("SCORE", player.latestScore.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"), Icons.star_outline),
              _buildStatItem("GUILD", player.guildName.isNotEmpty ? player.guildName : "No Guild", Icons.emoji_events_outlined),
              _buildStatItem("PLAYER ID", "PL-${player.playerId.toString().padLeft(5, '0')}", null),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events_outlined, size: 18, color: primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    player.latestRank <= 3 ? "Top 3 of Server" : "Top ${player.latestRank * 2}% of Server",
                    style: const TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: const Row(
                  children: [
                    Text("Analytics", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: primaryBlue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData? icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: secondaryText, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: primaryBlue),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}