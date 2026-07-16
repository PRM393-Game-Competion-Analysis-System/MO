import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mo/API/api.dart';
import 'package:mo/features/mock_data/login-mock-data.dart';
import 'upload_analyze_flow/server_selection_modal.dart';
import 'upload_analyze_flow/visual_state_card.dart';
import 'upload_analyze_flow/pipeline_card.dart';
import 'upload_analyze_flow/ranking_list.dart';

enum AnalyzeStep { empty, imageUploaded, processing, result }

class UploadAndAnalyzeScreen extends StatefulWidget {
  final GameModel game;

  const UploadAndAnalyzeScreen({super.key, required this.game});

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color bgColor = Color(0xFFF8F9FA);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  State<UploadAndAnalyzeScreen> createState() => _UploadAndAnalyzeScreenState();
}

class _UploadAndAnalyzeScreenState extends State<UploadAndAnalyzeScreen> {
  AnalyzeStep _currentStep = AnalyzeStep.empty;
  String _selectedServer = "------";
  bool _showServerModal = false;
  XFile? _pickedImage;
  List<ServerModel> _matchingServers = [];
  bool _isLoadingServers = true;
  AnalysisResultModel? _analysisResult;
  double? _lastAnalysisDuration;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    try {
      final servers = await ApiService.getServers();
      if (mounted) {
        setState(() {
          _matchingServers = servers.where((server) {
            if (server.gameName.isEmpty) return true;
            return server.gameName.toLowerCase() == widget.game.title.toLowerCase();
          }).toList();
          if (_matchingServers.isNotEmpty) {
            _selectedServer = _matchingServers.first.serverName;
          }
          _isLoadingServers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServers = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load servers: $e")),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          _pickedImage = image;
          _currentStep = AnalyzeStep.imageUploaded;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to pick image: $e")),
        );
      }
    }
  }

