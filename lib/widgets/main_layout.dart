import 'package:flutter/material.dart';
import 'package:mo/widgets/app_tab.dart';
import 'package:mo/widgets/custom_bottom_nav_bar.dart';
import 'package:mo/features/mock_data/login-mock-data.dart';
import 'package:mo/features/game_management/game_selection_screen.dart';
import 'package:mo/features/history/history_screen.dart';
import 'package:mo/features/cloud_sync/cloud_sync_screen.dart';
import 'package:mo/features/player_lookup/player_lookup_screen.dart';
import 'package:mo/features/profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  // Pass dynamic user data down from LoginScreen
  final UserModel user;
  final List<GameModel> games;

  const MainLayout({
    super.key,
    required this.user,
    required this.games,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  AppTab _currentTab = AppTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves the state of each tab to prevent reloading data
      body: IndexedStack(
        index: _currentTab.index,
        children: [
          GameSelectionScreen(
            user: widget.user,
            games: widget.games,
          ), // Tab 0: Home
          const HistoryScreen(),       // Tab 1: History
          const Center(child: Text('Dashboard')), // Tab 2: Dashboard
          const PlayerLookupScreen(),  // Tab 3: Players
          const CloudSyncScreen(),     // Tab 4: Cloud Sync
          const ProfileScreen(),       // Tab 5: Profile
        ],
      ),
      // FIXED: Aligned parameters perfectly with your Enum-driven CustomBottomNavBar 👇
      bottomNavigationBar: CustomBottomNavBar(
        currentTab: _currentTab, // Passes the current active Enum tab
        onTabSelected: (AppTab selectedTab) {
          setState(() {
            _currentTab = selectedTab; // Updates the state beautifully on click
          });
        },
      ),
    );
  }
}