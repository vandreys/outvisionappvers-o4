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
    final String imageUrl = artworkData['imageUrl'] ?? ''; // URL da imagem da obra
    final String artworkName = artworkData['name'] ?? context.t.map.arrivedTitle; // Nome da obra

    return Material(
      color: Colors.white,
      elevation: 8, // Uma sombra sutil para destacar o card do mapa
      child: Stack( // Usamos Stack para posicionar o botão de fechar sobre o conteúdo
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Imagem da Obra (com tratamento de loading e erro)
              if (imageUrl.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Colors.black));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.grey, size: 48);
                    },
                  ),
                ),

              // 2. Conteúdo de Texto e Botão
              Padding(
                padding: const EdgeInsets.all(20.0),
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
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: onOpenAr,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      child: Text(context.t.map.openArButton),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 3. Botão de Fechar
          Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.6),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: onClose,
                tooltip: 'Fechar',
              ),
            ),
          ),
        ],
      ),
    );
  }
}