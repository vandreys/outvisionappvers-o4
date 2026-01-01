import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Para usar a fonte Montserrat

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sobre Outvision',
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
            Text(
              'Outvision XR: Arte e Realidade Aumentada',
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Descrição Geral
            Text(
              'Outvision XR é uma plataforma inovadora que redefine a experiência da arte, combinando o mundo físico com a imersão da Realidade Aumentada (RA). Desenvolvido para entusiastas da arte e visitantes de exposições como a Bienal de Curitiba, nosso aplicativo transforma a maneira como você interage com obras e artistas.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 4. Seção: Nossa Missão
            Text(
              'Nossa Missão',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Conectar pessoas à arte de maneiras inéditas, utilizando a tecnologia para enriquecer a compreensão e o engajamento com expressões culturais contemporâneas. Acreditamos que a RA pode quebrar barreiras e tornar a arte mais acessível e interativa para todos.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 5. Seção: Nossa Visão
            Text(
              'Nossa Visão',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ser a plataforma líder em curadoria de arte com Realidade Aumentada, reconhecida por sua inovação, acessibilidade e pela capacidade de criar experiências memoráveis que transcendem os limites tradicionais das galerias e museus.',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),

            // 6. Seção: Conecte-se Conosco (Exemplo de ícones sociais)
            Text(
              'Conecte-se Conosco',
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
                _socialIcon(Icons.language, 'Website'),
                _socialIcon(Icons.mail_outline, 'Email'),
                _socialIcon(Icons.camera_alt_outlined, 'Instagram'), // Ícone para Instagram
                _socialIcon(Icons.share, 'Compartilhar'), // Ícone genérico
              ],
            ),
            const SizedBox(height: 32),

            // 7. Informações de Copyright/Versão
            Center(
              child: Text(
                'Outvision XR © 2025. Todos os direitos reservados.',
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