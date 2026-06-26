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
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Logo centralizada
          Center(
            child: AnimatedBuilder(
              animation: _fadeIn,
              builder: (_, child) => Opacity(opacity: _fadeIn.value, child: child),
              child: Image.asset(
                'assets/images/bienal_ar_es.png',
                width: screenW * 0.62,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Barra de loading no rodapé
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
                child: AnimatedBuilder(
                  animation: _progress,
                  builder: (_, __) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                                child: Container(color: AppColors.ink),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'CARREGANDO',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          letterSpacing: 2.0,
                          color: AppColors.faint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
