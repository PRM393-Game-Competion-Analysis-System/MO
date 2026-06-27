import 'package:flutter/material.dart';

class PlayerLookupScreen extends StatelessWidget {
  const PlayerLookupScreen({super.key});

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
                              value: "Global",
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.public, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                              items: const [
                                DropdownMenuItem(value: "Global", child: Text("Global", style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (val) {},
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
                              value: "Rank",
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.filter_alt_outlined, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                              ),
                              items: const [
                                DropdownMenuItem(value: "Rank", child: Text("Rank", style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (val) {},
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
                      onPressed: () {},
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
                text: const TextSpan(
                  style: TextStyle(color: darkText, fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "Search Results | "),
                    TextSpan(text: "268", style: TextStyle(color: primaryBlue)),
                    TextSpan(text: " players"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Player Card
            _buildPlayerCard(),

            const SizedBox(height: 32),
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                "Loading more players...",
                style: TextStyle(color: secondaryText, fontSize: 12),
              ),
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
      // REMOVED: bottomNavigationBar property is now entirely managed by MainLayout globally!
    );
  }

  Widget _buildPlayerCard() {
    return Container(
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
                  image: const DecorationImage(
                    image: NetworkImage("https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200"),
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
                        const Text(
                          "ShadowSlayer",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: darkText),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Lvl 95",
                            style: TextStyle(color: primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: secondaryText),
                        SizedBox(width: 4),
                        Text("NA East 1", style: TextStyle(color: secondaryText, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("RANK", style: TextStyle(fontSize: 10, color: secondaryText, fontWeight: FontWeight.bold)),
                  Text(
                    "#1",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent),
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
              _buildStatItem("SCORE", "14,520", Icons.star_outline),
              _buildStatItem("GUILD", "Void Walk", Icons.directions_car_filled_outlined),
              _buildStatItem("PLAYER ID", "PX-70210", null),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 18, color: primaryBlue),
                  SizedBox(width: 8),
                  Text(
                    "Top 1% of Server",
                    style: TextStyle(color: primaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
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
    return Column(
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
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
          ],
        ),
      ],
    );
  }
}