import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static const _heroUrl =
      'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro%203.jpg?alt=media&token=12dd3951-c1fc-424d-84f8-e80b5cd64f73';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── Hero image com card branco sobreposto ──────────────────────
          SliverAppBar(
            expandedHeight: 320,
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
                    progress == null ? child : Container(color: const Color(0xFFBBBBBB)),
                errorBuilder: (context, _, __) =>
                    Container(color: const Color(0xFFBBBBBB)),
              ),
            ),
            // Card branco com cantos arredondados sobreposto à imagem
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(32),
              child: Container(
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
            ),
          ),

          // ── Conteúdo ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle + título
                  const Text(
                    '16ª Edição · 2025',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Bienal de\nCuritiba',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(height: 1, color: Colors.black12),
                  const SizedBox(height: 28),

                  // ── Sobre o App ──────────────────────────────────────
                  const Text(
                    'SOBRE O APP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'O app da Bienal de Curitiba é sua porta de entrada para uma experiência artística que vai além do espaço físico da exposição. Desenvolvido especialmente para a 16ª edição, o aplicativo permite que você explore obras de arte em Realidade Aumentada — diretamente nos locais onde as obras estão instaladas.',
                    style: TextStyle(fontSize: 15, height: 1.75, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ao se aproximar de uma obra participante, o app reconhece sua localização e libera a experiência em AR. Apontando a câmera para o espaço ao redor, você vê a obra tomar vida em três dimensões — fundindo o digital com o mundo real.',
                    style: TextStyle(fontSize: 15, height: 1.75, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),

                  // ── Features ─────────────────────────────────────────
                  const _FeatureRow(
                    icon: Icons.view_in_ar,
                    title: 'Realidade Aumentada',
                    description: 'Visualize obras em 3D no espaço real, nos locais da Bienal.',
                  ),
                  const SizedBox(height: 16),
                  const _FeatureRow(
                    icon: Icons.map_outlined,
                    title: 'Mapa Interativo',
                    description: 'Navegue pelos pontos da exposição e encontre obras próximas.',
                  ),
                  const SizedBox(height: 16),
                  const _FeatureRow(
                    icon: Icons.person_outline,
                    title: 'Artistas',
                    description: 'Conheça a trajetória e a obra dos artistas participantes.',
                  ),
                  const SizedBox(height: 40),

                  Container(height: 1, color: Colors.black12),
                  const SizedBox(height: 32),

                  // ── Desenvolvido por ──────────────────────────────────
                  const Text(
                    'DESENVOLVIDO POR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: Colors.black45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OutVisionXR',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 2, width: 36, color: Colors.black38),
                  const SizedBox(height: 16),
                  const Text(
                    'A OutVisionXR é uma empresa especializada em experiências imersivas que conectam arte, cultura e tecnologia. Com foco em Realidade Aumentada e Realidade Virtual, desenvolvemos soluções digitais para museus, galerias, festivais e instituições culturais.',
                    style: TextStyle(fontSize: 15, height: 1.75, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nossa missão é ampliar a forma como as pessoas percebem e interagem com a arte — tornando o invisível visível e o espaço um suporte para novas narrativas.',
                    style: TextStyle(fontSize: 15, height: 1.75, color: Colors.black87),
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
                      const SizedBox(width: 12),
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

                  // ── Versão ────────────────────────────────────────────
                  Container(height: 1, color: Colors.black12),
                  const SizedBox(height: 20),
                  Center(
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final version = snapshot.data?.version ?? '—';
                        final build = snapshot.data?.buildNumber ?? '';
                        return Column(
                          children: [
                            Text(
                              'Versão $version ($build)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black38,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '© 2025 OutVisionXR. Todos os direitos reservados.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: Colors.black38),
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
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 26, color: Colors.black),
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
