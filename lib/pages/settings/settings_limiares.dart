import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/utils/app_theme.dart';

class LimiaresPage extends StatelessWidget {
  const LimiaresPage({super.key});

  static const _photoUrl =
      'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F1%20-%20Da%20esquerda%20para%20a%20direita%20-%20Adriana%20Almada%2C%20Tereza%20de%20Arruda%20-%20Cortesia%20High%20Class%20e%20Tereza%20de%20Arruda.jpg?alt=media&token=115d9098-b940-46de-bb1e-a8803675d229';

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
              child: _BackButton(onTap: () => Navigator.of(context).pop()),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const SizedBox.shrink(),
                errorBuilder: (_, __, ___) => Container(color: AppColors.bg2),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(28),
              child: Container(
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '16ª Bienal de Curitiba · 2026',
                    style: AppText.caption(),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t.limiares.title,
                    style: AppText.display(fontSize: 38),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 28),

                  // Conceito
                  Text('CONCEITO', style: AppText.label()),
                  const SizedBox(height: 12),
                  Text(t.limiares.conceptText, style: AppText.body()),
                  const SizedBox(height: 32),

                  // Statement
                  Text(
                    t.limiares.statementTitle.toUpperCase(),
                    style: AppText.label(),
                  ),
                  const SizedBox(height: 12),
                  Text(t.limiares.statementText, style: AppText.body()),
                  const SizedBox(height: 40),

                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 24),

                  // Curadores
                  Text(
                    t.limiares.curatorsLabel.toUpperCase(),
                    style: AppText.label(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.limiares.curatorsNames,
                    style: AppText.display(fontSize: 16),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.chevron_left, size: 22, color: Colors.black),
      ),
    );
  }
}
