import 'dart:math';
import 'package:flutter/material.dart';

class FlashyPageRoute<T> extends PageRouteBuilder<T> {
  FlashyPageRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
    Color flashColor = Colors.white,
    Duration duration = const Duration(milliseconds: 1250),
    Duration reverseDuration = const Duration(milliseconds: 1250),
  }) : super(
    settings: settings,
    opaque: false,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _PixelWaveRevealTransition(
        animation: animation,
        flashColor: flashColor,
        child: child,
      );
    },
  );
}

class _PixelWaveRevealTransition extends StatelessWidget {
  const _PixelWaveRevealTransition({
    required this.animation,
    required this.flashColor,
    required this.child,
  });

  final Animation<double> animation;
  final Color flashColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final rawT = animation.value;
        final revealT = Curves.easeInOutCubic.transform(rawT);

        return Stack(
          fit: StackFit.expand,
          children: [
            // New page reveals from top to bottom.
            ClipRect(
              clipper: _TopToBottomRevealClipper(
                progress: revealT,
              ),
              child: child,
            ),

            // Pixel wave/trickle layer.
            IgnorePointer(
              child: CustomPaint(
                painter: _PixelWavePainter(
                  progress: rawT,
                  revealProgress: revealT,
                  color: flashColor,
                ),
              ),
            ),

            // Quick initial flash so the transition feels punchier.
            IgnorePointer(
              child: ColoredBox(
                color: flashColor.withOpacity(_flashOpacity(rawT)),
              ),
            ),
          ],
        );
      },
    );
  }

  double _flashOpacity(double t) {
    if (t < 0.08) {
      return t / 0.08 * 0.75;
    }

    if (t < 0.24) {
      return 0.75 * (1.0 - ((t - 0.08) / 0.16));
    }

    return 0.0;
  }
}

class _TopToBottomRevealClipper extends CustomClipper<Rect> {
  const _TopToBottomRevealClipper({
    required this.progress,
  });

  final double progress;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height * progress.clamp(0.0, 1.0),
    );
  }

  @override
  bool shouldReclip(covariant _TopToBottomRevealClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

class _PixelWavePainter extends CustomPainter {
  _PixelWavePainter({
    required this.progress,
    required this.revealProgress,
    required this.color,
  });

  final double progress;
  final double revealProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    const double blockSize = 24;
    final cols = (size.width / blockSize).ceil();
    final rows = (size.height / blockSize).ceil();

    final waveY = size.height * revealProgress;
    final waveBand = blockSize * 5.2;

    final paint = Paint();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final centerX = (col * blockSize) + blockSize / 2;
        final centerY = (row * blockSize) + blockSize / 2;

        final distanceFromWave = (centerY - waveY).abs();

        if (distanceFromWave > waveBand) continue;

        final noise = _noise(col, row);

        // Creates a staggered / trickling edge instead of a straight line.
        final stagger = (noise - 0.5) * blockSize * 3.2;
        final adjustedDistance = (centerY + stagger - waveY).abs();

        if (adjustedDistance > waveBand) continue;

        final closeness = 1.0 - (adjustedDistance / waveBand).clamp(0.0, 1.0);
        final pulse = sin(closeness * pi);

        final alpha = (pulse * 0.88).clamp(0.0, 0.88);

        final isWhiteBlock = (col + row) % 5 == 0;
        final isBrightBlock = (col * 3 + row * 7) % 11 == 0;

        final blockColor = isWhiteBlock
            ? Colors.white
            : isBrightBlock
            ? color.withOpacity(0.95)
            : color;

        final fallAmount = blockSize * 1.4 * (1.0 - closeness) * noise;
        final rectSize = blockSize * (0.62 + (0.50 * closeness));

        final dx = centerX - rectSize / 2;
        final dy = centerY - rectSize / 2 + fallAmount;

        paint.color = blockColor.withOpacity(alpha);

        canvas.drawRect(
          Rect.fromLTWH(dx, dy, rectSize, rectSize),
          paint,
        );
      }
    }

    _paintScanlines(canvas, size);
  }

  void _paintScanlines(Canvas canvas, Size size) {
    if (progress > 0.72) return;

    final opacity = 0.18 * (1.0 - (progress / 0.72).clamp(0.0, 1.0));

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity);

    const gap = 8.0;

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.3),
        paint,
      );
    }
  }

  double _noise(int x, int y) {
    final value = (x * 73 + y * 151 + x * y * 17) % 100;
    return value / 100.0;
  }

  @override
  bool shouldRepaint(covariant _PixelWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.revealProgress != revealProgress ||
        oldDelegate.color != color;
  }
}