import 'dart:async';

import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../core/theme/app_colors.dart';

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
    required this.difficultyDescription,
    required this.guideOverlayAssetPath,
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
  final String difficultyDescription;
  final String guideOverlayAssetPath;

  final bool waitingForTap;
  final String? spriteAssetPath;
  final VoidCallback onTap;

  final double spriteOpacity;
  final double spriteScale;
  final Duration spriteScaleDuration;
  final Duration spriteFadeDuration;

  double get _contentTopFactor {
    switch (difficultyLabel.toUpperCase()) {
      case 'BASIC':
        return 0.535;

      case 'LOGIC':
        return 0.510;

      case 'MANIC':
        return 0.490;

      default:
        return 0.535;
    }
  }

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
                  ? _buildGuideCard(context)
                  : _buildCountdownSprite(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = (size.width * 1.25).clamp(360.0, 470.0);
    final double cardHeight = cardWidth * 1.75;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Image.asset(
              guideOverlayAssetPath,
              fit: BoxFit.contain,
            ),
          ),

          Positioned(
            top: cardHeight * _contentTopFactor,
            left: cardWidth * 0.12,
            right: cardWidth * 0.12,
            child: Column(
              children: [
                Text(
                  '$modeLabel: $difficultyLabel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFFFE28A),
                    fontSize: cardWidth * 0.042,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                    shadows: const [
                      Shadow(
                        color: Colors.black38,
                        blurRadius: 2,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  difficultyDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: cardWidth * 0.032,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    letterSpacing: 0.15,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Tap anywhere to start',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: cardWidth * 0.030,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownSprite() {
    return Center(
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
    );
  }
}


class PauseOverlay extends StatefulWidget {
  const PauseOverlay({
    super.key,
    required this.backgroundAssetPath,
    required this.onResume,
    required this.onRetry,
    required this.onExitToMenu,
  });

  final String backgroundAssetPath;
  final VoidCallback onResume;
  final VoidCallback onRetry;
  final VoidCallback onExitToMenu;

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay> {
  _PauseConfirmMode _confirmMode = _PauseConfirmMode.none;

  bool get _isConfirming => _confirmMode != _PauseConfirmMode.none;

  String get _confirmTitle {
    switch (_confirmMode) {
      case _PauseConfirmMode.retry:
        return 'RETRY GAME?';
      case _PauseConfirmMode.exit:
        return 'EXIT TO MENU?';
      case _PauseConfirmMode.none:
        return '';
    }
  }

  String get _confirmMessage {
    switch (_confirmMode) {
      case _PauseConfirmMode.retry:
        return 'Your current progress will be lost.';
      case _PauseConfirmMode.exit:
        return 'Your current game will end.';
      case _PauseConfirmMode.none:
        return '';
    }
  }

  VoidCallback get _confirmAction {
    switch (_confirmMode) {
      case _PauseConfirmMode.retry:
        return widget.onRetry;

      case _PauseConfirmMode.exit:
        return widget.onExitToMenu;

      case _PauseConfirmMode.none:
        return () {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = (size.width * 0.9).clamp(390.0, 450.0);
    final double cardHeight = cardWidth * 1.60;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.72),
        child: Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    widget.backgroundAssetPath,
                    fit: BoxFit.contain,
                  ),
                ),

                Positioned(
                  top: cardHeight * 0.50,
                  left: 0,
                  right: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _isConfirming
                        ? _buildConfirmContent(cardWidth)
                        : _buildPauseButtons(cardWidth),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButtons(double cardWidth) {
    return Column(
      key: const ValueKey('pause-buttons'),

      children: [
        const SizedBox(height: 40),

        BeveledMenuButton(
          label: 'RESUME',
          color: AppColors.greenButton,
          width: cardWidth * 0.65,
          height: 48,
          textColor: Colors.white,
          fontSize: 17,
          onTap: widget.onResume,
        ),

        const SizedBox(height: 5),

        BeveledMenuButton(
          label: 'RETRY',
          color: AppColors.orangeButton,
          width: cardWidth * 0.65,
          height: 48,
          textColor: Colors.white,
          fontSize: 17,
          onTap: () {
            setState(() {
              unawaited(SfxController.instance.playMenuPress());
              _confirmMode = _PauseConfirmMode.retry;
            });
          },
        ),

        const SizedBox(height: 5),

        BeveledMenuButton(
          label: 'EXIT TO MENU',
          color: AppColors.greyButton,
          width: cardWidth * 0.65,
          height: 48,
          textColor: Colors.white,
          fontSize: 17,
          onTap: () {
            setState(() {
              unawaited(SfxController.instance.playMenuPress());
              _confirmMode = _PauseConfirmMode.exit;
            });
          },
        ),
      ],
    );
  }

  Widget _buildConfirmContent(double cardWidth) {
    return Column(
      key: const ValueKey('confirm-content'),
      children: [
        const SizedBox(height: 50),
        Text(
          _confirmTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        Text(
          _confirmMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 18),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BeveledMenuButton(
              label: 'NO',
              color: AppColors.greyButton,
              width: cardWidth * 0.30,
              height: 44,
              textColor: Colors.white,
              fontSize: 18,
              onTap: () {
                setState(() {
                  unawaited(SfxController.instance.playMenuBack());
                  _confirmMode = _PauseConfirmMode.none;
                });
              },
            ),

            const SizedBox(width: 12),

            BeveledMenuButton(
              label: 'YES',
              color: AppColors.redButton,
              width: cardWidth * 0.30,
              height: 44,
              textColor: Colors.white,
              fontSize: 18,
              onTap: _confirmAction,
            ),
          ],
        ),
      ],
    );
  }
}

enum _PauseConfirmMode {
  none,
  retry,
  exit,
}


class GameResultOverlay extends StatelessWidget {
  final int highestStreak;
  const GameResultOverlay({
    super.key,
    required this.backgroundAssetPath,
    required this.modeLabel,
    required this.difficultyLabel,
    required this.score,
    required this.correctCount,
    required this.wrongAttempts,
    required this.passesUsed,
    required this.onRetry,
    required this.onLeaderboards,
    required this.onBackToMenu,
    required this.highestStreak,
  });

  final String backgroundAssetPath;
  final String modeLabel;
  final String difficultyLabel;
  final int score;
  final int correctCount;
  final int wrongAttempts;
  final int passesUsed;

  final VoidCallback onRetry;
  final VoidCallback onLeaderboards;
  final VoidCallback onBackToMenu;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final double cardWidth = (size.width * 1.5).clamp(360.0, 410.0);
    final double cardHeight = cardWidth * 1.85;

    return Positioned.fill(
      child: Material(
        color: Colors.black.withOpacity(0.72),
        child: Center(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Image.asset(
                    backgroundAssetPath,
                    fit: BoxFit.contain,
                  ),
                ),

                Positioned(
                  top: cardHeight * 0.409,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.3,
                        ),
                      ),
                      child: Text(
                        '${modeLabel.toUpperCase()}: ${difficultyLabel.toUpperCase()}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.4,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: cardHeight * 0.475,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        score.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          height: 0.95,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SCORE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: cardHeight * 0.610,
                  left: cardWidth * 0.24,
                  right: cardWidth * 0.16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GameOverStatText('Correct: $correctCount'),
                      _GameOverStatText('Wrong Attempts: $wrongAttempts'),
                      _GameOverStatText('Passes Used: $passesUsed'),
                    ],
                  ),
                ),

                Positioned(
                  top: cardHeight * 0.730,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      BeveledMenuButton(
                        label: 'RETRY',
                        color: AppColors.orangeButton,
                        width: cardWidth * 0.5,
                        height: 40,
                        textColor: Colors.white,
                        fontSize: 16,
                        onTap: onRetry,
                      ),

                      const SizedBox(height: 5),

                      BeveledMenuButton(
                        label: 'LEADERBOARDS',
                        color: AppColors.greenButton,
                        width: cardWidth * 0.5,
                        height: 40,
                        textColor: Colors.white,
                        fontSize: 16,
                        onTap: onLeaderboards,
                      ),

                      const SizedBox(height: 10),

                      BeveledMenuButton(
                        label: 'BACK TO MENU',
                        color: AppColors.greyButton,
                        width: cardWidth * 0.4,
                        height: 40,
                        textColor: Colors.white,
                        fontSize: 15,
                        onTap: onBackToMenu,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameOverStatText extends StatelessWidget {
  const _GameOverStatText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0.1,
      ),
    );
  }
}