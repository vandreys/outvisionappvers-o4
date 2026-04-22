import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.bg2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.chevron_left,
                              size: 22, color: AppColors.fg),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text('BIENAL DE CURITIBA', style: AppText.eyebrow()),
                  const SizedBox(height: 6),
                  Text(t.settings.title, style: AppText.display(fontSize: Rsp.fs(context, 38))),
                  const SizedBox(height: 28),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                children: [
                  _buildSection(
                    label: 'APP',
                    items: [
                      _SettingsItem(
                        icon: Icons.help_outline,
                        title: t.settings.getHelp,
                        subtitle: 'Suporte e perguntas frequentes',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.language,
                        title: t.settings.language,
                        subtitle: _currentLangLabel(),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.settingsLang),
                        isNav: true,
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline,
                        title: t.settings.aboutApp,
                        subtitle: 'Versão e informações',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.settingsApp),
                        isNav: true,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    label: 'BIENAL',
                    items: [
                      _SettingsItem(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Limiares',
                        subtitle: 'Conceito curatorial da 16ª edição',
                        onTap: () => Navigator.pushNamed(
                            context, AppRouter.settingsLimiares),
                        isNav: true,
                      ),
                      _SettingsItem(
                        icon: Icons.computer_outlined,
                        title: t.settings.website,
                        subtitle: 'bienaldecuritiba.org',
                        isExternal: true,
                        onTap: () => launchUrl(
                          Uri.parse('https://www.bienaldecuritiba.org/'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _SettingsItem(
                        iconWidget: const FaIcon(FontAwesomeIcons.instagram,
                            size: 15, color: AppColors.fg),
                        title: t.settings.instagram,
                        subtitle: '@bienaldecuritiba',
                        isExternal: true,
                        onTap: () => launchUrl(
                          Uri.parse(
                              'https://www.instagram.com/bienaldecuritiba/'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.shield_outlined,
                        title: t.settings.privacyPolicy,
                        subtitle: 'Política de privacidade',
                        isExternal: true,
                        onTap: () => launchUrl(
                          Uri.parse('https://outvisionxr.com/privacy-bienal'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                      _SettingsItem(
                        icon: Icons.description_outlined,
                        title: t.settings.termsOfUse,
                        subtitle: 'Termos e condições',
                        isExternal: true,
                        isLast: true,
                        onTap: () => launchUrl(
                          Uri.parse(
                              'https://outvisionxr.com/terms-of-use-bienal'),
                          mode: LaunchMode.externalApplication,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snap) {
                        final version = snap.data?.version ?? '—';
                        return Text(
                          'v$version · Bienal de Curitiba',
                          style: AppText.caption(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currentLangLabel() {
    switch (LocaleSettings.currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'Português';
    }
  }

  Widget _buildSection(
      {required String label, required List<_SettingsItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(label, style: AppText.label()),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: items.map((item) => item._build()).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isExternal;
  final bool isNav;
  final bool isLast;

  const _SettingsItem({
    this.icon,
    this.iconWidget,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isExternal = false,
    this.isNav = false,
    this.isLast = false,
  });

  Widget _build() {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: iconWidget ??
                        Icon(icon, size: 16, color: AppColors.fg),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.fg,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(subtitle, style: AppText.caption()),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isExternal)
                  Icon(Icons.open_in_new, size: 12, color: AppColors.fg3)
                else
                  Icon(Icons.chevron_right, size: 16, color: AppColors.fg3),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 60,
            endIndent: 0,
            color: AppColors.border,
          ),
      ],
    );
  }
}
