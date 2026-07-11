import 'package:flutter/material.dart';
import 'package:mo/API/api.dart';

class ServerSelectionModal extends StatelessWidget {
  final String currentSelected;
  final ValueChanged<String> onServerConfirmed;
  final VoidCallback onClose;
  final List<ServerModel> servers;

  const ServerSelectionModal({
    super.key,
    required this.currentSelected,
    required this.onServerConfirmed,
    required this.onClose,
    required this.servers,
  });

  static const Color primaryBlue = Color(0xFF1129A4);
  static const Color darkText = Color(0xFF1A1D20);
  static const Color secondaryText = Color(0xFF6C757D);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                const Text("Server", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryBlue)),
                GestureDetector(onTap: onClose, child: const Icon(Icons.close, color: darkText)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("AVAILABLE SERVERS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: secondaryText)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    "${servers.length} Servers",
                    style: const TextStyle(color: secondaryText, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: servers.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Text("No servers available for this game.", style: TextStyle(color: secondaryText)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: servers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final server = servers[index];
                        final isSelected = server.serverName == currentSelected;
                        final isHighLatency = server.status == 'busy';
                        final ping = isHighLatency ? "High" : "Low";
                        final dotColor = server.status == 'active' ? Colors.green : Colors.grey;

                        return GestureDetector(
                          onTap: () => onServerConfirmed(server.serverName),
                          child: _buildServerListItem(
                            server.serverName,
                            server.region.isNotEmpty ? server.region : "Global",
                            server.status,
                            ping,
                            isSelected,
                            dotColor,
                            isHighLatency: isHighLatency,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: primaryBlue, borderRadius: BorderRadius.circular(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("SELECTED SERVICE", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          currentSelected,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: currentSelected == "------" || currentSelected.isEmpty
                        ? null
                        : () => onServerConfirmed(currentSelected),
                    child: const Row(
                      children: [
                        Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(width: 6),
                        Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onClose,
              child: const Text("Cancel", style: TextStyle(color: secondaryText, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerListItem(String title, String location, String status, String ping, bool isSelected, Color dotColor, {bool isHighLatency = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? primaryBlue : Colors.grey.shade100, width: isSelected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isSelected ? primaryBlue : const Color(0xFFF1F3F5), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.dns_outlined, color: isSelected ? Colors.white : secondaryText, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.public, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text("$location  •  ", style: const TextStyle(color: secondaryText, fontSize: 11)),
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(status, style: TextStyle(color: isHighLatency ? Colors.redAccent : secondaryText, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          if (isHighLatency)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8)), child: const Text("High", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
          else
            Row(
              children: [
                Icon(Icons.bar_chart, size: 14, color: isSelected ? primaryBlue : Colors.grey),
                const SizedBox(width: 4),
                Text(ping, style: TextStyle(fontSize: 12, color: isSelected ? primaryBlue : secondaryText, fontWeight: FontWeight.bold)),
              ],
            ),
          if (isSelected) ...[const SizedBox(width: 12), const Icon(Icons.check_circle, color: primaryBlue, size: 20)],
        ],
      ),
    );
  }
}