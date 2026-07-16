import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../upload_and_analyze_screen.dart';

class VisualStateCard extends StatelessWidget {
  final AnalyzeStep currentStep;
  final XFile? pickedImage;
  final VoidCallback onUploadTriggered;
  final VoidCallback onClearTriggered;
  final VoidCallback onReAnalyzeTriggered;
  final String gameTitle;
  final String selectedServerName;
  final double? analysisDuration;

  const VisualStateCard({
    super.key,
    required this.currentStep,
    required this.pickedImage,
    required this.onUploadTriggered,
    required this.onClearTriggered,
    required this.onReAnalyzeTriggered,
    required this.gameTitle,
    required this.selectedServerName,
    this.analysisDuration,
  });

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
      case AnalyzeStep.empty:
        return GestureDetector(
          onTap: onUploadTriggered,
          child: Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primaryBlue.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.file_upload_outlined, color: primaryBlue, size: 32),
                SizedBox(height: 8),
                Text("Upload images", style: TextStyle(color: secondaryText, fontSize: 13)),
              ],
            ),
          ),
        );

      case AnalyzeStep.imageUploaded:
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: pickedImage != null
                      ? DecorationImage(
                          image: FileImage(File(pickedImage!.path)),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600"),
                          fit: BoxFit.cover,
                        ),
                ),
                child: Container(
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(pickedImage != null ? pickedImage!.name : "game_snap_042.png", style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text("$gameTitle • $selectedServerName", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: onClearTriggered,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );

      case AnalyzeStep.processing:
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              image: pickedImage != null
                  ? DecorationImage(
                      image: FileImage(File(pickedImage!.path)),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600"),
                      fit: BoxFit.cover,
                    ),
            ),
            child: Container(
              color: primaryBlue.withValues(alpha: 0.8),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  SizedBox(height: 16),
                  Text("Processing Screenshot...", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 4),
                  Text("Identifying player ranks and scores", style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ),
        );

      case AnalyzeStep.result:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ANALYSIS COMPLETE", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.5)),
                        SizedBox(height: 4),
                        Text("PixelRank High Precision", style: TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 18), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("98.4%", style: TextStyle(color: primaryBlue, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("CONFIDENCE", style: TextStyle(color: Colors.grey.shade500, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildResultMetaBox(Icons.memory, "AI MODEL", "PaddleOCR"),
                  const SizedBox(width: 8),
                  _buildResultMetaBox(
                    Icons.access_time,
                    "DURATION",
                    analysisDuration != null ? "${(analysisDuration! / 1000).toStringAsFixed(1)}s" : "1.4s",
                  ),
                  const SizedBox(width: 8),
                  _buildResultMetaBox(Icons.emoji_events_outlined, "PLAYERS", "Verified"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: onReAnalyzeTriggered,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text("Re-Analyze", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: const Icon(Icons.ios_share, color: darkText, size: 20),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }

  Widget _buildResultMetaBox(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, size: 18, color: primaryBlue),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 9, color: secondaryText, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}