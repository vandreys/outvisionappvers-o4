import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static const _heroUrl =
      'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro%203.jpg?alt=media&token=12dd3951-c1fc-424d-84f8-e80b5cd64f73';

  Widget _buildFooter(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '—';
        final build = snapshot.data?.buildNumber ?? '';
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Versão $version ($build)', style: AppText.caption()),
              const SizedBox(height: 4),
              Text(
                '© 2026 OutVisionXR. Todos os direitos reservados.',
                textAlign: TextAlign.center,
                style: AppText.caption(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final isTablet = Rsp.isTablet(context);
    return Scaffold(
      backgroundColor: AppColors.bg,
      bottomNavigationBar: isTablet ? _buildFooter(context) : null,
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
              background: CachedNetworkImage(
                imageUrl: _heroUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.bg2),
                errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
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
                  Text(t.about.editionLabel, style: AppText.caption()),
                  const SizedBox(height: 6),
                  Text(
                    t.about.heroTitle,
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
                  Text(t.about.aboutLabel, style: AppText.label()),
                  const SizedBox(height: 12),
                  Text(t.about.appText1, style: AppText.body()),
                  const SizedBox(height: 14),
                  Text(t.about.appText2, style: AppText.body()),
                  const SizedBox(height: 32),
                  _FeatureRow(
                    icon: Icons.view_in_ar,
                    title: t.about.featureArTitle,
                    description: t.about.featureArDesc,
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.map_outlined,
                    title: t.about.featureMapTitle,
                    description: t.about.featureMapDesc,
                  ),
                  const SizedBox(height: 16),
                  _FeatureRow(
                    icon: Icons.person_outline,
                    title: t.about.featureArtistsTitle,
                    description: t.about.featureArtistsDesc,
                  ),
                  const SizedBox(height: 40),
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 32),
                  Text(t.about.devByLabel, style: AppText.label()),
                  const SizedBox(height: 16),
                  Text('OutVision XR', style: AppText.display(fontSize: 22)),
                  const SizedBox(height: 16),
                  Text(t.about.studioText, style: AppText.body()),
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
                  if (!isTablet) ...[
                    const SizedBox(height: 48),
                    Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 20),
                    Center(child: _buildFooter(context)),
                    const SizedBox(height: 24),
                  ],
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
