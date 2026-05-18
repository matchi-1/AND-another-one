import 'package:flutter/material.dart';

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
                    onTap: widget.onSkip,
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
    final bubble = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: Color(0xFF222222),
        ),
      ),
    );

    final tail = Padding(
      padding: EdgeInsets.only(
        left: _tailOnRight ? 0 : 46,
        right: _tailOnRight ? 46 : 0,
      ),
      child: Align(
        alignment: _tailOnRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Transform.rotate(
          angle: 0.78,
          child: Container(
            width: 20,
            height: 20,
            color: Colors.white,
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _tailOnTop
          ? [
              tail,
              const SizedBox(height: 2),
              bubble,
            ]
          : [
              bubble,
              const SizedBox(height: 2),
              tail,
            ],
    );
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