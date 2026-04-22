import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, AppRouter.welcome);
      }
    });
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
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 48),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Opacity(
                opacity: _fadeIn.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(flex: 3),

                    // Eyebrow
                    Text(
                      '16ª EDIÇÃO · 2026',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fg3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      'Bienal de\nCuritiba',
                      style: GoogleFonts.inter(
                        fontSize: Rsp.fs(context, 44),
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        letterSpacing: -1.0,
                        color: AppColors.fg,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Concept name
                    Text(
                      'Limiares',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                        color: AppColors.fg3,
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Progress bar
                    Column(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Carregando',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: AppColors.fg3,
                              ),
                            ),
                            Text(
                              '${(_progress.value * 100).toInt()}%',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                letterSpacing: 1,
                                color: AppColors.fg3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
