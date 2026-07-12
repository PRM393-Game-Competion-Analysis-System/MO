import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';

enum UserFilterTab { all, admins, users }

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
  String _searchQuery = "";

  List<ApiUserModel> _users = [];
  bool _isLoading = true;
  String _errorMessage = "";

  ApiUserModel? _activeUserData;

  // Controllers for creation modal
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = "user"; // "admin" or "user"

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _createUser() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _selectedRole;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.createUser(username, email, password, role);
      setState(() {
        _showCreateModal = false;
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
      });
      _fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User created successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create user: $e")),
        );
      }
    }
  }

  Future<void> _deleteUser(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _showDetailDialog = false;
    });

    try {
      await ApiService.deleteUser(id);
      _fetchUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete user: $e")),
        );
      }
    }
  }

  List<ApiUserModel> _getFilteredUsers() {
    return _users.where((user) {
      // 1. Search Query Filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesUsername = user.username.toLowerCase().contains(query);
        final matchesEmail = user.email.toLowerCase().contains(query);
        final matchesId = user.userId.toString().contains(query);
        if (!matchesUsername && !matchesEmail && !matchesId) {
          return false;
        }
      }

      // 2. Tab Filter
      if (_selectedFilter == UserFilterTab.admins) {
        return user.role.toLowerCase() == 'admin';
      } else if (_selectedFilter == UserFilterTab.users) {
        return user.role.toLowerCase() == 'user';
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      backgroundColor: UserManagementScreen.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchUsers,
                  color: UserManagementScreen.primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildFilterChipsRow(),
                        const SizedBox(height: 20),
                        _buildSortAndResultsHeader(filteredUsers.length),
                        const SizedBox(height: 12),
                        if (_isLoading && _users.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: CircularProgressIndicator(color: UserManagementScreen.primaryBlue)),
                          )
                        else if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Text("Error: $_errorMessage", style: const TextStyle(color: Colors.redAccent)),
                                  const SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: _fetchUsers,
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          )
                        else if (filteredUsers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: Text("No users found.", style: TextStyle(color: UserManagementScreen.secondaryText))),
                          )
                        else
                          _buildUserListView(filteredUsers),
                        const SizedBox(height: 24),
                        if (_isLoading && _users.isNotEmpty) _buildLoadingIndicator(),
                        const SizedBox(height: 80),
                      ],
                    ),
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
              onPressed: () => setState(() {
                _usernameController.clear();
                _emailController.clear();
                _passwordController.clear();
                _selectedRole = "user";
                _showCreateModal = true;
              }),
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
      child: TextField(
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: const InputDecoration(
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
    return Row(
      children: UserFilterTab.values.map((tab) {
        final isSelected = _selectedFilter == tab;
        String label = "All Users";
        if (tab == UserFilterTab.admins) label = "Admins";
        if (tab == UserFilterTab.users) label = "Users";

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
    );
  }

  Widget _buildSortAndResultsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: UserManagementScreen.darkText, fontSize: 14, fontWeight: FontWeight.bold),
            children: [
              const TextSpan(text: "Total Results "),
              TextSpan(text: "($count)", style: const TextStyle(color: UserManagementScreen.primaryBlue)),
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

  Widget _buildUserListView(List<ApiUserModel> usersList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: usersList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = usersList[index];
        final bool isAdmin = item.role.toLowerCase() == 'admin';
        final Color roleColor = isAdmin ? UserManagementScreen.primaryBlue : Colors.green;

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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            isAdmin
                                ? "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200"
                                : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200",
                          ),
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
                          color: Colors.green,
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
                          Expanded(
                            child: Text(
                              item.username,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: UserManagementScreen.darkText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: roleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(item.role.toUpperCase(), style: TextStyle(color: roleColor, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text("ID: USR-${item.userId}", style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(item.email, style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                  onPressed: () => _deleteUser(item.userId),
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
    final bool isAdmin = _activeUserData!.role.toLowerCase() == 'admin';

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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            isAdmin
                                ? "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200"
                                : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 14,
                        height: 14,
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
                      Text(_activeUserData!.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: UserManagementScreen.darkText)),
                      const SizedBox(height: 2),
                      Text("ID: USR-${_activeUserData!.userId}", style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: isAdmin ? UserManagementScreen.primaryBlue : Colors.green, borderRadius: BorderRadius.circular(8)),
                  child: Text(_activeUserData!.role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.email_outlined, size: 18, color: UserManagementScreen.secondaryText),
                const SizedBox(width: 10),
                Text(_activeUserData!.email, style: const TextStyle(color: UserManagementScreen.darkText, fontSize: 14)),
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
                      onPressed: () => _deleteUser(_activeUserData!.userId),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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

              const Text("Username", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: "e.g. johndoe",
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Email Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "john@ranklens-ai.com",
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "••••••••",
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Account Role", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = "admin"),
                      child: _buildRoleSelectorCard("Admin", "Full access", _selectedRole == "admin"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedRole = "user"),
                      child: _buildRoleSelectorCard("User", "Analysis only", _selectedRole == "user"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _createUser,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UserManagementScreen.darkText)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(color: UserManagementScreen.secondaryText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}