import 'package:flutter/material.dart';
import 'package:mo/widgets/custom_bottom_nav_bar.dart';
import 'package:mo/features/history/history_screen.dart';
import 'package:mo/features/cloud_sync/cloud_sync_screen.dart';
import 'package:mo/features/player_lookup/player_lookup_screen.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Cover and Avatar
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Cover Image
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=1000"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                // AppBar items
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          "My Profile",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer for centering
                    ],
                  ),
                ),
                // Avatar
                Positioned(
                  bottom: -60,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 56,
                          backgroundImage: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200"),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),

            // Stats Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem("Total Analyses", "1,248"),
                    _buildDivider(),
                    _buildStatItem("Global Rank", "#42"),
                    _buildDivider(),
                    _buildStatItem("Account Level", "Gold"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Username", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                    const SizedBox(height: 8),
                    _buildTextField("Alex_ProGamer", Icons.person_outline),
                    const SizedBox(height: 20),
                    const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                    const SizedBox(height: 8),
                    _buildTextField("alex.v@ranklens-ai.com", Icons.email_outlined),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_outlined, size: 18, color: darkText),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Your data is secured with AI-powered encryption.",
                              style: TextStyle(fontSize: 11, color: secondaryText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined),
                  label: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 4, // Profile index
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
          } else if (index == 2) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CloudSyncScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const PlayerLookupScreen()));
          }
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: secondaryText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildTextField(String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
