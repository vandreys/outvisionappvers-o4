import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/utils/app_theme.dart';

class HowToUsePage extends StatefulWidget {
  const HowToUsePage({super.key});

  @override
  State<HowToUsePage> createState() => _HowToUsePageState();
}

class _HowToUsePageState extends State<HowToUsePage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _Slide(
      step: 'PASSO 1 · EXPLORE',
      title: 'Abra o mapa\ne explore',
      description: 'Os marcadores no mapa indicam onde estão as obras. Toque em um para ver detalhes e obter direções.',
      mockup: _MockupMap(),
    ),
    _Slide(
      step: 'PASSO 2 · APROXIME-SE',
      title: 'Caminhe até\na obra',
      description: 'Quando você entrar no raio de 150m de uma obra, o app detecta automaticamente sua proximidade.',
      mockup: _MockupProximity(),
    ),
    _Slide(
      step: 'PASSO 3 · DESBLOQUEIO',
      title: 'A obra aparece\nautomaticamente',
      description: 'Após 3 segundos no raio, um card sobe com informações e o botão para abrir em AR.',
      mockup: _MockupCard(),
    ),
    _Slide(
      step: 'PASSO 4 · REALIDADE AUMENTADA',
      title: 'Aponte a câmera\ne veja a arte',
      description: 'O modelo 3D aparece no mundo real pela câmera. Mova-se ao redor para explorar em escala real.',
      mockup: _MockupAR(),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  _NavButton(onTap: () => Navigator.of(context).pop()),
                  const Spacer(),
                  Text('${_currentPage + 1} / ${_slides.length}', style: AppText.caption()),
                  if (!isLast) ...[
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('Pular', style: AppText.caption(color: AppColors.accent)),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final active = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active ? AppColors.fg : AppColors.fg3,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fg,
                        foregroundColor: AppColors.bg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(
                        isLast ? 'Entendi' : 'Próximo',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.2),
                      ),
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
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _Slide {
  final String step;
  final String title;
  final String description;
  final Widget mockup;
  const _Slide({required this.step, required this.title, required this.description, required this.mockup});
}

// ─── Slide layout ─────────────────────────────────────────────────────────────

class _SlideView extends StatelessWidget {
  final _Slide slide;
  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final phoneH = constraints.maxHeight * 0.92;
                final phoneW = phoneH * 0.50;
                return Center(
                  child: SizedBox(
                    width: phoneW,
                    height: phoneH,
                    child: _PhoneFrame(child: slide.mockup),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(slide.step, style: AppText.label(color: AppColors.accent)),
          const SizedBox(height: 6),
          Text(slide.title, style: AppText.display(fontSize: Rsp.fs(context, 24))),
          const SizedBox(height: 8),
          Text(slide.description, style: AppText.body()),
          const Spacer(),
        ],
      ),
    );
  }
}

// ─── Phone frame ──────────────────────────────────────────────────────────────

class _PhoneFrame extends StatelessWidget {
  final Widget child;
  const _PhoneFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.fg.withValues(alpha: 0.12), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.fg.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.5),
        child: Stack(
          children: [
            child,
            Positioned(
              top: 8, left: 0, right: 0,
              child: Center(
                child: Container(
                  width: 44, height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(3),
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

// ─── Slide 1: Map ─────────────────────────────────────────────────────────────

class _MockupMap extends StatelessWidget {
  const _MockupMap();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      double px(double x) => x / 220 * w;
      double py(double y) => y / 440 * h;
      return Stack(children: [
        CustomPaint(painter: const _MapPainter(), size: Size(w, h)),
        _PhoneStatusBar(textColor: AppColors.fg),
        Positioned(
          top: py(46), left: px(14), right: px(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _MapBtn(icon: Icons.menu),
            _MapBtn(icon: Icons.near_me_outlined),
          ]),
        ),
        Positioned(left: px(50), top: py(115), child: const _MapMarker()),
        Positioned(left: px(130), top: py(175), child: const _MapMarker()),
        Positioned(left: px(60), top: py(295), child: const _MapMarker()),
        Positioned(left: px(160), top: py(240), child: const _MapMarker()),
        Positioned(left: px(93), top: py(193), child: const _UserDot()),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(width: 20, height: 2.5, margin: const EdgeInsets.only(bottom: 7),
                  decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2)))),
              Text('Nenhuma obra por perto',
                style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.fg)),
              const SizedBox(height: 2),
              Text('Caminhe em direção aos marcadores.',
                style: GoogleFonts.inter(fontSize: 6.5, color: AppColors.fg3, height: 1.5)),
              const SizedBox(height: 7),
              Container(
                width: double.infinity, height: 22,
                decoration: BoxDecoration(color: AppColors.fg, borderRadius: BorderRadius.circular(5)),
                child: Center(child: Text('Ir à obra mais próxima',
                    style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w600, color: Colors.white))),
              ),
            ]),
          ),
        ),
      ]);
    });
  }
}

