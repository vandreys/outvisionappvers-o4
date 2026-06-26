import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/utils/app_theme.dart';

class SplashLoading extends StatefulWidget {
  const SplashLoading({super.key});

  @override
  State<SplashLoading> createState() => _SplashLoadingState();
}

class _SplashLoadingState extends State<SplashLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              Image.asset(
                'assets/images/bienal_ar_es.png',
                width: 180,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(1),
                        child: SizedBox(
                          height: 1,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              Container(color: AppColors.border),
                              FractionallySizedBox(
                                widthFactor: _progress.value,
                                child: Container(color: AppColors.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Carregando',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          letterSpacing: 1.5,
                          color: AppColors.fg3,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
