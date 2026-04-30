import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static const _heroUrl =
      'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro%203.jpg?alt=media&token=12dd3951-c1fc-424d-84f8-e80b5cd64f73';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: false,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: _NavButton(
                icon: Icons.chevron_left,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _heroUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : Container(color: AppColors.bg2),
                errorBuilder: (context, _, __) =>
                    Container(color: AppColors.bg2),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(24),
              child: Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.bg,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('16ª Edição · 2026', style: AppText.caption()),
                  const SizedBox(height: 6),
                  Text(
                    'Bienal de\nCuritiba',
                    style: GoogleFonts.inter(
                      fontSize: Rsp.fs(context, 38),
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.1,
                      color: AppColors.fg,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 28),
                  Text('SOBRE O APP', style: AppText.label()),
                  const SizedBox(height: 12),
                  Text(
                    'O app da Bienal de Curitiba é sua porta de entrada para uma experiência artística que vai além do espaço físico da exposição. Desenvolvido especialmente para a 16ª edição, o aplicativo permite que você explore obras de arte em Realidade Aumentada — diretamente nos locais onde as obras estão instaladas.',
                    style: AppText.body(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Ao se aproximar de uma obra participante, o app reconhece sua localização e libera a experiência em AR. Apontando a câmera para o espaço ao redor, você vê a obra tomar vida em três dimensões — fundindo o digital com o mundo real.',
                    style: AppText.body(),
                  ),
                  const SizedBox(height: 32),
                  const _FeatureRow(
                    icon: Icons.view_in_ar,
                    title: 'Realidade Aumentada',
                    description:
                        'Visualize obras em 3D no espaço real, nos locais da Bienal.',
                  ),
                  const SizedBox(height: 16),
                  const _FeatureRow(
                    icon: Icons.map_outlined,
                    title: 'Mapa Interativo',
                    description:
                        'Navegue pelos pontos da exposição e encontre obras próximas.',
                  ),
                  const SizedBox(height: 16),
                  const _FeatureRow(
                    icon: Icons.person_outline,
                    title: 'Artistas',
                    description:
                        'Conheça a trajetória e a obra dos artistas participantes.',
                  ),
                  const SizedBox(height: 40),
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 32),
                  Text('DESENVOLVIDO POR', style: AppText.label()),
                  const SizedBox(height: 16),
                  Text('OutVisionXR', style: AppText.display(fontSize: 22)),
                  const SizedBox(height: 16),
                  Text(
                    'A OutVisionXR é uma empresa especializada em experiências imersivas que conectam arte, cultura e tecnologia. Com foco em Realidade Aumentada e Realidade Virtual, desenvolvemos soluções digitais para museus, galerias, festivais e instituições culturais.',
                    style: AppText.body(),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nossa missão é ampliar a forma como as pessoas percebem e interagem com a arte — tornando o invisível visível e o espaço um suporte para novas narrativas.',
                    style: AppText.body(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _LinkChip(
                        label: 'outvisionxr.com',
                        icon: Icons.language,
                        onTap: () => launchUrl(
                          Uri.parse('https://outvisionxr.com'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _LinkChip(
                        label: '@outvisionxr',
                        icon: Icons.camera_alt_outlined,
                        onTap: () => launchUrl(
                          Uri.parse('https://www.instagram.com/outvisionxr/'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 20),
                  Center(
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.data?.version ?? '—';
                        final build = snapshot.data?.buildNumber ?? '';
                        return Column(
                          children: [
                            Text('Versão $version ($build)',
                                style: AppText.caption()),
                            const SizedBox(height: 4),
                            Text(
                              '© 2026 OutVisionXR. Todos os direitos reservados.',
                              textAlign: TextAlign.center,
                              style: AppText.caption(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 22, color: Colors.black),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.fg, size: 16),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(description, style: AppText.caption()),
            ],
          ),
        ),
      ],
    );
  }
}

class _LinkChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _LinkChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.fg3),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.fg2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
