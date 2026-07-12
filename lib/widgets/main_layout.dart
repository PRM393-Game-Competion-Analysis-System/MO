import 'package:flutter/material.dart';
import 'package:mo/widgets/app_tab.dart';
import 'package:mo/widgets/custom_bottom_nav_bar.dart';
import 'package:mo/features/mock_data/login-mock-data.dart';
import 'package:mo/features/game_management/game_selection_screen.dart';
import 'package:mo/features/history/history_screen.dart';
import 'package:mo/features/cloud_sync/cloud_sync_screen.dart';
import 'package:mo/features/player_lookup/player_lookup_screen.dart';
import 'package:mo/features/profile/profile_screen.dart';
import 'package:mo/features/profile/admin_profile_screen.dart';
import 'package:mo/features/game_management/dashboard_screen.dart';

class MainLayout extends StatefulWidget {
  final UserModel user;
  final List<GameModel> games;

  const MainLayout({
    super.key,
    required this.user,
    required this.games,
  });

  static _MainLayoutState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MainLayoutState>();

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  AppTab _currentTab = AppTab.home;

  void setTab(AppTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentTab == AppTab.home,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setTab(AppTab.home);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentTab.index,
          children: [
            GameSelectionScreen(
              user: widget.user,
              games: widget.games,
            ),
            const HistoryScreen(),
            const DashboardScreen(),
            const PlayerLookupScreen(),
            const CloudSyncScreen(),
            widget.user.isAdmin ? const AdminProfileScreen() : const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentTab: _currentTab,
          onTabSelected: (AppTab selectedTab) {
            setTab(selectedTab);
          },
        ),
      ),
    );
  }
}