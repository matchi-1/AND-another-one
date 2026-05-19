import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../core/theme/app_colors.dart';




class HelpOverlay extends StatelessWidget {
  const HelpOverlay({super.key, required this.onClose});

  final VoidCallback onClose;

  static const List<_GateLegendData> _gateLegends = [
    _GateLegendData(
      label: 'AND',
      imagePath: 'assets/images/logic_guide/symbols_and.png',
      color: Color(0xFF196EEA),
      imageXOffset: -10,
    ),
    _GateLegendData(
      label: 'OR',
      imagePath: 'assets/images/logic_guide/symbols_or.png',
      color: Color(0xFFFF9800),
      imageXOffset: -6,
    ),
    _GateLegendData(
      label: 'NOT',
      imagePath: 'assets/images/logic_guide/symbols_not.png',
      color: Color(0xFFFF2E2E),
      imageXOffset: -3,
    ),
    _GateLegendData(
      label: 'NOR',
      imagePath: 'assets/images/logic_guide/symbols_xor.png',
      color: Color(0xFF2FAF1D), 
    ),
    _GateLegendData(
      label: 'NAND',
      imagePath: 'assets/images/logic_guide/symbols_nand.png',
      color: Color(0xFF8B2DE2),
    ),
    _GateLegendData(
      label: 'XOR',
      imagePath: 'assets/images/logic_guide/symbols_nor.png',
      color: Color(0xFFD13ED6),
      imageXOffset: 3,
    ),
    _GateLegendData(
      label: 'XNOR',
      imagePath: 'assets/images/logic_guide/symbols_xnor.png',
      color: Color(0xFF14AFA7),
    ),
  ];

  static const List<_SymbolNameData> _symbolNames = [
    _SymbolNameData(
      label: 'AND',
      imagePath: 'assets/images/logic_guide/symbol_dot.png',
    ),
    _SymbolNameData(
      label: 'OR',
      imagePath: 'assets/images/logic_guide/symbol_plus.png',
    ),
    _SymbolNameData(
      label: 'NOT',
      imagePath: 'assets/images/logic_guide/symbol_tilde.png',
    ),
    _SymbolNameData(
      label: 'NOR',
      imagePath: 'assets/images/logic_guide/symbol_down.png',
    ),
    _SymbolNameData(
      label: 'NAND',
      imagePath: 'assets/images/logic_guide/symbol_up.png',
    ),
    _SymbolNameData(
      label: 'XOR',
      imagePath: 'assets/images/logic_guide/symbol_xor.png',
    ),
    _SymbolNameData(
      label: 'XAND',
      imagePath: 'assets/images/logic_guide/symbol_xand.png',
    ),
    _SymbolNameData(
      label: 'XNOR',
      imagePath: 'assets/images/logic_guide/symbol_xnor.png',
    ),
  ];

  double _scaled(double value, double scale) => value * scale;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = (min(size.width, size.height) / 390).clamp(0.82, 1.15).toDouble();

    return Material(
      color: Colors.black.withOpacity(0.68),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _scaled(14, scale),
              vertical: _scaled(12, scale),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: min(size.width * 0.94, 560.0),
                maxHeight: size.height * 0.86,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_scaled(18, scale)),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(
                    sigmaX: 3,
                    sigmaY: 3,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.beigeBg.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(_scaled(18, scale)),
                      border: Border.all(
                        color: const Color(0xFFFF9F00).withOpacity(0.88),
                        width: _scaled(4, scale),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.20),
                          blurRadius: 10,
                          spreadRadius: -2,
                          offset: const Offset(-3, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(scale),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              _scaled(14, scale),
                              _scaled(12, scale),
                              _scaled(14, scale),
                              _scaled(16, scale),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSectionTitle('GATE LEGENDS', scale),
                                SizedBox(height: _scaled(8, scale)),
                                _buildGateLegends(scale),
                                SizedBox(height: _scaled(16, scale)),
                                _buildSectionTitle('SYMBOL NAMES', scale),
                                SizedBox(height: _scaled(8, scale)),
                                _buildSymbolNamesTable(scale),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildHeader(double scale) {
    return Container(
      padding: EdgeInsets.only(
        left: _scaled(18, scale),
        right: _scaled(8, scale),
        top: _scaled(10, scale),
        bottom: _scaled(10, scale),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_scaled(14, scale)),
          topRight: Radius.circular(_scaled(14, scale)),
        ),
        color: const Color(0xFF196EEA).withOpacity(0.68),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFFF9F00), width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'GATE HELP',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _scaled(22, scale),
                fontWeight: FontWeight.w900,
                fontFamily: 'Nunito',
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(12, scale),
        vertical: _scaled(7, scale),
      ),
      decoration: BoxDecoration(
        color: AppColors.pinkButton.withOpacity(0.68),
        borderRadius: BorderRadius.circular(_scaled(10, scale)),
        border: Border.all(
          color: const Color(0xFFFF9F00),
          width: _scaled(2.2, scale),
        ),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _scaled(16, scale),
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildGateLegends(double scale) {
    return Container(
      padding: EdgeInsets.all(_scaled(10, scale)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(_scaled(12, scale)),
        border: Border.all(
          color: const Color(0xFFD8C6B5),
          width: _scaled(2, scale),
        ),
      ),
      child: Wrap(
        spacing: _scaled(10, scale),
        runSpacing: _scaled(10, scale),
        alignment: WrapAlignment.center,
        children: _gateLegends
            .map((gate) => _buildGateLegendItem(gate, scale))
            .toList(),
      ),
    );
  }

  Widget _buildGateLegendItem(_GateLegendData gate, double scale) {
    return SizedBox(
      width: _scaled(140, scale),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.translate(
            offset: Offset(_scaled(gate.imageXOffset, scale), 0),
            child: Image.asset(
              gate.imagePath,
              width: _scaled(54, scale),
              height: _scaled(54, scale),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: _scaled(8, scale)),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                gate.label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: _scaled(20, scale),
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito',
                  color: gate.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolNamesTable(double scale) {
    final rowHeight = _scaled(35, scale);
    final symbolHeight = _scaled(22, scale);

    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.82,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
            color: const Color(0xFFD66AA9),
            width: _scaled(1.7, scale),
          ),
          columnWidths: const {
            0: FlexColumnWidth(1.25),
            1: FlexColumnWidth(1),
          },
          children: _symbolNames
              .map(
                (row) => TableRow(
                  children: [
                    SizedBox(
                      height: rowHeight,
                      child: Center(
                        child: Text(
                          row.label,
                          style: TextStyle(
                            fontSize: _scaled(15, scale),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFCF6AA5),
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: rowHeight,
                      child: Center(
                        child: Image.asset(
                          row.imagePath,
                          height: _symbolHeightForLabel(
                            row.label,
                            symbolHeight,
                            scale,
                          ),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  double _symbolHeightForLabel(String label, double baseHeight, double scale) {
    if (label == 'AND' || label == 'NOT') {
      return (baseHeight * 0.5).clamp(_scaled(6, scale), baseHeight).toDouble();
    }
    return baseHeight;
  }
}

class _GateLegendData {
  const _GateLegendData({
    required this.label,
    required this.imagePath,
    required this.color,
    this.imageXOffset = 0,
  });

  final String label;
  final String imagePath;
  final Color color;
  final double imageXOffset;
}

class _SymbolNameData {
  const _SymbolNameData({
    required this.label,
    required this.imagePath,
  });

  final String label;
  final String imagePath;
}


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

  final int highestStreak;
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
                      _GameOverStatText('Highest Streak: $highestStreak'),
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