import 'package:flutter/material.dart';

class ReactionSpriteLayer extends StatelessWidget {
  const ReactionSpriteLayer({
    super.key,
    required this.assetPath,
    required this.opacity,
    required this.scale,
    required this.scaleDuration,
    required this.scaleCurve,
    this.width = 190,
  });

  final String assetPath;
  final double opacity;
  final double scale;
  final Duration scaleDuration;
  final Curve scaleCurve;
  final double width;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOutCubic,
          opacity: opacity,
          child: AnimatedScale(
            duration: scaleDuration,
            curve: scaleCurve,
            scale: scale,
            child: Image.asset(
              assetPath,
              width: width,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class PreGameOverlay extends StatelessWidget {
  const PreGameOverlay({
    super.key,
    required this.modeLabel,
    required this.difficultyLabel,
    required this.reminderText,
    required this.waitingForTap,
    required this.spriteAssetPath,
    required this.onTap,
    required this.spriteOpacity,
    required this.spriteScale,
    required this.spriteScaleDuration,
    required this.spriteFadeDuration,
  });

  final String modeLabel;
  final String difficultyLabel;
  final String reminderText;
  final bool waitingForTap;
  final String? spriteAssetPath;
  final VoidCallback onTap;
  final double spriteOpacity;
  final double spriteScale;
  final Duration spriteScaleDuration;
  final Duration spriteFadeDuration;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.80),
        child: InkWell(
          onTap: onTap,
          child: SafeArea(
            child: Center(
              child: waitingForTap
    ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              modeLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              difficultyLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFE28A),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.18),
                  width: 1.5,
                ),
              ),
              child: Text(
                reminderText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Tap anywhere to start',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      )
    : Center(
        child: spriteAssetPath == null
            ? const SizedBox.shrink()
            : AnimatedOpacity(
                duration: spriteFadeDuration,
                curve: Curves.easeInOutCubic,
                opacity: spriteOpacity,
                child: AnimatedScale(
                  duration: spriteScaleDuration,
                  curve: Curves.easeOutCubic,
                  scale: spriteScale,
                  child: Image.asset(
                    spriteAssetPath!,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
      ),
            ),
          ),
        ),
      ),
    );
  }
}