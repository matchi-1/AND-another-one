import 'package:flutter/material.dart';
import 'dart:async';

import '../../core/audio/sfx_controller.dart';

enum TutorialAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

class TutorialOverlayPlacement {
  final TutorialAnchor anchor;

  /// Pixel adjustment after anchoring.
  ///
  /// Example:
  /// Offset(-20, 0) moves left.
  /// Offset(0, 30) moves down.
  final Offset offset;

  /// Keeps Andy/dialogue away from screen edges.
  final EdgeInsets margin;

  final Duration duration;
  final Curve curve;

  const TutorialOverlayPlacement({
    required this.anchor,
    this.offset = Offset.zero,
    this.margin = const EdgeInsets.all(18),
    this.duration = const Duration(milliseconds: 480),
    this.curve = Curves.easeOutCubic,
  });
}

class TutorialPositions {
  const TutorialPositions._();

  static const topLeft = TutorialOverlayPlacement(
    anchor: TutorialAnchor.topLeft,
  );

  static const topCenter = TutorialOverlayPlacement(
    anchor: TutorialAnchor.topCenter,
  );

  static const topRight = TutorialOverlayPlacement(
    anchor: TutorialAnchor.topRight,
  );

  static const centerLeft = TutorialOverlayPlacement(
    anchor: TutorialAnchor.centerLeft,
  );

  static const center = TutorialOverlayPlacement(
    anchor: TutorialAnchor.center,
  );

  static const centerRight = TutorialOverlayPlacement(
    anchor: TutorialAnchor.centerRight,
  );

  static const bottomLeft = TutorialOverlayPlacement(
    anchor: TutorialAnchor.bottomLeft,
  );

  static const bottomCenter = TutorialOverlayPlacement(
    anchor: TutorialAnchor.bottomCenter,
  );

  static const bottomRight = TutorialOverlayPlacement(
    anchor: TutorialAnchor.bottomRight,
  );
}

class GameplayTutorialStep {
  final GlobalKey? targetKey;
  final String text;
  final String andyAsset;

  final TutorialOverlayPlacement andyPlacement;
  final TutorialOverlayPlacement dialoguePlacement;

  /// Width of Andy relative to screen width.
  ///
  /// 0.60 means 60% of the screen width.
  final double andyWidthFactor;

  /// Width of the dialogue box relative to screen width.
  ///
  /// 0.90 means 90% of the screen width.
  final double dialogueWidthFactor;

  const GameplayTutorialStep({
    required this.targetKey,
    required this.text,
    required this.andyAsset,
    this.andyPlacement = TutorialPositions.bottomLeft,
    this.dialoguePlacement = TutorialPositions.topCenter,
    this.andyWidthFactor = 0.60,
    this.dialogueWidthFactor = 0.90,
  });
}

class GameplayTutorialOverlay extends StatefulWidget {
  const GameplayTutorialOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
    required this.onSkip,
  });

  final List<GameplayTutorialStep> steps;
  final VoidCallback onFinish;
  final VoidCallback onSkip;

  @override
  State<GameplayTutorialOverlay> createState() =>
      _GameplayTutorialOverlayState();
}

