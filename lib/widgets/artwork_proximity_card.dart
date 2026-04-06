import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class ArtworkProximityCard extends StatelessWidget {
  // Recebe os dados da obra (vindos do Firebase) e os callbacks de ação.
  final Map<String, dynamic> artworkData;
  final VoidCallback onOpenAr;
  final VoidCallback onClose;

  const ArtworkProximityCard({
    super.key,
    required this.artworkData,
    required this.onOpenAr,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Extrai os dados para facilitar a leitura, com valores padrão para segurança.
    final String artworkName = artworkData['name'] ?? context.t.map.arrivedTitle; // Nome da obra
    final String? artistName = artworkData['artist']; // Nome do artista (opcional)

    return Material(
      color: Colors.white,
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha: título chegou + botão fechar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.map.arrivedTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artworkName,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (artistName != null && artistName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          artistName,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onOpenAr,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: Text(context.t.map.openArButton),
            ),
          ],
        ),
      ),
    );
  }
}