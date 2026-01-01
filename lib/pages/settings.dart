import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/pages/settings_language.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/pages/settings_about.dart';

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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // Começamos direto com as opções de suporte e ajustes
          _buildSettingsTile(
            title: 'Get Help with the App',
            onTap: () {
              // Ação para ajuda
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildSettingsTile(
            title: 'App Settings',
            onTap: () {
              // Ação para configurações internas
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildSettingsTile(
            title: 'Language',
            onTap: () {
              // NAVEGAÇÃO PARA A PÁGINA DE SELEÇÃO DE IDIOMA
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LanguagePage()),
              );
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildSettingsTile(
            title: 'About Out Vision',
            onTap: () {
                  // NAVEGAÇÃO PARA A PÁGINA "ABOUT OUTVISION"
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          // Itens com ícone de link externo (Imprint, Privacy, Terms)
          _buildSettingsTile(
            title: 'Imprint',
            isExternal: true,
            onTap: () {
              // Abrir link externo
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildSettingsTile(
            title: 'Privacy Policy',
            isExternal: true,
            onTap: () {
              // Abrir link externo
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          
          _buildSettingsTile(
            title: 'Terms of Use',
            isExternal: true,
            onTap: () {
              // Abrir link externo
            },
          ),
          
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
      bottomNavigationBar: bottomNavBar(context,3),
    );
  }

  // Widget auxiliar para construir as linhas de configuração
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