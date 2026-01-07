import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart'; // Para usar a fonte Montserrat

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.about.pageTitle,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Cor do texto do AppBar
          ),
        ),
        backgroundColor: Colors.white, // Fundo branco como no Wava
        elevation: 0, // Sem sombra no AppBar
        iconTheme: const IconThemeData(color: Colors.black), // Cor do ícone de voltar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagem/Logo Principal (se houver na foto)
            Center(
              child: Image.asset(
                'assets/images/outvision_logo.png', // Substitua pelo seu logo
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),

            // 2. Título Principal
            Text(t.about.mainTitle,
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Descrição Geral
            Text(t.about.pageTitle,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 4. Seção: Nossa Missão
            Text(t.about.missionTitle,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(t.about.missionText,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 5. Seção: Nossa Visão
            Text(t.about.visionTitle,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(t.about.visionText,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // 6. Seção: Conecte-se Conosco (Exemplo de ícones sociais)
            Text(t.about.connectTitle,
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _socialIcon(Icons.language, t.about.website),
                _socialIcon(Icons.mail_outline, t.about.email),
                _socialIcon(Icons.camera_alt_outlined, t.about.instagram), // Ícone para Instagram
                _socialIcon(Icons.share, t.about.share), // Ícone genérico
              ],
            ),
            const SizedBox(height: 32),

            // 7. Informações de Copyright/Versão
            Center(
              child: Text(t.about.copyright,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para os ícones sociais
  Widget _socialIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}