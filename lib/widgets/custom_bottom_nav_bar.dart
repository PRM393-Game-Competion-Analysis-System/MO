import 'package:flutter/material.dart';
import 'package:mo/widgets/app_tab.dart';

class CustomBottomNavBar extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  const CustomBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  static const Color primaryBlue = Color(0xFF1E40AF);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: primaryBlue,
      unselectedItemColor: Colors.grey.shade400,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      currentIndex: currentTab.index, // Lấy index tự động từ Enum
      onTap: (int index) {
        // Trả về Enum tương ứng với vị trí click
        onTabSelected(AppTab.values[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Players'),
        BottomNavigationBarItem(icon: Icon(Icons.cloud_sync_outlined), label: 'Cloud Sync'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}