import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';
import 'package:mo/features/profile/my_profile_screen.dart';
import 'package:mo/features/profile/activity_center_screen.dart';
import 'package:mo/widgets/main_layout.dart';
import 'package:mo/widgets/app_tab.dart';
import 'package:mo/features/auth/welcome.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  late Future<ApiUserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = ApiService.getUserProfile();
    });
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
          "My Profile",
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Admin Info Card
            FutureBuilder<ApiUserModel>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 98,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const CircularProgressIndicator(color: primaryBlue),
                  );
                }

                final profile = snapshot.data;
                final username = profile?.username ?? "Alex V.";
                final email = profile?.email ?? "alex@gmail.com";
                final role = profile?.role ?? "user";
                final avatarUrl = role == 'admin'
                    ? "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200"
                    : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200";

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                    ).then((_) => _refreshProfile());
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
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
                          width: 64,
                          height: 64,
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
                                    username,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryBlue),
                                  ),
                                  const SizedBox(width: 8),
                                  if (role == 'admin')
                                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: const TextStyle(color: secondaryText, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Account Verified Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_outlined, color: primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Verified",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText),
                        ),
                        Text(
                          "Your game analytics are protected by AI encryption.",
                          style: TextStyle(color: secondaryText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ACCOUNT Section (Admin specific)
            const Text(
              "ACCOUNT",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryText, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMenuTile(Icons.person_outline, "Manage Account", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyProfileScreen()),
                    );
                  }),
                  _buildMenuTile(Icons.vpn_key_outlined, "Password & Security"),
                  _buildMenuTile(Icons.dashboard_customize_outlined, "Activity Center", onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ActivityCenterScreen()),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // PREFERENCES Section
            const Text(
              "PREFERENCES",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: secondaryText, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildMenuTile(Icons.info_outline, "About Us"),
                  _buildMenuTile(
                    Icons.logout_outlined,
                    "Log Out",
                    isDestructive: true,
                    onTap: () {
                      ApiService.logout(); // Clear session and user email
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const GameAnalyzeWelcomeScreen()),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      // REMOVED: bottomNavigationBar property is now handled globally by MainLayout shell!
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {String? trailingText, bool showSwitch = false, bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : primaryBlue, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.redAccent : darkText,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          if (showSwitch)
            Switch(
              value: false,
              onChanged: (val) {},
              activeTrackColor: primaryBlue.withValues(alpha: 0.5),
              activeColor: primaryBlue,
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: isDestructive ? Colors.redAccent : Colors.grey.shade400, size: 20),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}