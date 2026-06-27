import 'package:flutter/material.dart';

enum UserFilterTab { all, admins, moderators, online }

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  bool _showCreateModal = false;
  bool _showDetailDialog = false;
  UserFilterTab _selectedFilter = UserFilterTab.all;

  Map<String, String>? _activeUserData;

  final List<Map<String, String>> _users = [
    {"username": "alex_commander", "role": "Admin", "id": "USR-9921", "email": "alex.smith@pixelrank.ai", "status": "online"},
    {"username": "luna_gamer", "role": "Moderator", "id": "USR-8842", "email": "luna.dev@gaming.com", "status": "away"},
    {"username": "pixel_pro", "role": "User", "id": "USR-7751", "email": "contact@pixelpro.net", "status": "offline"},
    {"username": "shadow_striker", "role": "User", "id": "USR-6630", "email": "striker.game@web.de", "status": "online"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserManagementScreen.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 16),
                      _buildFilterChipsRow(),
                      const SizedBox(height: 20),
                      _buildSortAndResultsHeader(),
                      const SizedBox(height: 12),
                      _buildUserListView(),
                      const SizedBox(height: 24),
                      _buildLoadingIndicator(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_showDetailDialog && _activeUserData != null)
            _buildUserDetailDialog(),

          if (_showCreateModal)
            _buildCreateUserModal(),
        ],
      ),
      floatingActionButton: _showCreateModal || _showDetailDialog
          ? null
          : FloatingActionButton(
        onPressed: () => setState(() => _showCreateModal = true),
        backgroundColor: UserManagementScreen.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: UserManagementScreen.darkText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "User Management",
        style: TextStyle(color: UserManagementScreen.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: UserManagementScreen.darkText),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search by username, ID or email...",
          hintStyle: TextStyle(color: UserManagementScreen.secondaryText, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: UserManagementScreen.secondaryText, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: UserFilterTab.values.map((tab) {
          final isSelected = _selectedFilter == tab;
          String label = "All Users";
          if (tab == UserFilterTab.admins) label = "Admins";
          if (tab == UserFilterTab.moderators) label = "Moderators";
          if (tab == UserFilterTab.online) label = "Online";

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = tab),
              selectedColor: UserManagementScreen.primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : UserManagementScreen.darkText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSortAndResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: UserManagementScreen.darkText, fontSize: 14, fontWeight: FontWeight.bold),
            children: [
              const TextSpan(text: "Total Results "),
              TextSpan(text: "(${_users.length * 10 + 2})", style: const TextStyle(color: UserManagementScreen.primaryBlue)),
            ],
          ),
        ),
        Row(
          children: const [
            Text("Sort: ", style: TextStyle(color: UserManagementScreen.secondaryText, fontSize: 13)),
            Text("Newest", style: TextStyle(color: UserManagementScreen.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_drop_down, color: UserManagementScreen.primaryBlue, size: 20),
          ],
        )
      ],
    );
  }

  Widget _buildUserListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = _users[index];
        Color statusColor = Colors.grey;
        if (item["status"] == "online") statusColor = Colors.green;
        if (item["status"] == "away") statusColor = Colors.orange;

        Color roleColor = UserManagementScreen.primaryBlue;
        if (item["role"] == "Moderator") roleColor = Colors.purpleAccent;
        if (item["role"] == "User") roleColor = Colors.green;

        return GestureDetector(
          onTap: () => setState(() {
            _activeUserData = item;
            _showDetailDialog = true;
          }),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(item["username"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: UserManagementScreen.darkText)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(item["role"]!, style: TextStyle(color: roleColor, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text("ID: ${item["id"]!}", style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(item["email"]!, style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        children: [
          // FIXED: Removed const from parent container list as Indicator has no const constructor 👇
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: UserManagementScreen.primaryBlue),
          ),
          const SizedBox(height: 12),
          Text("Loading more users...", style: TextStyle(color: UserManagementScreen.secondaryText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildUserDetailDialog() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(image: NetworkImage("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100"), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 14,
                        height: 14,
                        // FIXED: Replaced invalid const factory setup with standard definition 👇
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_activeUserData!["username"]!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: UserManagementScreen.darkText)),
                      const SizedBox(height: 2),
                      Text("ID: ${_activeUserData!["id"]!}", style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Text(_activeUserData!["role"]!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 18, color: UserManagementScreen.secondaryText),
                const SizedBox(width: 10),
                Text(_activeUserData!["email"]!, style: const TextStyle(color: UserManagementScreen.darkText, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("ACTIVE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text("Edit", style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade200), foregroundColor: UserManagementScreen.darkText, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showDetailDialog = false),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text("Delete", style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade200), foregroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _showDetailDialog = false),
              child: const Text("Close Window", style: TextStyle(color: UserManagementScreen.secondaryText, fontSize: 13, fontWeight: FontWeight.w500)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCreateUserModal() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          // FIXED: Removed invalid const array flag due to dynamic non-const text inputs 👇
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text("Create New User", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: UserManagementScreen.primaryBlue)),
                GestureDetector(onTap: () => setState(() => _showCreateModal = false), child: const Icon(Icons.close, color: UserManagementScreen.darkText)),
              ],
            ),
            const SizedBox(height: 6),
            const Text("Onboard a new analyst or administrator to the AI system.", style: TextStyle(color: UserManagementScreen.secondaryText, fontSize: 13)),
            const SizedBox(height: 24),

            const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "e.g. John Doe",
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "john@ranklens.ai",
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 16),

            const Text("Account Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildRoleSelectorCard("Admin", "Full access", true)),
                const SizedBox(width: 16),
                Expanded(child: _buildRoleSelectorCard("User", "Analysis only", false)),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => setState(() => _showCreateModal = false),
                style: ElevatedButton.styleFrom(backgroundColor: UserManagementScreen.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                child: const Text("Confirm & Create Account", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => setState(() => _showCreateModal = false),
                child: const Text("Cancel", style: TextStyle(color: UserManagementScreen.secondaryText, fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelectorCard(String title, String desc, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? UserManagementScreen.primaryBlue : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Icon(title == "Admin" ? Icons.verified_user_outlined : Icons.person_outline, color: isSelected ? UserManagementScreen.primaryBlue : UserManagementScreen.secondaryText),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}