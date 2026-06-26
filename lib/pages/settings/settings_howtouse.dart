import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:provider/provider.dart';

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({super.key});

  static const Color _hi = Color(0xFFAF6030);

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final hiStyle = GoogleFonts.inter(color: _hi, fontWeight: FontWeight.w400, fontSize: 14, height: 1.65);
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.hairline, width: 1)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bg2,
                      ),
                      child: const Icon(Icons.chevron_left, size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                children: [
                  Text(
                    'Como usar o app',
                    style: GoogleFonts.inter(
                      fontSize: Rsp.fs(context, 36),
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 36),
                  _Step(
                    number: '01',
                    label: t.howToUse.step1Label,
                    title: t.howToUse.step1Title,
                    spans: [
                      const TextSpan(text: 'Os marcadores '),
                      TextSpan(text: 'no mapa', style: hiStyle),
                      const TextSpan(text: ' indicam onde estão as obras. '),
                      TextSpan(text: 'Toque em um para ver detalhes e obter direções.', style: hiStyle),
                    ],
                  ),
                  _Step(
                    number: '02',
                    label: t.howToUse.step2Label,
                    title: t.howToUse.step2Title,
                    spans: [
                      const TextSpan(text: 'Quando você entrar no '),
                      TextSpan(text: 'raio de 150 m de uma obra', style: hiStyle),
                      const TextSpan(text: ', '),
                      TextSpan(text: 'o app detecta automaticamente sua proximidade.', style: hiStyle),
                    ],
                  ),
                  _Step(
                    number: '03',
                    label: t.howToUse.step3Label,
                    title: t.howToUse.step3Title,
                    spans: [
                      const TextSpan(text: 'Após '),
                      TextSpan(text: '3 segundos no raio', style: hiStyle),
                      const TextSpan(text: ', '),
                      TextSpan(text: 'um card sobe', style: hiStyle),
                      const TextSpan(text: ' com informações e o botão para abrir em RA.'),
                    ],
                  ),
                  _Step(
                    number: '04',
                    label: t.howToUse.step4Label,
                    title: t.howToUse.step4Title,
                    spans: [
                      const TextSpan(text: 'O modelo 3D aparece '),
                      TextSpan(text: 'no mundo real', style: hiStyle),
                      const TextSpan(text: ' pela câmera. '),
                      TextSpan(text: 'Mova-se ao redor', style: hiStyle),
                      const TextSpan(text: ' para explorar em escala real.'),
                    ],
                    isLast: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: Text(
                    t.howToUse.done.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String number;
  final String label;
  final String title;
  final List<InlineSpan> spans;
  final bool isLast;

  const _Step({
    required this.number,
    required this.label,
    required this.title,
    required this.spans,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w300,
      color: AppColors.body,
      height: 1.65,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: AppColors.hairline),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  number,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: AppColors.faint,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppText.eyebrow()),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(text: TextSpan(style: baseStyle, children: spans)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isLast) Divider(height: 1, color: AppColors.hairline),
      ],
    );
  }
}