// ─── Slide 3: Proximity ───────────────────────────────────────────────────────

class _MockupProximity extends StatelessWidget {
  const _MockupProximity();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      double px(double x) => x / 220 * w;
      double py(double y) => y / 440 * h;
      final ringW = 90 / 220 * w;
      final ringH = 90 / 440 * h;
      return Stack(children: [
        CustomPaint(painter: const _MapPainter(), size: Size(w, h)),
        _PhoneStatusBar(textColor: AppColors.fg),
        Positioned(
          top: py(46), left: px(14), right: px(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _MapBtn(icon: Icons.menu),
            _MapBtn(icon: Icons.near_me_outlined),
          ]),
        ),
        // Proximity ring around selected marker at HTML (90,145) center
        Positioned(
          left: px(90) - ringW / 2,
          top: py(145) - ringH / 2,
          width: ringW, height: ringH,
          child: CustomPaint(
            painter: _DashedRingPainter(
              color: AppColors.accent.withValues(alpha: 0.5),
              fillColor: AppColors.accent.withValues(alpha: 0.06),
            ),
          ),
        ),
        Positioned(left: px(60), top: py(295), child: const _MapMarker()),
        Positioned(left: px(160), top: py(240), child: const _MapMarker()),
        Positioned(left: px(76), top: py(131), child: const _MapMarker(selected: true)),
        // Distance chip centered at x=50%, y=110
        Positioned(
          top: py(102), left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(8)),
              child: Text('~80m',
                style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5)),
            ),
          ),
        ),
        Positioned(left: px(108), top: py(183), child: const _UserDot()),
      ]);
    });
  }
}

// ─── Slide 4: Card ────────────────────────────────────────────────────────────

class _MockupCard extends StatelessWidget {
  const _MockupCard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final h = box.maxHeight;
      double px(double x) => x / 220 * w;
      double py(double y) => y / 440 * h;
      final ringW = 90 / 220 * w;
      final ringH = 90 / 440 * h;
      return Stack(children: [
        CustomPaint(painter: const _MapPainter(), size: Size(w, h)),
        _PhoneStatusBar(textColor: AppColors.fg),
        Positioned(
          top: py(46), left: px(14), right: px(14),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _MapBtn(icon: Icons.menu),
            _MapBtn(icon: Icons.near_me_outlined),
          ]),
        ),
        Positioned(
          left: px(120) - ringW / 2, top: py(155) - ringH / 2,
          width: ringW, height: ringH,
          child: CustomPaint(
            painter: _DashedRingPainter(
              color: AppColors.accent.withValues(alpha: 0.4),
              fillColor: AppColors.accent.withValues(alpha: 0.04),
            ),
          ),
        ),
        Positioned(left: px(106), top: py(141), child: const _MapMarker(selected: true)),
        Positioned(left: px(116), top: py(151), child: const _UserDot()),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 16, offset: const Offset(0, -6))],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 20, height: 2.5, margin: const EdgeInsets.only(bottom: 7),
                  decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2)))),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: double.infinity, height: 56,
                  child: Stack(children: [
                    CustomPaint(painter: const _AbstractArtPainter(), child: Container()),
                    Positioned(top: 4, right: 4,
                      child: Container(
                        width: 14, height: 14,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x73000000)),
                        child: const Icon(Icons.close, size: 7, color: Colors.white),
                      )),
                  ]),
                ),
              ),
              const SizedBox(height: 5),
              Text('JARDIM BOTÂNICO', style: GoogleFonts.inter(fontSize: 5.5, color: AppColors.fg3)),
              const SizedBox(height: 1),
              Text('Threads of Silence',
                style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: AppColors.fg)),
              const SizedBox(height: 1),
              Text('Chiharu Shiota', style: GoogleFonts.inter(fontSize: 6, color: AppColors.fg3)),
              const SizedBox(height: 7),
              Container(
                width: double.infinity, height: 22,
                decoration: BoxDecoration(color: AppColors.fg, borderRadius: BorderRadius.circular(5)),
                child: Center(child: Text('Abrir em AR',
                    style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w600, color: Colors.white))),
              ),
            ]),
          ),
        ),
      ]);
    });
  }
}

