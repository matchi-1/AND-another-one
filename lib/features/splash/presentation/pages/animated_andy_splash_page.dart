import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedAndySplashPage extends StatefulWidget {
  const AnimatedAndySplashPage({super.key});

  @override
  State<AnimatedAndySplashPage> createState() => _AnimatedAndySplashPageState();
}

class _AnimatedAndySplashPageState extends State<AnimatedAndySplashPage>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _idleController;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  bool _startedRedirect = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.65, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0.00,
          0.58,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -0.65,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(
          0.00,
          0.65,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.45, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 35,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.00, 0.82),
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.00, 0.22, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashFlow();
    });
  }

  Future<void> _startSplashFlow() async {
    if (_startedRedirect) return;
    _startedRedirect = true;

    _idleController.repeat();
    unawaited(_introController.forward());

    // Minimum splash duration so the livelier animation is visible.
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    await _redirectAfterAuthCheck();
  }

  Future<void> _redirectAfterAuthCheck() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    String username = 'Player';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final storedUsername = data?['username'] as String?;

      if (storedUsername != null && storedUsername.isNotEmpty) {
        username = storedUsername;
      }
    } catch (_) {
      // fallback stays "Player"
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: 'Welcome back, $username!',
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mergedAnimation = Listenable.merge([
      _introController,
      _idleController,
    ]);

    return Scaffold(
      backgroundColor: AppColors.blueBg,
      body: AnimatedBuilder(
        animation: mergedAnimation,
        builder: (context, _) {
          final intro = _introController.value;
          final idle = _idleController.value;

          final bob = sin(idle * pi * 2) * 8;
          final squashX = 1.0 + sin(idle * pi * 2) * 0.025;
          final squashY = 1.0 - sin(idle * pi * 2) * 0.018;
          final glowPulse = 0.65 + (sin(idle * pi * 2) + 1) * 0.175;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ArcadeSplashBackgroundPainter(
                    introProgress: intro,
                    idleProgress: idle,
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScanlinePainter(
                      progress: idle,
                    ),
                  ),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 270,
                      height: 265,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(260, 260),
                            painter: _PixelBurstPainter(
                              progress: intro,
                              pulse: idle,
                            ),
                          ),

                          Positioned(
                            bottom: 24,
                            child: Transform.scale(
                              scaleX: 1.1 + glowPulse * 0.15,
                              scaleY: 0.72 + glowPulse * 0.08,
                              child: Container(
                                width: 112,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.28),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF00F6FF)
                                          .withOpacity(0.18),
                                      blurRadius: 18,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SlideTransition(
                            position: _slideAnimation,
                            child: Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.translate(
                                offset: Offset(0, bob),
                                child: Transform.rotate(
                                  angle: _rotationAnimation.value,
                                  child: Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.diagonal3Values(
                                        squashX,
                                        squashY,
                                        1,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFFF3AF2)
                                                  .withOpacity(0.34),
                                              blurRadius: 34,
                                              spreadRadius: 6,
                                            ),
                                            BoxShadow(
                                              color: const Color(0xFF00F6FF)
                                                  .withOpacity(0.24),
                                              blurRadius: 52,
                                              spreadRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Image.asset(
                                          AppAssets.andyBasic,
                                          width: 165,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Transform.translate(
                      offset: Offset(0, sin(idle * pi * 2) * 2),
                      child: _LoadingBadge(progress: idle),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingBadge extends StatelessWidget {
  const _LoadingBadge({
    required this.progress,
  });

  final double progress;

  @override
  Widget build(BuildContext context) {
    final dots = '. ' * ((progress * 4).floor() + 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF00F6FF).withOpacity(0.75),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3AF2).withOpacity(0.32),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        'POWERING UP$dots',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.2,
          shadows: [
            Shadow(
              color: Color(0xFF00F6FF),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcadeSplashBackgroundPainter extends CustomPainter {
  _ArcadeSplashBackgroundPainter({
    required this.introProgress,
    required this.idleProgress,
  });

  final double introProgress;
  final double idleProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF101C68),
          Color(0xFF182D9E),
          Color(0xFF351163),
        ],
      ).createShader(rect);

    canvas.drawRect(rect, bgPaint);

    _drawRadialGlow(canvas, size);
    _drawMovingGrid(canvas, size);
    _drawDiagonalSpeedLines(canvas, size);
    _drawFloatingLogicGlyphs(canvas, size);
    _drawPixelCorners(canvas, size);
  }

  void _drawRadialGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.46);
    final radius = size.shortestSide * (0.45 + introProgress * 0.18);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00F6FF).withOpacity(0.22),
          const Color(0xFFFF3AF2).withOpacity(0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, paint);
  }

  void _drawMovingGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF7DF9FF).withOpacity(0.13)
      ..strokeWidth = 1;

    final strongGridPaint = Paint()
      ..color = const Color(0xFFFF3AF2).withOpacity(0.12)
      ..strokeWidth = 1.4;

    const spacing = 30.0;
    final offset = idleProgress * spacing;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      final isStrong = ((x / spacing).round() % 4) == 0;
      canvas.drawLine(
        Offset(x + offset, 0),
        Offset(x + offset - size.height * 0.18, size.height),
        isStrong ? strongGridPaint : gridPaint,
      );
    }

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      final isStrong = ((y / spacing).round() % 4) == 0;
      canvas.drawLine(
        Offset(0, y + offset),
        Offset(size.width, y + offset),
        isStrong ? strongGridPaint : gridPaint,
      );
    }
  }

  void _drawDiagonalSpeedLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    for (int i = 0; i < 9; i++) {
      final t = (idleProgress + i / 9) % 1.0;
      final x = size.width * t;
      final y = size.height * (0.12 + (i % 5) * 0.16);

      paint.color = (i.isEven ? const Color(0xFFFF3AF2) : const Color(0xFF00F6FF))
          .withOpacity(0.08 + introProgress * 0.07);

      canvas.drawLine(
        Offset(x - 90, y + 48),
        Offset(x + 20, y),
        paint,
      );
    }
  }

  void _drawFloatingLogicGlyphs(Canvas canvas, Size size) {
    const glyphs = ['AND', 'OR', 'NOT', '1', '0', 'XOR', 'NAND'];

    for (int i = 0; i < glyphs.length; i++) {
      final drift = (idleProgress + i * 0.137) % 1.0;
      final x = size.width * ((0.11 + i * 0.139) % 1.0);
      final y = size.height * (1.08 - drift * 1.22);
      final wobble = sin((idleProgress * pi * 2) + i) * 10;

      final textPainter = TextPainter(
        text: TextSpan(
          text: glyphs[i],
          style: TextStyle(
            color: Colors.white.withOpacity(0.10),
            fontSize: i % 2 == 0 ? 22 : 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      canvas.save();
      canvas.translate(x + wobble, y);
      canvas.rotate(sin(idleProgress * pi * 2 + i) * 0.08);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  void _drawPixelCorners(Canvas canvas, Size size) {
    final paint = Paint();

    const pixel = 12.0;
    final colors = [
      const Color(0xFF00F6FF).withOpacity(0.34),
      const Color(0xFFFF3AF2).withOpacity(0.28),
      const Color(0xFFFFD93D).withOpacity(0.20),
    ];

    for (int i = 0; i < 16; i++) {
      paint.color = colors[i % colors.length];

      final dx = (i % 4) * pixel;
      final dy = (i ~/ 4) * pixel;

      if ((i + idleProgress * 10).floor().isEven) {
        canvas.drawRect(
          Rect.fromLTWH(dx, dy, pixel * 0.68, pixel * 0.68),
          paint,
        );

        canvas.drawRect(
          Rect.fromLTWH(
            size.width - dx - pixel,
            size.height - dy - pixel,
            pixel * 0.68,
            pixel * 0.68,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArcadeSplashBackgroundPainter oldDelegate) {
    return oldDelegate.introProgress != introProgress ||
        oldDelegate.idleProgress != idleProgress;
  }
}

class _PixelBurstPainter extends CustomPainter {
  _PixelBurstPainter({
    required this.progress,
    required this.pulse,
  });

  final double progress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 3; i++) {
      final ringProgress = ((progress * 1.2) - i * 0.18).clamp(0.0, 1.0);
      final radius = 42 + ringProgress * (76 + i * 18);
      final opacity = (1 - ringProgress).clamp(0.0, 1.0);

      ringPaint.color = [
        const Color(0xFF00F6FF),
        const Color(0xFFFF3AF2),
        const Color(0xFFFFD93D),
      ][i]
          .withOpacity(opacity * 0.55);

      canvas.drawCircle(center, radius, ringPaint);
    }

    final pixelPaint = Paint();

    for (int i = 0; i < 34; i++) {
      final angle = (pi * 2 / 34) * i + pulse * pi * 0.28;
      final burst = Curves.easeOutBack.transform(progress.clamp(0.0, 1.0));
      final distance = 34 + burst * (78 + (i % 5) * 9);
      final sizePx = 5.0 + (i % 4) * 2.0;
      final fade = (1 - progress).clamp(0.0, 1.0);

      pixelPaint.color = [
        const Color(0xFF00F6FF),
        const Color(0xFFFF3AF2),
        const Color(0xFFFFD93D),
        Colors.white,
      ][i % 4]
          .withOpacity(0.18 + fade * 0.48);

      final pos = Offset(
        center.dx + cos(angle) * distance,
        center.dy + sin(angle) * distance,
      );

      canvas.drawRect(
        Rect.fromCenter(
          center: pos,
          width: sizePx,
          height: sizePx,
        ),
        pixelPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({
    required this.progress,
  });

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;

    const gap = 5.0;
    final offset = progress * gap;

    for (double y = -gap; y < size.height + gap; y += gap) {
      canvas.drawLine(
        Offset(0, y + offset),
        Offset(size.width, y + offset),
        paint,
      );
    }

    final shinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.07),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          size.height * ((progress * 1.4) % 1.0) - 90,
          size.width,
          180,
        ),
      );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        size.height * ((progress * 1.4) % 1.0) - 90,
        size.width,
        180,
      ),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}