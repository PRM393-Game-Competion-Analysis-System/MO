import 'package:flutter/material.dart';
import 'upload_analyze_flow/server_selection_modal.dart';
import 'upload_analyze_flow/visual_state_card.dart';
import 'upload_analyze_flow/pipeline_card.dart';
import 'upload_analyze_flow/ranking_list.dart';

enum AnalyzeStep { empty, imageUploaded, processing, result }

class UploadAndAnalyzeScreen extends StatefulWidget {
  const UploadAndAnalyzeScreen({super.key});

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
                  onUploadTriggered: () => setState(() => _currentStep = AnalyzeStep.imageUploaded),
                  onClearTriggered: () => setState(() => _currentStep = AnalyzeStep.empty),
                  onReAnalyzeTriggered: () => setState(() => _currentStep = AnalyzeStep.processing),
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
              Expanded(child: _buildSelectorCard(Icons.sports_esports_outlined, "TARGET GAME", "Genshin Impact")),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showServerModal = true),
                  child: _buildSelectorCard(Icons.description_outlined, "SERVER", _selectedServer),
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
              onPressed: _currentStep == AnalyzeStep.empty
                  ? null
                  : () async {
                setState(() => _currentStep = AnalyzeStep.processing);
                await Future.delayed(const Duration(seconds: 2));
                if (mounted) setState(() => _currentStep = AnalyzeStep.result);
              },
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
      return const RankingList();
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
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: UploadAndAnalyzeScreen.darkText)),
        ],
      ),
    );
  }
}