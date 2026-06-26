import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:provider/provider.dart';

class LimiaresPage extends StatelessWidget {
  const LimiaresPage({super.key});

  static const _photoUrl =
      'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F1%20-%20Da%20esquerda%20para%20a%20direita%20-%20Adriana%20Almada%2C%20Tereza%20de%20Arruda%20-%20Cortesia%20High%20Class%20e%20Tereza%20de%20Arruda.jpg?alt=media&token=115d9098-b940-46de-bb1e-a8803675d229';

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: false,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: _BackButton(onTap: () => Navigator.of(context).pop()),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox.shrink(),
                errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: Container(
                height: 28,
                color: AppColors.bg,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Eyebrow caption
                  Text(
                    t.limiares.editionCaption.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: AppColors.muted2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    t.limiares.title,
                    style: GoogleFonts.inter(
                      fontSize: 42,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.5,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: AppColors.hairline),
                  const SizedBox(height: 28),

                  // Conceito
                  Text(t.limiares.conceptLabel, style: AppText.label()),
                  const SizedBox(height: 12),
                  Text(
                    t.limiares.conceptText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: AppColors.body,
                      height: 1.72,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Statement
                  Text(
                    t.limiares.statementTitle.toUpperCase(),
                    style: AppText.label(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.limiares.statementText,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: AppColors.body,
                      height: 1.72,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Divider(height: 1, color: AppColors.hairline),
                  const SizedBox(height: 24),

                  // Curadores
                  Text(
                    t.limiares.curatorsLabel.toUpperCase(),
                    style: AppText.label(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.limiares.curatorsNames,
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
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

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: const Icon(Icons.chevron_left, size: 20, color: Colors.black),
      ),
    );
  }
}
