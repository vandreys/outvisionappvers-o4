import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/pages/settings/settings_language.dart';
import 'package:outvisionxr/pages/settings/settings_about.dart';
import 'package:outvisionxr/pages/settings/settings_about_app.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cor cinza mais clara para os containers, conforme a imagem
    const Color groupColor = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        // O título foi removido daqui para ficar abaixo da seta no body
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 600;
          final horizontalPadding = isTablet ? constraints.maxWidth * 0.1 : 16.0;
          final titleSize = isTablet ? 26.0 : 18.0;
          final tileVerticalPadding = isTablet ? 16.0 : 10.0;
          final iconSize = isTablet ? 24.0 : 20.0;
          final iconPadding = isTablet ? 10.0 : 6.0;
          final fontSize = isTablet ? 18.0 : 16.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding + 8, vertical: 8),
                child: Text(
                  t.settings.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleSize,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  children: [
                    const SizedBox(height: 30),
                    _buildSettingsGroup(
                      groupColor,
                      [
                        _tile(
                          icon: Icons.help_outline,
                          iconBackgroundColor: Colors.blue,
                          title: context.t.settings.getHelp,
                          onTap: () {},
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
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
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
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
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _tile(
                          icon: Icons.app_settings_alt,
                          iconBackgroundColor: Colors.red,
                          title: context.t.settings.aboutApp,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AboutAppPage()),
                            );
                          },
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSettingsGroup(
                      groupColor,
                      [
                        _tile(
                          icon: Icons.public,
                          iconBackgroundColor: Colors.grey,
                          title: context.t.settings.website,
                          isExternal: true,
                          onTap: () {},
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _tile(
                          icon: Icons.shield_outlined,
                          iconBackgroundColor: Colors.indigo,
                          title: context.t.settings.privacyPolicy,
                          isExternal: true,
                          onTap: () {},
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
                        ),
                        Divider(height: 1, color: Colors.grey[300]),
                        _tile(
                          icon: Icons.gavel_outlined,
                          iconBackgroundColor: Colors.brown,
                          title: context.t.settings.termsOfUse,
                          isExternal: true,
                          onTap: () {},
                          verticalPadding: tileVerticalPadding,
                          iconSize: iconSize,
                          iconPadding: iconPadding,
                          fontSize: fontSize,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Center(
                  child: Text(
                    "v1.0.0",
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: isTablet ? 13 : 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
    double verticalPadding = 10,
    double iconSize = 20,
    double iconPadding = 6,
    double fontSize = 16,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPadding),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              isExternal ? Icons.open_in_new : Icons.arrow_forward_ios,
              size: 14,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}