class _GameplayTutorialOverlayState extends State<GameplayTutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _index = 0;

  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;

  @override
  void initState() {
    super.initState();

    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _jumpAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: -18).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -18, end: 0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 55,
      ),
    ]).animate(_jumpController);

    _playJump();
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  void _playJump() {
    _jumpController.forward(from: 0);
  }

  Rect? _targetRect(GlobalKey? key) {
    if (key == null) return null;

    final ctx = key.currentContext;
    if (ctx == null) return null;

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    final topLeft = renderObject.localToGlobal(Offset.zero);
    return topLeft & renderObject.size;
  }

  void _next() {
    unawaited(SfxController.instance.playMenuPress());

    if (_index >= widget.steps.length - 1) {
      widget.onFinish();
      return;
    }

    setState(() {
      _index++;
    });

    _playJump();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final rect = _targetRect(step.targetKey);
    final size = MediaQuery.of(context).size;

    final mascotWidth = (size.width * step.andyWidthFactor)
        .clamp(120.0, size.width * 0.78)
        .toDouble();

    final dialogueWidth = (size.width * step.dialogueWidthFactor)
        .clamp(220.0, size.width - 36)
        .toDouble();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SpotlightPainter(rect),
              ),
            ),

            if (rect != null)
              Positioned.fromRect(
                rect: rect.inflate(10),
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.white24,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            _AnchoredTutorialItem(
              placement: step.dialoguePlacement,
              width: dialogueWidth,
              child: _SpeechBubble(
                text: step.text,
                anchor: step.dialoguePlacement.anchor,
              ),
            ),

            _AnchoredTutorialItem(
              placement: step.andyPlacement,
              width: mascotWidth,
              child: AnimatedBuilder(
                animation: _jumpAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _jumpAnimation.value),
                    child: child,
                  );
                },
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Image.asset(
                      step.andyAsset,
                      key: ValueKey(step.andyAsset),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              right: 18,
              bottom: 18,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _index == widget.steps.length - 1
                        ? 'Tap to finish'
                        : 'Tap to continue',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.black.withOpacity(0.45),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      unawaited(SfxController.instance.playMenuBack());
                      widget.onSkip();
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
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

class _AnchoredTutorialItem extends StatelessWidget {
  const _AnchoredTutorialItem({
    required this.placement,
    required this.width,
    required this.child,
  });

  final TutorialOverlayPlacement placement;
  final double width;
  final Widget child;

  Alignment _alignmentFor(TutorialAnchor anchor) {
    switch (anchor) {
      case TutorialAnchor.topLeft:
        return Alignment.topLeft;
      case TutorialAnchor.topCenter:
        return Alignment.topCenter;
      case TutorialAnchor.topRight:
        return Alignment.topRight;
      case TutorialAnchor.centerLeft:
        return Alignment.centerLeft;
      case TutorialAnchor.center:
        return Alignment.center;
      case TutorialAnchor.centerRight:
        return Alignment.centerRight;
      case TutorialAnchor.bottomLeft:
        return Alignment.bottomLeft;
      case TutorialAnchor.bottomCenter:
        return Alignment.bottomCenter;
      case TutorialAnchor.bottomRight:
        return Alignment.bottomRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SafeArea(
        child: Padding(
          padding: placement.margin,
          child: AnimatedAlign(
            alignment: _alignmentFor(placement.anchor),
            duration: placement.duration,
            curve: placement.curve,
            child: AnimatedContainer(
              duration: placement.duration,
              curve: placement.curve,
              width: width,
              transform: Matrix4.translationValues(
                placement.offset.dx,
                placement.offset.dy,
                0,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
    required this.anchor,
  });

  final String text;
  final TutorialAnchor anchor;

  bool get _tailOnRight {
    return anchor == TutorialAnchor.topRight ||
        anchor == TutorialAnchor.centerRight ||
        anchor == TutorialAnchor.bottomRight;
  }

  bool get _tailOnTop {
    return anchor == TutorialAnchor.bottomLeft ||
        anchor == TutorialAnchor.bottomCenter ||
        anchor == TutorialAnchor.bottomRight;
  }

  @override
  Widget build(BuildContext context) {
    const tailSpace = 22.0;

    return CustomPaint(
      painter: _PixelSpeechBubblePainter(
        tailOnTop: _tailOnTop,
        tailOnRight: _tailOnRight,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          _tailOnTop ? 22 + tailSpace : 22,
          22,
          _tailOnTop ? 22 : 22 + tailSpace,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,

            // Optional:
            // If you have a pixel font in pubspec.yaml,
            // uncomment this and replace with your font family.
            // fontFamily: 'PressStart2P',
          ),
        ),
      ),
    );
  }
}

class _PixelSpeechBubblePainter extends CustomPainter {
  const _PixelSpeechBubblePainter({
    required this.tailOnTop,
    required this.tailOnRight,
  });

  final bool tailOnTop;
  final bool tailOnRight;

  @override
  void paint(Canvas canvas, Size size) {
    const tailHeight = 18.0;
    const corner = 12.0;

    final bubbleTop = tailOnTop ? tailHeight : 0.0;
    final bubbleBottom = tailOnTop ? size.height : size.height - tailHeight;

    final bubbleRect = Rect.fromLTRB(
      0,
      bubbleTop,
      size.width,
      bubbleBottom,
    );

    final bubblePath = _pixelRectPath(bubbleRect, corner);
    final tailPath = _tailPath(bubbleRect, tailHeight);

    final fullPath = Path()
      ..addPath(bubblePath, Offset.zero)
      ..addPath(tailPath, Offset.zero);

    final shadowPath = fullPath.shift(const Offset(5, 5));

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final fillPaint = Paint()
      ..color = const Color(0xFF21103A)
      ..style = PaintingStyle.fill;

    final outerBorderPaint = Paint()
      ..color = const Color(0xFF05000A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.square;

    final neonBorderPaint = Paint()
      ..color = const Color.fromARGB(255, 183, 94, 255)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.square;

    final innerHighlightPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 88, 222)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeJoin = StrokeJoin.miter
      ..strokeCap = StrokeCap.square;

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(fullPath, fillPaint);
    canvas.drawPath(fullPath, outerBorderPaint);
    canvas.drawPath(fullPath, neonBorderPaint);

    final innerRect = bubbleRect.deflate(10);
    final innerPath = _pixelRectPath(innerRect, 8);
    canvas.drawPath(innerPath, innerHighlightPaint);

    _drawPixelSparkles(canvas, bubbleRect);
    _drawScanLines(canvas, bubbleRect);
  }

  Path _pixelRectPath(Rect rect, double corner) {
    return Path()
      ..moveTo(rect.left + corner, rect.top)
      ..lineTo(rect.right - corner, rect.top)
      ..lineTo(rect.right - corner, rect.top + corner)
      ..lineTo(rect.right, rect.top + corner)
      ..lineTo(rect.right, rect.bottom - corner)
      ..lineTo(rect.right - corner, rect.bottom - corner)
      ..lineTo(rect.right - corner, rect.bottom)
      ..lineTo(rect.left + corner, rect.bottom)
      ..lineTo(rect.left + corner, rect.bottom - corner)
      ..lineTo(rect.left, rect.bottom - corner)
      ..lineTo(rect.left, rect.top + corner)
      ..lineTo(rect.left + corner, rect.top + corner)
      ..close();
  }

  Path _tailPath(Rect bubbleRect, double tailHeight) {
    final centerX = tailOnRight
        ? bubbleRect.right - 58
        : bubbleRect.left + 58;

    const halfWidth = 18.0;
    const step = 8.0;

    if (tailOnTop) {
      final y = bubbleRect.top;

      return Path()
        ..moveTo(centerX - halfWidth, y)
        ..lineTo(centerX - halfWidth, y - step)
        ..lineTo(centerX - step, y - step)
        ..lineTo(centerX - step, y - tailHeight)
        ..lineTo(centerX + step, y - tailHeight)
        ..lineTo(centerX + step, y - step)
        ..lineTo(centerX + halfWidth, y - step)
        ..lineTo(centerX + halfWidth, y)
        ..close();
    } else {
      final y = bubbleRect.bottom;

      return Path()
        ..moveTo(centerX - halfWidth, y)
        ..lineTo(centerX - halfWidth, y + step)
        ..lineTo(centerX - step, y + step)
        ..lineTo(centerX - step, y + tailHeight)
        ..lineTo(centerX + step, y + tailHeight)
        ..lineTo(centerX + step, y + step)
        ..lineTo(centerX + halfWidth, y + step)
        ..lineTo(centerX + halfWidth, y)
        ..close();
    }
  }

  void _drawPixelSparkles(Canvas canvas, Rect rect) {
    final sparklePaint = Paint()
      ..color = const Color(0xFF00F5FF)
      ..style = PaintingStyle.fill;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFFD23F)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(rect.right - 36, rect.top + 18, 6, 6),
      sparklePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(rect.right - 24, rect.top + 30, 4, 4),
      yellowPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(rect.left + 22, rect.bottom - 30, 5, 5),
      sparklePaint,
    );
  }

  void _drawScanLines(Canvas canvas, Rect rect) {
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.045)
      ..strokeWidth = 1;

    for (double y = rect.top + 18; y < rect.bottom - 12; y += 8) {
      canvas.drawLine(
        Offset(rect.left + 16, y),
        Offset(rect.right - 16, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelSpeechBubblePainter oldDelegate) {
    return oldDelegate.tailOnTop != tailOnTop ||
        oldDelegate.tailOnRight != tailOnRight;
  }
}


class _SpotlightPainter extends CustomPainter {
  final Rect? rect;

  _SpotlightPainter(this.rect);

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.72);

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);

    if (rect != null) {
      final clearPaint = Paint()..blendMode = BlendMode.clear;
      final rrect = RRect.fromRectAndRadius(
        rect!.inflate(6),
        const Radius.circular(18),
      );
      canvas.drawRRect(rrect, clearPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.rect != rect;
  }
}