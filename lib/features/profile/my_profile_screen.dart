import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  late Future<ApiUserModel> _profileFuture;
  TextEditingController? _usernameController;
  TextEditingController? _emailController;

  @override
  void initState() {
    super.initState();
    _profileFuture = ApiService.getUserProfile().then((profile) {
      _usernameController = TextEditingController(text: profile.username);
      _emailController = TextEditingController(text: profile.email);
      return profile;
    });
  }

  @override
  void dispose() {
    _usernameController?.dispose();
    _emailController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ApiUserModel>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: bgColor,
            body: Center(
              child: CircularProgressIndicator(color: primaryBlue),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Failed to load profile: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ),
          );
        }

        final profile = snapshot.data!;
        final role = profile.role;
        final avatarUrl = role == 'admin'
            ? "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200"
            : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200";

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
                    // AppBar items with back action
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
                    // Avatar Picture
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
                            child: CircleAvatar(
                              radius: 56,
                              backgroundImage: NetworkImage(avatarUrl),
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
                        _buildStatItem("Account Level", role == 'admin' ? "Admin" : "Gold"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Information Form
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
                        if (_usernameController != null)
                          _buildTextField(_usernameController!, Icons.person_outline),
                        const SizedBox(height: 20),
                        const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                        const SizedBox(height: 8),
                        if (_emailController != null)
                          _buildTextField(_emailController!, Icons.email_outlined),
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

                // Save Changes Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final username = _usernameController?.text.trim() ?? '';
                          final email = _emailController?.text.trim() ?? '';
                          if (username.isEmpty || email.isEmpty) {
                            throw Exception("Username and email cannot be empty.");
                          }
                          messenger.showSnackBar(
                            const SnackBar(content: Text("Saving profile changes...")),
                          );
                          await ApiService.updateUserProfile(username, email);
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(content: Text("Profile changes saved successfully!")),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text("Failed to save changes: $e")),
                            );
                          }
                        }
                      },
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
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

  Widget _buildTextField(TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
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