// ─── Slide 5: AR view ─────────────────────────────────────────────────────────

class _MockupAR extends StatelessWidget {
  const _MockupAR();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFC8DFEF), Color(0xFFD6E9F5), Color(0xFFBFD5EA)],
        ),
      ),
      child: Stack(alignment: Alignment.center, children: [
        Align(
          alignment: const Alignment(0, -0.25),
          child: Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppColors.accent.withValues(alpha: 0.35), Colors.transparent,
              ]),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.25),
          child: CustomPaint(size: const Size(60, 78), painter: const _SculpturePainter()),
        ),
        Align(
          alignment: const Alignment(0, -0.25),
          child: SizedBox(
            width: 80, height: 80,
            child: CustomPaint(painter: const _ReticlePainter()),
          ),
        ),
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            height: 26,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(children: [
              Text('9:41', style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A3A5C).withValues(alpha: 0.7))),
              const Spacer(),
              Text('● AR ATIVO', style: GoogleFonts.inter(fontSize: 6, fontWeight: FontWeight.w700,
                  letterSpacing: 0.5, color: const Color(0xFF5BA3D9))),
            ]),
          ),
        ),
        Positioned(
          bottom: 52, left: 0, right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF5BA3D9).withValues(alpha: 0.25)),
              ),
              child: Text('Threads of Silence · Chiharu Shiota',
                style: GoogleFonts.inter(fontSize: 5.5, color: const Color(0xFF1A3A5C), fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter, end: Alignment.topCenter,
                colors: [const Color(0xFFB4D7F0).withValues(alpha: 0.8), Colors.transparent],
              ),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5BA3D9).withValues(alpha: 0.5), width: 1.2),
                ),
                child: Icon(Icons.close, size: 8, color: const Color(0xFF1A3A5C).withValues(alpha: 0.6)),
              ),
              const SizedBox(width: 14),
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white,
                  border: Border.all(color: const Color(0xFF5BA3D9).withValues(alpha: 0.4), width: 2.5),
                  boxShadow: [BoxShadow(color: const Color(0xFF5BA3D9).withValues(alpha: 0.2), blurRadius: 6)],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 20, height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF5BA3D9).withValues(alpha: 0.5), width: 1.2),
                ),
                child: Icon(Icons.refresh, size: 8, color: const Color(0xFF1A3A5C).withValues(alpha: 0.6)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _PhoneStatusBar extends StatelessWidget {
  final Color textColor;
  const _PhoneStatusBar({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
        child: Row(children: [
          Text('9:41', style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w600, color: textColor)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [2.0, 4.0, 6.0].map((barH) =>
              Container(width: 2.5, height: barH, margin: const EdgeInsets.only(right: 1), color: textColor)
            ).toList(),
          ),
          const SizedBox(width: 3),
          Container(
            width: 12, height: 6,
            decoration: BoxDecoration(border: Border.all(color: textColor, width: 0.8), borderRadius: BorderRadius.circular(1)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(width: 8, height: 4, margin: const EdgeInsets.all(0.5),
                decoration: BoxDecoration(color: textColor, borderRadius: BorderRadius.circular(0.5))),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  final IconData icon;
  const _MapBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22, height: 22,
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Icon(icon, size: 10, color: AppColors.fg),
    );
  }
}

class _MapMarker extends StatelessWidget {
  final bool selected;
  const _MapMarker({this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle, color: Colors.white,
        border: Border.all(color: selected ? AppColors.fg : const Color(0xFFBBBBBB), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Center(
        child: Container(
          width: 12, height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF7B52FF), Color(0xFFC1632F)],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10, height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF2979FF),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [BoxShadow(color: const Color(0xFF2979FF).withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 2)],
      ),
    );
  }
}

// ─── Custom painters ──────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  const _MapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    double px(double x) => x / 220 * w;
    double py(double y) => y / 440 * h;

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8E8E8));

    final block = Paint()..color = const Color(0xFFDCDCDC);
    void b(double x, double y, double bw, double bh) =>
        canvas.drawRect(Rect.fromLTWH(px(x), py(y), px(bw), py(bh)), block);
    b(0, 60, 90, 80); b(100, 60, 120, 50); b(0, 160, 70, 100);
    b(80, 130, 80, 70); b(170, 130, 50, 90); b(0, 280, 100, 80);
    b(110, 240, 110, 100);

    final road = Paint()..color = const Color(0xFFF0F0F0);
    void r(double x, double y, double rw, double rh) =>
        canvas.drawRect(Rect.fromLTWH(px(x), py(y), px(rw), py(rh)), road);
    r(90, 0, 10, 440); r(0, 150, 220, 10); r(0, 270, 220, 10); r(160, 0, 10, 220);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(px(100), py(160), px(60), py(80)), const Radius.circular(4)),
      Paint()..color = const Color(0xFFD8E8D0),
    );
  }

  @override
  bool shouldRepaint(_MapPainter old) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  const _DashedRingPainter({required this.color, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(center: center, width: size.width, height: size.height);

    canvas.drawOval(rect, Paint()..color = fillColor);

    final dashPaint = Paint()..color = color..strokeWidth = 1.2..style = PaintingStyle.stroke;
    const count = 18;
    const span = math.pi * 2 / count;
    for (int i = 0; i < count; i++) {
      canvas.drawArc(rect, i * span, span * 0.6, false, dashPaint);
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => false;
}

class _AbstractArtPainter extends CustomPainter {
  const _AbstractArtPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF1A1A2E));
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.5), size.height * 0.7,
        Paint()..color = const Color(0xFFC1632F).withValues(alpha: 0.3));
    canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.65), size.height * 0.5,
        Paint()..color = const Color(0xFF7B52FF).withValues(alpha: 0.2));
  }

  @override
  bool shouldRepaint(_AbstractArtPainter old) => false;
}

