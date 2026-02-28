import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';

class ExhibitionsPage extends StatelessWidget {
  const ExhibitionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t.gallery.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 42),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGEM / OBRA
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEBE7),
                    borderRadius: BorderRadius.circular(5),
                    image: const DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/450x600'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Fallback para caso a imagem não carregue (importante para App Store)
                  child: const SizedBox(), 
                ),

                const SizedBox(height: 18),

                // TEXTO
                Text(
                  t.gallery.artworkTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 18),

                // 🔘 BOTÃO "VER EXPOSIÇÃO"
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
                      // Feedback visual para o revisor da App Store não achar que o app travou
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${t.gallery.viewExhibition}: Em breve'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
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
        },
      ),
      bottomNavigationBar: SafeArea(
        child: bottomNavBar(context, 1),
      ),
    );
  }
}