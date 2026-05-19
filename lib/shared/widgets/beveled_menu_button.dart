import 'dart:math' as math;
import 'package:flutter/material.dart';

class BeveledMenuButton extends StatefulWidget {
  final String label;
  final Color color;
  final double width;
  final double height;
  final double fontSize;
  final Color textColor; // kept so existing usages will not break
  final VoidCallback onTap;
  final bool enabled;

  const BeveledMenuButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    required this.width,
    required this.height,
    required this.textColor,
    required this.fontSize,
    this.enabled = true,
  });

  @override
  State<BeveledMenuButton> createState() => _BeveledMenuButtonState();

  static Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return lighter.toColor();
  }
}

class _BeveledMenuButtonState extends State<BeveledMenuButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;

  Offset? _tapPosition;

  static const List<_PixelBurstParticle> _particles = [
    _PixelBurstParticle(direction: Offset(-1.00, -0.65), distance: 42, size: 6),
    _PixelBurstParticle(direction: Offset(-0.55, -1.00), distance: 38, size: 5),
    _PixelBurstParticle(direction: Offset(0.15, -1.00), distance: 40, size: 6),
    _PixelBurstParticle(direction: Offset(0.85, -0.75), distance: 44, size: 5),
    _PixelBurstParticle(direction: Offset(1.00, -0.10), distance: 39, size: 7),
    _PixelBurstParticle(direction: Offset(0.75, 0.55), distance: 42, size: 6),
    _PixelBurstParticle(direction: Offset(0.10, 1.00), distance: 36, size: 5),
    _PixelBurstParticle(direction: Offset(-0.70, 0.75), distance: 41, size: 6),
    _PixelBurstParticle(direction: Offset(-1.00, 0.15), distance: 37, size: 5),

    // extra inner burst pixels
    _PixelBurstParticle(direction: Offset(0.45, -0.35), distance: 26, size: 4),
    _PixelBurstParticle(direction: Offset(-0.35, -0.45), distance: 24, size: 4),
    _PixelBurstParticle(direction: Offset(0.50, 0.30), distance: 25, size: 5),
    _PixelBurstParticle(direction: Offset(-0.45, 0.35), distance: 27, size: 5),

    // cross-direction pixels
    _PixelBurstParticle(direction: Offset(0.00, -1.00), distance: 50, size: 4),
    _PixelBurstParticle(direction: Offset(1.00, 0.00), distance: 48, size: 4),
    _PixelBurstParticle(direction: Offset(0.00, 1.00), distance: 45, size: 4),
    _PixelBurstParticle(direction: Offset(-1.00, 0.00), distance: 48, size: 4),
  ];

  @override
  void initState() {
    super.initState();

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapPosition = details.localPosition;
  }

  void _handleTap() {
    _tapController.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBurstOrigin = Offset(
      widget.width / 2,
      (widget.height - 6) / 2,
    );

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: IgnorePointer(
        ignoring: !widget.enabled,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.45,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleTapDown,
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _tapController,
              builder: (context, _) {
                final tapValue = _tapController.value;

                final pressAmount = math.sin(tapValue * math.pi);

                // Flashy arcade-style pop.
                final scale = 1.0 + (pressAmount * 0.055);

                final burstOrigin = _tapPosition ?? defaultBurstOrigin;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Stack(
                        children: [
                          _buildButtonFace(),
                        ],
                      ),
                    ),

                    // Pixel burst above the button.
                    _buildPixelBurst(burstOrigin),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonFace() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 6,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              BeveledMenuButton._lighten(widget.color, 0.10),
              widget.color,
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              offset: Offset(5, 8),
              blurRadius: 3,
            ),
          ],
        ),
        child: Stack(
          children: [
            // top gloss / bevel highlight
            Positioned(
              top: 1,
              left: 2,
              right: 3,
              child: Container(
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.20),
                    ],
                  ),
                ),
              ),
            ),

            // left highlight
            Positioned(
              top: 5,
              left: 0,
              child: Container(
                height: widget.height,
                width: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // right shadow
            Positioned(
              top: 5,
              right: 0,
              child: Container(
                height: widget.height,
                width: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.20),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // bottom shadow
            Positioned(
              bottom: 0,
              left: 2,
              right: 8,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.20),
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  // This is the important part from your original code.
                  // It ignores textColor and always keeps the label white.
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixelBurst(Offset origin) {
    final rawProgress = _tapController.value;

    if (rawProgress <= 0.0) {
      return const SizedBox.shrink();
    }

    final progress = Curves.easeOutCubic.transform(rawProgress);
    final opacity = (1.0 - rawProgress).clamp(0.0, 1.0);

    final flashOpacity = (1.0 - rawProgress * 2.8).clamp(0.0, 1.0);
    final ringSize = 18 + (rawProgress * 58);

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // quick white impact flash
            Positioned(
              left: origin.dx - 13,
              top: origin.dy - 13,
              child: Opacity(
                opacity: flashOpacity,
                child: Transform.rotate(
                  angle: rawProgress * 0.7,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // expanding square pixel ring
            Positioned(
              left: origin.dx - ringSize / 2,
              top: origin.dy - ringSize / 2,
              child: Opacity(
                opacity: opacity * 0.8,
                child: Container(
                  width: ringSize,
                  height: ringSize,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 3,
                    ),
                  ),
                ),
              ),
            ),

            // colored pixel burst
            for (int i = 0; i < _particles.length; i++)
              _buildPixel(
                particle: _particles[i],
                index: i,
                origin: origin,
                progress: progress,
                opacity: opacity,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPixel({
    required _PixelBurstParticle particle,
    required int index,
    required Offset origin,
    required double progress,
    required double opacity,
  }) {
    final dx = particle.direction.dx * particle.distance * progress;
    final dy = particle.direction.dy * particle.distance * progress;

    final pixelScale = 0.65 + (progress * 0.65);

    return Positioned(
      left: origin.dx + dx - (particle.size / 2),
      top: origin.dy + dy - (particle.size / 2),
      child: Opacity(
        opacity: opacity,
        child: Transform.scale(
          scale: pixelScale,
          child: Container(
            width: particle.size,
            height: particle.size,
            color: _pixelColor(index),
          ),
        ),
      ),
    );
  }

  Color _pixelColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.white.withValues(alpha: 0.95);
      case 1:
        return BeveledMenuButton._lighten(widget.color, 0.22)
            .withValues(alpha: 0.95);
      case 2:
        return Colors.white.withValues(alpha: 0.75);
      default:
        return Colors.black.withValues(alpha: 0.22);
    }
  }
}

class _PixelBurstParticle {
  final Offset direction;
  final double distance;
  final double size;

  const _PixelBurstParticle({
    required this.direction,
    required this.distance,
    required this.size,
  });
}