import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sticky back bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.hairline, width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.chevron_left, size: 20, color: AppColors.ink),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                children: [
                  const SizedBox(height: 32),
                  Text(t.settings.bienalEyebrow, style: AppText.eyebrow()),
                  const SizedBox(height: 6),
                  Text(
                    t.settings.title,
                    style: GoogleFonts.inter(
                      fontSize: Rsp.fs(context, 36),
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(t.settings.appSectionLabel, style: AppText.label()),
                  const SizedBox(height: 6),
                  _MenuItem(
                    title: t.settings.getHelp,
                    onTap: () => Navigator.pushNamed(
                        context, AppRouter.settingsHowToUse),
                  ).build(),
                  _MenuItem(
                    title: t.settings.language,
                    onTap: () => Navigator.pushNamed(
                        context, AppRouter.settingsLang),
                  ).build(),
                  _MenuItem(
                    title: t.settings.aboutApp,
                    onTap: () => Navigator.pushNamed(
                        context, AppRouter.settingsApp),
                  ).build(),
                  const SizedBox(height: 32),
                  Text(t.settings.bienalSectionLabel, style: AppText.label()),
                  const SizedBox(height: 6),
                  _MenuItem(
                    title: t.settings.limiares,
                    onTap: () => Navigator.pushNamed(
                        context, AppRouter.settingsLimiares),
                  ).build(),
                  _MenuItem(
                    title: t.settings.website,
                    isExternal: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://www.bienaldecuritiba.org/'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ).build(),
                  _MenuItem(
                    title: t.settings.instagram,
                    isExternal: true,
                    onTap: () => launchUrl(
                      Uri.parse(
                          'https://www.instagram.com/bienaldecuritiba/'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ).build(),
                  _MenuItem(
                    title: t.settings.privacyPolicy,
                    isExternal: true,
                    onTap: () => launchUrl(
                      Uri.parse('https://outvisionxr.com/privacy-bienal'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ).build(),
                  _MenuItem(
                    title: t.settings.termsOfUse,
                    isExternal: true,
                    onTap: () => launchUrl(
                      Uri.parse(
                          'https://outvisionxr.com/terms-of-use-bienal'),
                      mode: LaunchMode.externalApplication,
                    ),
                  ).build(),
                  const SizedBox(height: 48),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snap) {
                      final version = snap.data?.version ?? '—';
                      return Center(
                        child: Text(
                          'V$version · BIENAL DE CURITIBA'.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.faint,
                            letterSpacing: 1.5,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _MenuItem {
  final String title;
  final VoidCallback onTap;
  final bool isExternal;

  const _MenuItem({
    required this.title,
    required this.onTap,
    this.isExternal = false,
  });

  Widget build() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: const Color(0xFF14110E).withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isExternal)
                const Icon(Icons.open_in_new, size: 11, color: AppColors.faint)
              else
                const Icon(Icons.chevron_right, size: 15, color: AppColors.faint),
            ],
          ),
        ),
      ),
    );
  }
}
