import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mo/API/api.dart';
import 'package:mo/features/mock_data/login-mock-data.dart';

class GameManagementScreen extends StatefulWidget {
  const GameManagementScreen({super.key});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  State<GameManagementScreen> createState() => _GameManagementScreenState();
}

class _GameManagementScreenState extends State<GameManagementScreen> {
  bool _showCreateModal = false;
  bool _showEditDialog = false;
  String _selectedCategoryFilter = "All";
  String _searchQuery = "";

  List<GameModel> _games = [];
  bool _isLoading = true;
  String _errorMessage = "";

  GameModel? _activeGameData;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String _selectedCategory = "RPG";

  String? _selectedLocalImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchGames();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  Future<void> _fetchGames() async {
    setState(() {
      _isLoading = true;
      _errorMessage = "";
    });
    try {
      final games = await ApiService.getGames();
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _pickLocalImageFile() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedLocalImagePath = pickedFile.path;
      });
    }
  }

  void _prepareEditForm(GameModel game) {
    _titleController.text = game.title;
    _descController.text = game.description;
    _companyController.text = game.companyName;
    _selectedLocalImagePath = game.imageUrl;
    _selectedCategory = game.category;
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _companyController.clear();
    _selectedLocalImagePath = null;
    _selectedCategory = "RPG";
  }

  Future<void> _createGame() async {
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();
    final category = _selectedCategory;

    if (title.isEmpty || company.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Publisher cannot be empty.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showCreateModal = false;
    });

    try {
      await ApiService.createGame(title, category, company);
      _fetchGames();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game registered successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to register game: $e")),
        );
      }
    }
  }

  Future<void> _updateGame() async {
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();
    final category = _selectedCategory;

    if (title.isEmpty || company.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Title and Publisher cannot be empty.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _showEditDialog = false;
    });

    try {
      await ApiService.updateGame(_activeGameData!.gameId, title, category, company);
      _fetchGames();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game configuration updated successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update game: $e")),
        );
      }
    }
  }

  Future<void> _deleteGame(GameModel game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Game"),
        content: Text("Are you sure you want to delete '${game.title}'?"),
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
    });

    try {
      await ApiService.deleteGame(game.gameId);
      _fetchGames();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Game deleted successfully!")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete game: $e")),
        );
      }
    }
  }

  List<GameModel> _getFilteredGames() {
    return _games.where((game) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = game.title.toLowerCase().contains(query);
        final matchesCompany = game.companyName.toLowerCase().contains(query);
        if (!matchesTitle && !matchesCompany) {
          return false;
        }
      }

      if (_selectedCategoryFilter != "All") {
        return game.category.toUpperCase() == _selectedCategoryFilter.toUpperCase();
      }

      return true;
    }).toList();
  }

  Widget _buildGameImageWidget(String imagePath, {required double width, required double height}) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, width: width, height: height, child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      return Image.file(
        File(imagePath),
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, width: width, height: height, child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = _getFilteredGames();

    return Scaffold(
      backgroundColor: GameManagementScreen.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchGames,
                  color: GameManagementScreen.primaryBlue,
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
                        _buildResultsHeader(filteredGames.length),
                        const SizedBox(height: 12),
                        if (_isLoading && _games.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: CircularProgressIndicator(color: GameManagementScreen.primaryBlue)),
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
                                    onPressed: _fetchGames,
                                    child: const Text("Retry"),
                                  )
                                ],
                              ),
                            ),
                          )
                        else if (filteredGames.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
                            child: Center(child: Text("No games found.", style: TextStyle(color: GameManagementScreen.secondaryText))),
                          )
                        else
                          _buildGameListView(filteredGames),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (_showEditDialog && _activeGameData != null)
            _buildEditGameDialog(),

          if (_showCreateModal)
            _buildCreateGameModal(),
        ],
      ),
      floatingActionButton: _showCreateModal || _showEditDialog
          ? null
          : FloatingActionButton(
              onPressed: () {
                _clearForm();
                setState(() => _showCreateModal = true);
              },
              backgroundColor: GameManagementScreen.primaryBlue,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_moderator_outlined, color: Colors.white, size: 24),
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: GameManagementScreen.darkText, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Game Library Management",
        style: TextStyle(color: GameManagementScreen.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
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
          hintText: "Search active titles, genre tags or publishers...",
          hintStyle: TextStyle(color: GameManagementScreen.secondaryText, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: GameManagementScreen.secondaryText, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChipsRow() {
    final categories = ["All", "RPG", "FPS", "MOBA"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategoryFilter == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategoryFilter = cat),
              selectedColor: GameManagementScreen.primaryBlue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : GameManagementScreen.darkText,
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

  Widget _buildResultsHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: GameManagementScreen.darkText, fontSize: 14, fontWeight: FontWeight.bold),
            children: [
              const TextSpan(text: "Total Games "),
              TextSpan(text: "($count)", style: const TextStyle(color: GameManagementScreen.primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameListView(List<GameModel> gamesList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gamesList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = gamesList[index];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _buildGameImageWidget(item.imageUrl, width: 64, height: 64),
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
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: GameManagementScreen.darkText),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                          child: Text(item.category, style: const TextStyle(color: GameManagementScreen.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GameManagementScreen.secondaryText, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("Publisher: ${item.companyName}", style: TextStyle(color: GameManagementScreen.primaryBlue.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_note_outlined, color: GameManagementScreen.primaryBlue, size: 24),
                    onPressed: () => setState(() {
                      _activeGameData = item;
                      _prepareEditForm(item);
                      _showEditDialog = true;
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    onPressed: () => _deleteGame(item),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditGameDialog() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Game Configuration", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: GameManagementScreen.darkText)),
              const SizedBox(height: 16),

              const Text("Display Showcase Cover (Tap image to browse gallery)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: GameManagementScreen.secondaryText)),
              const SizedBox(height: 6),

              GestureDetector(
                onTap: _pickLocalImageFile,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      _selectedLocalImagePath == null
                          ? Container(color: Colors.grey.shade200, height: 130, width: double.infinity, child: const Icon(Icons.image, size: 40))
                          : _buildGameImageWidget(_selectedLocalImagePath!, width: double.infinity, height: 130),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.35),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.photo_library_outlined, color: Colors.white, size: 26),
                                SizedBox(height: 4),
                                Text("Change Photo File", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Game Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GameManagementScreen.darkText)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),

              const Text("Publisher / Company", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GameManagementScreen.darkText)),
              const SizedBox(height: 6),
              TextField(
                controller: _companyController,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),

              const Text("Category Genre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GameManagementScreen.darkText)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ["RPG", "FPS", "MOBA"].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showEditDialog = false),
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateGame,
                      style: ElevatedButton.styleFrom(backgroundColor: GameManagementScreen.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text("Save Edits"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGameModal() {
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
                  const Text("Onboard New Game Asset", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: GameManagementScreen.primaryBlue)),
                  GestureDetector(onTap: () => setState(() => _showCreateModal = false), child: const Icon(Icons.close, color: GameManagementScreen.darkText)),
                ],
              ),
              const SizedBox(height: 20),

              const Text("Game Asset Title", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: GameManagementScreen.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: "e.g. Valorant, Cyberpunk...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Publisher / Company", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: GameManagementScreen.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _companyController,
                decoration: InputDecoration(
                  hintText: "e.g. Riot Games, CD Projekt...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              const Text("Category Genre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: GameManagementScreen.darkText)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ["RPG", "FPS", "MOBA"].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),

              const Text("Cover Configuration File", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: GameManagementScreen.darkText)),
              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: _pickLocalImageFile,
                icon: Icon(Icons.upload_file_outlined, color: _selectedLocalImagePath != null ? Colors.green : GameManagementScreen.primaryBlue),
                label: Text(
                  _selectedLocalImagePath == null ? "Select Image File From Gallery" : "Image File Selected Successfully",
                  style: TextStyle(color: _selectedLocalImagePath != null ? Colors.green : GameManagementScreen.primaryBlue, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: _selectedLocalImagePath != null ? Colors.green : GameManagementScreen.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (_selectedLocalImagePath != null) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_selectedLocalImagePath!), height: 80, width: double.infinity, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _createGame,
                  style: ElevatedButton.styleFrom(backgroundColor: GameManagementScreen.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  child: const Text("Confirm & Register Game Title", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}