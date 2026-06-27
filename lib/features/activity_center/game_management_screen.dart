import 'dart:io'; // Required for File manipulation
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Required for Local File Uploads

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

  Map<String, String>? _activeGameData;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String _selectedCategory = "RPG";

  // Track selected local image path instead of a text URL controller
  String? _selectedLocalImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  final List<Map<String, String>> _games = [
    {
      "id": "GM-1021",
      "title": "Genshin Impact",
      "category": "RPG",
      "playersCount": "12.4M",
      "imageUrl": "https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=500",
      "description": "An open-world action RPG with anime aesthetics and elemental magic systems."
    },
    {
      "id": "GM-8842",
      "title": "Apex Legends",
      "category": "FPS",
      "playersCount": "8.2M",
      "imageUrl": "https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600",
      "description": "A fast-paced heroic battle royale game focused on squad tactics and skills."
    },
    {
      "id": "GM-7751",
      "title": "League of Legends",
      "category": "MOBA",
      "playersCount": "32.1M",
      "imageUrl": "https://images.unsplash.com/photo-1560253023-3ec5d502959f?q=80&w=500",
      "description": "The definitive strategic multiplayer online battle arena team combat game."
    }
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // Native Photo Gallery Picker Integration 🎯
  Future<void> _pickLocalImageFile() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Optimized compression
    );
    if (pickedFile != null) {
      setState(() {
        _selectedLocalImagePath = pickedFile.path;
      });
    }
  }

  void _prepareEditForm(Map<String, String> game) {
    _titleController.text = game["title"]!;
    _descController.text = game["description"]!;
    _selectedLocalImagePath = game["imageUrl"]!;
    _selectedCategory = game["category"]!;
  }

  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _selectedLocalImagePath = null;
    _selectedCategory = "RPG";
  }

  // Dynamic Image Renderer Helper (Handles both web URLs and local device files safely) 🎯
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
    return Scaffold(
      backgroundColor: GameManagementScreen.bgColor,
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
                      _buildResultsHeader(),
                      const SizedBox(height: 12),
                      _buildGameListView(),
                      const SizedBox(height: 80),
                    ],
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search active titles, genre tags or identifiers...",
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

  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(color: GameManagementScreen.darkText, fontSize: 14, fontWeight: FontWeight.bold),
            children: [
              const TextSpan(text: "Total Games "),
              TextSpan(text: "(${_games.length})", style: const TextStyle(color: GameManagementScreen.primaryBlue)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGameListView() {
    final filteredGames = _selectedCategoryFilter == "All"
        ? _games
        : _games.where((g) => g["category"] == _selectedCategoryFilter).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredGames.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filteredGames[index];

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
                // Optimized list view rendering using dynamic handler
                child: _buildGameImageWidget(item["imageUrl"]!, width: 64, height: 64),
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
                            item["title"]!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: GameManagementScreen.darkText),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(6)),
                          child: Text(item["category"]!, style: const TextStyle(color: GameManagementScreen.primaryBlue, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item["description"]!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: GameManagementScreen.secondaryText, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text("Pool: ${item["playersCount"]!} active profiles", style: TextStyle(color: GameManagementScreen.primaryBlue.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w500)),
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
                    onPressed: () => setState(() => _games.remove(item)),
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

              // Optimized tap container with integrated native image picking logic 📸
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

              const Text("Core Genre Description Log", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: GameManagementScreen.darkText)),
              const SizedBox(height: 6),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
                      onPressed: () {
                        setState(() {
                          _activeGameData!["title"] = _titleController.text;
                          _activeGameData!["description"] = _descController.text;
                          if (_selectedLocalImagePath != null) {
                            _activeGameData!["imageUrl"] = _selectedLocalImagePath!;
                          }
                          _showEditDialog = false;
                        });
                      },
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

              // Local file picker container button instead of an un-intuitive URL string field 🎯
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
              const SizedBox(height: 16),

              const Text("Strategic Overview Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: GameManagementScreen.darkText)),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Brief summary of core mechanics and metrics tracking rules...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      setState(() {
                        _games.add({
                          "id": "GM-${_games.length * 13 + 1200}",
                          "title": _titleController.text,
                          "category": _selectedCategory,
                          "playersCount": "1.0M",
                          "imageUrl": _selectedLocalImagePath ?? "https://images.unsplash.com/photo-1550745165-9bc0b252726f?q=80&w=500",
                          "description": _descController.text.isEmpty ? "No descriptive overview provided yet." : _descController.text
                        });
                        _showCreateModal = false;
                      });
                    }
                  },
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