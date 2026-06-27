import 'package:flutter/material.dart';
import 'package:mo/features/mock_data/login-mock-data.dart';
import 'package:mo/features/cloud_sync/cloud_sync_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  // Required data parameters passed from LoginScreen via MainLayout
  final UserModel user;
  final List<GameModel> games;

  const GameSelectionScreen({
    super.key,
    required this.user,
    required this.games,
  });

  // Color palette matching the design
  static const Color primaryBlue = Color(0xFF1E40AF);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color darkText = Color(0xFF1A1D20);

  @override
  Widget build(BuildContext context) {
    // Select the first game from mock data as the featured item
    final featuredGame = games.isNotEmpty ? games.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // Allows the banner image to sit beautifully against the status bar
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header Banner with local asset image
                        _buildHeaderBanner(context, user),

                        const SizedBox(height: 20),

                        // 2. Filter row (All, RPG, FPS, MOBA)
                        _buildFilterRow(),

                        const SizedBox(height: 20),

                        // 3. Dynamic Game Card display
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: featuredGame != null
                              ? _buildGameCard(featuredGame)
                              : const Text("No games available"),
                        ),

                        const SizedBox(height: 16),

                        // Pagination indicator dots
                        const Center(
                          child: Text(
                            "● ● ●",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // 4. Sticky Action Bar showing selected item details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: featuredGame != null
                              ? _buildSelectedActionBar(featuredGame)
                              : const SizedBox(),
                        ),

                        const SizedBox(height: 100), // Padding spacer at bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Refresh Button aligned right above global bottom navigation
            Positioned(
              right: 20,
              bottom: kBottomNavigationBarHeight + 20,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: primaryBlue,
                shape: const CircleBorder(),
                child: const Icon(Icons.refresh, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
      // REMOVED: bottomNavigationBar property is now completely handled by MainLayout globally!
    );
  }

  // --- HEADER BANNER WIDGET WITH SEARCHBAR ---
  Widget _buildHeaderBanner(BuildContext context, UserModel user) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/banner.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.6),
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CloudSyncScreen()),
                      );
                    },
                    child: Icon(Icons.sync, color: Colors.blue.shade300, size: 22),
                  ),
                ),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    children: [
                      const TextSpan(text: "Welcome back, "),
                      TextSpan(
                        text: user.username,
                        style: const TextStyle(color: accentOrange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Search bar overlapping header bottom edge
        Positioned(
          bottom: -24,
          left: 24,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search library...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- FILTER CHIPS ROW WIDGET ---
  Widget _buildFilterRow() {
    final List<String> categories = ["All", "RPG", "FPS", "MOBA"];
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.filter_alt_outlined, color: primaryBlue, size: 20),
            ),
            const SizedBox(width: 8),
            ...categories.map((category) {
              final bool isAll = category == "All";
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAll ? primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAll ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isAll ? Colors.white : darkText,
                      fontWeight: isAll ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // --- DYNAMIC GAME DISPLAY CARD WIDGET ---
  Widget _buildGameCard(GameModel game) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryBlue, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                child: Image.network(
                  game.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/banner.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (game.isPopular)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Popular",
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const Positioned(
                top: 12,
                right: 12,
                child: Icon(Icons.check_circle, color: Colors.white, size: 24),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    game.category,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue),
                    ),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          game.playersCount,
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  game.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.bolt, color: primaryBlue, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "AI ANALYSIS READY",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkText),
                    ),
                    Spacer(),
                    Icon(Icons.emoji_events_outlined, color: primaryBlue, size: 18),
                    SizedBox(width: 4),
                    Text(
                      "GLOBAL RANK",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkText),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- STICKY FOOTER ACTION BAR WIDGET ---
  Widget _buildSelectedActionBar(GameModel game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SELECTED TITLE",
                style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                game.title,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Row(
            children: [
              Text(
                "Next Step",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 6),
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
            ],
          )
        ],
      ),
    );
  }
}