import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/pages/settings/settings_language.dart';
import 'package:outvisionxr/pages/settings/settings_about.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cor cinza mais clara para os containers, conforme a imagem
    final Color groupColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        // O título foi removido daqui para ficar abaixo da seta no body
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título Settings abaixo da seta de voltar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              t.settings.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18, // Tamanho maior fiel à imagem
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 30), // Espaço para não ficar muito em cima
                _buildSettingsGroup(
                  groupColor,
                  [
                    _tile(
                      icon: Icons.help_outline,
                      iconBackgroundColor: Colors.blue,
                      title: context.t.settings.getHelp,
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    _tile(
                      icon: Icons.language,
                      iconBackgroundColor: Colors.green,
                      title: context.t.settings.language,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LanguagePage()),
                        );
                      },
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    _tile(
                      icon: Icons.info_outline,
                      iconBackgroundColor: Colors.orange,
                      title: context.t.settings.about,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AboutPage()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSettingsGroup(
                  groupColor,
                  [
                    _tile(
                      icon: Icons.article_outlined,
                      iconBackgroundColor: Colors.grey,
                      title: context.t.settings.imprint,
                      isExternal: true,
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    _tile(
                      icon: Icons.shield_outlined,
                      iconBackgroundColor: Colors.indigo,
                      title: context.t.settings.privacyPolicy,
                      isExternal: true,
                      onTap: () {},
                    ),
                    Divider(height: 1, color: Colors.grey[300]),
                    _tile(
                      icon: Icons.gavel_outlined,
                      iconBackgroundColor: Colors.brown,
                      title: context.t.settings.termsOfUse,
                      isExternal: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Texto de rodapé fiel à imagem
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Center(
              child: Text(
                "v1.0.0", // Na primeira versão, você começa aqui
                style: TextStyle(
                  color: Colors.grey[400], // Bem clarinho para não distrair
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(Color color, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(children: children),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconBackgroundColor,
    required String title,
    required VoidCallback onTap,
    bool isExternal = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              isExternal ? Icons.open_in_new : Icons.arrow_forward_ios,
              size: 14, // Seta um pouco menor para delicadeza visual
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}