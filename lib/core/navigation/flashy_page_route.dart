import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

class FlashyPageRoute<T> extends PageRouteBuilder<T> {
  FlashyPageRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
    Color flashColor = Colors.white,
    Duration duration = const Duration(milliseconds: 680),
    Duration reverseDuration = const Duration(milliseconds: 360),
  }) : super(
    settings: settings,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _PixelBurstTransition(
        animation: animation,
        flashColor: flashColor,
        child: child,
      );
    },
  );
}

class _PixelBurstTransition extends StatelessWidget {
  const _PixelBurstTransition({
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
        final t = animation.value;

        final pageCurve = Curves.easeOutBack.transform(
          t.clamp(0.0, 1.0),
        );

        final flashOpacity = _flashOpacity(t);
        final pixelOpacity = _pixelOpacity(t);
        final wipeOpacity = _wipeOpacity(t);
        final scanlineOpacity = _scanlineOpacity(t);

        final slideX = lerpDouble(1.15, 0.0, pageCurve)!;
        final scale = lerpDouble(0.72, 1.0, pageCurve)!;
        final rotation = lerpDouble(0.12, 0.0, pageCurve)!;

        return Stack(
          fit: StackFit.expand,
          children: [
            Transform.translate(
              offset: Offset(
                MediaQuery.of(context).size.width * slideX,
                0,
              ),
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: Curves.easeOut.transform(t),
                    child: child,
                  ),
                ),
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                painter: _PixelBurstPainter(
                  progress: t,
                  color: flashColor,
                  opacity: pixelOpacity,
                ),
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                painter: _WipeBarsPainter(
                  progress: t,
                  color: flashColor,
                  opacity: wipeOpacity,
                ),
              ),
            ),

            IgnorePointer(
              child: CustomPaint(
                painter: _ScanlinePainter(
                  opacity: scanlineOpacity,
                ),
              ),
            ),

            IgnorePointer(
              child: ColoredBox(
                color: flashColor.withOpacity(flashOpacity),
              ),
            ),
          ],
        );
      },
    );
  }

  double _flashOpacity(double t) {
    if (t < 0.10) {
      return t / 0.10;
    }

    if (t < 0.32) {
      return 1.0 - ((t - 0.10) / 0.22);
    }

    return 0.0;
  }

  double _pixelOpacity(double t) {
    if (t < 0.08) {
      return 0.0;
    }

    if (t < 0.22) {
      return (t - 0.08) / 0.14;
    }

    if (t < 0.72) {
      return 1.0 - ((t - 0.22) / 0.50);
    }

    return 0.0;
  }

  double _wipeOpacity(double t) {
    if (t < 0.03) {
      return 0.0;
    }

    if (t < 0.18) {
      return (t - 0.03) / 0.15;
    }

    if (t < 0.58) {
      return 1.0 - ((t - 0.18) / 0.40);
    }

    return 0.0;
  }

  double _scanlineOpacity(double t) {
    if (t < 0.12) return 0.30;
    if (t < 0.62) return 0.30 * (1.0 - ((t - 0.12) / 0.50));
    return 0.0;
  }
}

class _PixelBurstPainter extends CustomPainter {
  _PixelBurstPainter({
    required this.progress,
    required this.color,
    required this.opacity,
  });

  final double progress;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    const double blockSize = 26;
    final cols = (size.width / blockSize).ceil();
    final rows = (size.height / blockSize).ceil();

    final paint = Paint();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        final noise = ((x * 37 + y * 71) % 100) / 100.0;

        final appearPoint = noise * 0.34;
        final local = ((progress - appearPoint) / 0.46).clamp(0.0, 1.0);

        if (local <= 0 || local >= 1) continue;

        final pulse = sin(local * pi);
        final alpha = opacity * pulse * 0.82;

        final sizeBoost = lerpDouble(1.25, 0.65, local)!;
        final rectSize = blockSize * sizeBoost;

        final dx = x * blockSize + (blockSize - rectSize) / 2;
        final dy = y * blockSize + (blockSize - rectSize) / 2;

        final isWhiteBlock = (x + y) % 4 == 0;
        final blockColor = isWhiteBlock ? Colors.white : color;

        paint.color = blockColor.withOpacity(alpha);

        canvas.drawRect(
          Rect.fromLTWH(dx, dy, rectSize, rectSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelBurstPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}

class _WipeBarsPainter extends CustomPainter {
  _WipeBarsPainter({
    required this.progress,
    required this.color,
    required this.opacity,
  });

  final double progress;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    const int barCount = 9;
    final barWidth = size.width / barCount;
    final paint = Paint();

    for (int i = 0; i < barCount; i++) {
      final delay = i * 0.035;
      final local = ((progress - delay) / 0.42).clamp(0.0, 1.0);

      if (local <= 0) continue;

      final height = size.height * Curves.easeOutCubic.transform(local);
      final isAlt = i.isEven;

      paint.color = (isAlt ? color : Colors.white).withOpacity(
        opacity * (isAlt ? 0.42 : 0.28),
      );

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          0,
          barWidth + 1,
          height,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WipeBarsPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity;
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({
    required this.opacity,
  });

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.22);

    const double gap = 8;

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}