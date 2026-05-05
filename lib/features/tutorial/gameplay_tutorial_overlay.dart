import 'package:flutter/material.dart';

class GameplayTutorialStep {
  final GlobalKey? targetKey;
  final String text;

  const GameplayTutorialStep({
    required this.targetKey,
    required this.text,
  });
}

class GameplayTutorialOverlay extends StatefulWidget {
  const GameplayTutorialOverlay({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  final List<GameplayTutorialStep> steps;
  final VoidCallback onFinish;

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
    final mascotWidth = size.width * 0.60;

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

            // Speech bubble
            Positioned(
              top: size.height * 0.09,
              left: 18,
              right: 18,
              child: _SpeechBubble(
                text: step.text,
              ),
            ),

            // Big mascot at lower-left / lower-center
            Positioned(
              left: 0,
              bottom: 0,
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
                  child: Image.asset(
                    'assets/images/sprites/andy-play.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // Tap hint
            Positioned(
              right: 18,
              bottom: 18,
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

            // Optional close/skip button
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.black.withOpacity(0.45),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onFinish,
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

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 46),
          child: Transform.rotate(
            angle: 0.78,
            child: Container(
              width: 20,
              height: 20,
              color: Colors.white,
            ),
          ),
        ),
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