class _SculpturePainter extends CustomPainter {
  const _SculpturePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    void ellipse(double rx, double ry, Color color, {bool fill = false}) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
        Paint()..color = color..strokeWidth = 0.8..style = fill ? PaintingStyle.fill : PaintingStyle.stroke,
      );
    }

    ellipse(28, 36, const Color(0xFFFFDCB4).withValues(alpha: 0.7));
    ellipse(18, 28, AppColors.accent.withValues(alpha: 0.8));
    ellipse(8, 16, AppColors.accent.withValues(alpha: 0.15), fill: true);
    ellipse(8, 16, AppColors.accent.withValues(alpha: 0.9));

    final thread = Paint()..color = const Color(0xFFFFB478).withValues(alpha: 0.35)..strokeWidth = 0.6;
    for (final p in [
      Offset(0.15 * size.width, 0.28 * size.height),
      Offset(0.85 * size.width, 0.28 * size.height),
      Offset(0.15 * size.width, 0.72 * size.height),
      Offset(0.85 * size.width, 0.72 * size.height),
      Offset(cx, 0.1 * size.height),
      Offset(cx, 0.9 * size.height),
    ]) {
      canvas.drawLine(p, Offset(cx, cy), thread);
    }

    canvas.drawCircle(Offset(cx, cy), 3, Paint()..color = AppColors.accent.withValues(alpha: 0.9));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 3), width: 20, height: 5),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(_SculpturePainter old) => false;
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    const len = 12.0;
    final w = size.width;
    final h = size.height;
    for (final path in [
      Path()..moveTo(0, len)..lineTo(0, 0)..lineTo(len, 0),
      Path()..moveTo(w - len, 0)..lineTo(w, 0)..lineTo(w, len),
      Path()..moveTo(0, h - len)..lineTo(0, h)..lineTo(len, h),
      Path()..moveTo(w - len, h)..lineTo(w, h)..lineTo(w, h - len),
    ]) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ReticlePainter old) => false;
}


// ─── Nav button ───────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final VoidCallback onTap;
  const _NavButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.bg2, borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: const Icon(Icons.chevron_left, size: 20, color: Colors.black),
      ),
    );
  }
}
