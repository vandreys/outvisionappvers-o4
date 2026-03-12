import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/services/exhibition_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';

class ExhibitionsPage extends StatefulWidget {
  const ExhibitionsPage({super.key});

  @override
  State<ExhibitionsPage> createState() => _ExhibitionsPageState();
}

class _ExhibitionsPageState extends State<ExhibitionsPage> {
  final ExhibitionService _exhibitionService = ExhibitionService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              hintText: t.gallery.search,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              t.gallery.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _exhibitionService.getExhibitionsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 75),
                        const SizedBox(height: 5),
                        Text(
                          t.ar.errorTitle,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final exhibitions = snapshot.data!.where((exhibition) =>
                    exhibition["title"].toString().toLowerCase().contains(_query.toLowerCase()) ||
                    exhibition["artist"].toString().toLowerCase().contains(_query.toLowerCase())).toList();

                if (exhibitions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mood_bad, size: 75),
                        const SizedBox(height: 5),
                        const Text(
                          'Nenhuma exposição encontrada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: exhibitions.length,
                  itemBuilder: (context, index) {
                    return _buildExhibitionCard(exhibitions[index], context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: bottomNavBar(context, 1),
      ),
    );
  }

  Widget _buildExhibitionCard(Map<String, dynamic> exhibitionData, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGEM COM BADGE
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBE7),
                  borderRadius: BorderRadius.circular(5),
                  image: exhibitionData["imageUrl"] != null
                      ? DecorationImage(
                          image: NetworkImage(exhibitionData["imageUrl"]),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: exhibitionData["imageUrl"] == null
                    ? const Icon(Icons.image, size: 50, color: Colors.grey)
                    : null,
              ),
              // BADGE DE LOCALIZAÇÃO
              if (exhibitionData["location"] != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu, size: 14, color: Colors.grey[700]),
                        const SizedBox(width: 4),
                        Text(
                          exhibitionData["location"],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // TÍTULO DA OBRA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              exhibitionData["title"] ?? 'Título não disponível',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ARTISTA + ANO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  exhibitionData["artist"] ?? 'Artista desconhecido',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '·',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  exhibitionData["year"] ?? '2025',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // BOTÃO "View artwork"
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {
                // Navegação para detalhes da obra
              },
              child: Text(
                t.gallery.viewExhibition,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}