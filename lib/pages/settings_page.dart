import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/pages/settings/settings_language.dart';
import 'package:outvisionxr/pages/settings/settings_about.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// CONTEÚDO PRINCIPAL
          ListView(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 120),
            children: [
              _buildSettingsTile(
                title: t.settings.getHelp,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              _buildSettingsTile(
                title: t.settings.appSettings,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              _buildSettingsTile(
                title: t.settings.language,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguagePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              _buildSettingsTile(
                title: t.settings.about,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              _buildSettingsTile(
                title: t.settings.imprint,
                isExternal: true,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              _buildSettingsTile(
                title: t.settings.privacyPolicy,
                isExternal: true,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),

              _buildSettingsTile(
                title: t.settings.termsOfUse,
                isExternal: true,
                onTap: () {},
              ),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
            ],
          ),

          /// BOTTOM NAVIGATION FLUTUANTE (IGUAL AO EXPLORE)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: bottomNavBar(context, 3),
          ),
        ],
      ),
    );
  }

  /// ITEM DE CONFIGURAÇÃO
  Widget _buildSettingsTile({
    required String title,
    bool isExternal = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(
              isExternal ? Icons.open_in_new : Icons.arrow_forward_ios,
              size: 16,
              color: isExternal ? Colors.grey : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}