  Future<void> _analyzeScreenshot() async {
    if (_pickedImage == null) return;

    setState(() {
      _currentStep = AnalyzeStep.processing;
      _lastAnalysisDuration = null;
    });

    try {
      final startTime = DateTime.now();

      // Step 1: Call OCR extraction
      final ocrResult = await ApiService.extractText(_pickedImage!.path);

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds.toDouble();

      if (ocrResult.fullText.isEmpty) {
        throw Exception("OCR returned no text content");
      }

      List<LeaderboardItem> parsedLeaderboard = [];
      try {
        final decoded = jsonDecode(ocrResult.fullText);
        if (decoded is List) {
          parsedLeaderboard = decoded.map((item) {
            if (item is Map<String, dynamic>) {
              final rank = int.tryParse(item['Hạng']?.toString() ?? '') ?? 0;
              final name = item['Tên']?.toString() ?? '';
              final guild = item['Bang Hội']?.toString() ?? '';
              final scoreStr = item['Lực Chiến']?.toString() ?? '0';
              final cleanScoreStr = scoreStr.replaceAll(RegExp(r'[^0-9]'), '');
              final score = int.tryParse(cleanScoreStr) ?? 0;

              return LeaderboardItem(
                rank: rank,
                playerName: name,
                guildName: guild,
                score: score,
                value: score,
              );
            }
            return LeaderboardItem(rank: 0, playerName: '', guildName: '', score: 0, value: 0);
          }).where((item) => item.playerName.isNotEmpty).toList();
        }
      } catch (e) {
        throw Exception("Failed to parse leaderboard from OCR: $e");
      }

      if (parsedLeaderboard.isEmpty) {
        throw Exception("No ranking rows could be detected in the image");
      }

      final result = AnalysisResultModel(
        analysisId: 0,
        imageUrl: _pickedImage?.path ?? '',
        processedTime: DateTime.now().toIso8601String(),
        gameName: widget.game.title,
        serverName: _selectedServer,
        eventName: 'OCR Leaderboard',
        leaderboard: parsedLeaderboard,
      );

      await LocalHistoryService.saveResult(result);

      if (mounted) {
        setState(() {
          _analysisResult = result;
          _lastAnalysisDuration = duration;
          _currentStep = AnalyzeStep.result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStep = AnalyzeStep.imageUploaded;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Analysis failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UploadAndAnalyzeScreen.bgColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (_currentStep != AnalyzeStep.result) ...[
                  const Text(
                    "CURRENT SELECTION",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: UploadAndAnalyzeScreen.secondaryText, letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 20),
                ],

                // 1. Render Central Box Widget safely
                VisualStateCard(
                  currentStep: _currentStep,
                  pickedImage: _pickedImage,
                  onUploadTriggered: _pickImage,
                  onClearTriggered: () => setState(() {
                    _pickedImage = null;
                    _currentStep = AnalyzeStep.empty;
                  }),
                  onReAnalyzeTriggered: _analyzeScreenshot,
                  gameTitle: widget.game.title,
                  selectedServerName: _selectedServer,
                  analysisDuration: _lastAnalysisDuration,
                ),
                const SizedBox(height: 24),

                // 2. Render Dynamic Control Bottom Form safely
                _buildFormArea(),
              ],
            ),
          ),

          // 3. Render Floating Modal Sheet safely
          if (_showServerModal)
            ServerSelectionModal(
              currentSelected: _selectedServer,
              onClose: () => setState(() => _showServerModal = false),
              servers: _matchingServers,
              onServerConfirmed: (String server) => setState(() {
                _selectedServer = server;
                _showServerModal = false;
              }),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = _currentStep == AnalyzeStep.result ? "Analyze Result" : "Upload & Analyze";
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: UploadAndAnalyzeScreen.darkText, size: 20),
        onPressed: () {
          if (_currentStep == AnalyzeStep.result) {
            setState(() => _currentStep = AnalyzeStep.empty);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        title,
        style: const TextStyle(color: UploadAndAnalyzeScreen.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        if (_currentStep == AnalyzeStep.result) ...[
          IconButton(icon: const Icon(Icons.share_outlined, color: UploadAndAnalyzeScreen.darkText), onPressed: () {}),
          IconButton(icon: const Icon(Icons.file_download_outlined, color: UploadAndAnalyzeScreen.darkText), onPressed: () {}),
        ] else
          IconButton(icon: const Icon(Icons.more_vert, color: UploadAndAnalyzeScreen.darkText), onPressed: () {}),
      ],
    );
  }

  Widget _buildFormArea() {
    if (_currentStep == AnalyzeStep.empty || _currentStep == AnalyzeStep.imageUploaded) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildSelectorCard(Icons.sports_esports_outlined, "TARGET GAME", widget.game.title)),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: _isLoadingServers
                      ? null
                      : () => setState(() => _showServerModal = true),
                  child: _buildSelectorCard(
                    Icons.description_outlined,
                    "SERVER",
                    _isLoadingServers ? "Loading..." : _selectedServer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFEEF2FF).withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: UploadAndAnalyzeScreen.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Pro Tip", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: UploadAndAnalyzeScreen.darkText)),
                      SizedBox(height: 2),
                      Text("Ensure the screenshot is clear and uncropped for the highest OCR accuracy.", style: TextStyle(color: UploadAndAnalyzeScreen.secondaryText, fontSize: 12, height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _currentStep == AnalyzeStep.empty ? null : _analyzeScreenshot,
              icon: const Icon(Icons.bolt, size: 20),
              label: const Text("Analyze Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: UploadAndAnalyzeScreen.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    } else if (_currentStep == AnalyzeStep.processing) {
      return PipelineCard(onClearAll: () => setState(() => _currentStep = AnalyzeStep.empty));
    } else {
      return RankingList(leaderboard: _analysisResult?.leaderboard ?? []);
    }
  }

  Widget _buildSelectorCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFF1F3F5).withValues(alpha: 0.7), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: UploadAndAnalyzeScreen.primaryBlue),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: UploadAndAnalyzeScreen.primaryBlue, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: UploadAndAnalyzeScreen.darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}