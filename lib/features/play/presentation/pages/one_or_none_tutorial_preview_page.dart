import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../../tutorial/app_tutorial_controller.dart';
import '../../../tutorial/tutorial_targets.dart';

class OneOrNoneTutorialPreviewPage extends StatelessWidget {
  const OneOrNoneTutorialPreviewPage({super.key});

  static const Color _passOrange = Color(0xFFFF6B00);
  static const Color _brownText = Color(0xFF8A5200);
  static const Color _choiceOne = Color(0xFF00D3FF);
  static const Color _choiceZero = Color(0xFFFFBC19);

  Widget _buildScoreText(double width) {
    return Center(
      child: Text(
        '0',
        style: TextStyle(
          fontSize: width * 0.085,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE6F7D9),
          shadows: const [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivesDisplay(double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(right: width * 0.01),
              child: Icon(
                Icons.favorite,
                color: const Color(0xFFFF3B5C),
                size: width * 0.07,
                shadows: const [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(0, 1.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            );
          }),
        ),
        SizedBox(height: width * 0.008),
        Text(
          '  LIVES 3/3',
          style: TextStyle(
            fontSize: width * 0.028,
            fontWeight: FontWeight.w900,
            color: _brownText,
            letterSpacing: 0.8,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultiplierText(double width) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFE28A).withOpacity(0.7),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mult: x1.0',
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFE28A),
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Streak: 0',
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramPlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.24),
            width: 2,
          ),
        ),
        child: const Icon(
          Icons.account_tree_rounded,
          color: Colors.white,
          size: 110,
        ),
      ),
    );
  }

  Widget _buildValuesBar() {
    return SizedBox(
      height: 72,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: const Text(
          'A = 1    B = 0    C = 1',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  Widget _buildPassStrip() {
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFD8C6B5),
          width: 2,
        ),
      ),
      child: const Text(
        'PASSES LEFT: 5',
        style: TextStyle(
          color: _passOrange,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildBinaryChoiceButton({
    required String label,
    required Color color,
    required double width,
    required double height,
  }) {
    return BeveledMenuButton(
      label: label,
      color: color,
      width: width,
      height: height,
      textColor: Colors.white,
      fontSize: 72,
      onTap: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sidePadding = 18;
    final double gap = 12;
    final double choiceButtonWidth =
        (size.width - (sidePadding * 2) - gap) / 2;
    const double choiceButtonHeight = 180;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.purpleBg,
        child: TutorialPageReady(
          routeName: AppRoutes.oneOrNoneTutorialPreview,
          child: SizedBox.expand(
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                visualDensity: VisualDensity.compact,
                                iconSize: 24,
                                icon: Image.asset(
                                  AppAssets.backBtn,
                                  width: 24,
                                  height: 24,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              const MusicButton(size: 26),
                            ],
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 0.78,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final w = constraints.maxWidth;
                              final h = constraints.maxHeight;

                              return Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      AppAssets.diagramContainerGreen2,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    left: w * 0.055,
                                    top: h * 0.04,
                                    width: w * 0.28,
                                    height: h * 0.13,
                                    child: Container(
                                      key: TutorialTargets.onePreviewLives,
                                      child: _buildLivesDisplay(w),
                                    ),
                                  ),
                                  Positioned(
                                    left: w * 0.315,
                                    right: w * 0.4,
                                    top: h * 0.02,
                                    height: h * 0.11,
                                    child: Container(
                                      key: TutorialTargets
                                          .onePreviewMultiplierStreak,
                                      child: _buildMultiplierText(w),
                                    ),
                                  ),
                                  Positioned(
                                    right: w * 0.07,
                                    top: h * 0.055,
                                    width: w * 0.31,
                                    height: h * 0.09,
                                    child: Container(
                                      key: TutorialTargets.onePreviewScore,
                                      child: _buildScoreText(w),
                                    ),
                                  ),
                                  Positioned(
                                    left: w * 0.12,
                                    right: w * 0.12,
                                    top: h * 0.18,
                                    height: h * 0.55,
                                    child: Container(
                                      key: TutorialTargets.onePreviewDiagram,
                                      child: _buildDiagramPlaceholder(),
                                    ),
                                  ),
                                  Positioned(
                                    left: w * 0.07,
                                    right: w * 0.07,
                                    bottom: h * 0.035,
                                    height: h * 0.16,
                                    child: Container(
                                      key: TutorialTargets.onePreviewValues,
                                      child: Center(
                                        child: _buildValuesBar(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            sidePadding,
                            0,
                            sidePadding,
                            0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    key: TutorialTargets.onePreviewPass,
                                    child: BeveledMenuButton(
                                      label: 'PASS',
                                      color: _passOrange,
                                      width: 120,
                                      height: 50,
                                      textColor: Colors.white,
                                      fontSize: 20,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildPassStrip()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                key: TutorialTargets.onePreviewButtons,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildBinaryChoiceButton(
                                        label: '1',
                                        color: _choiceOne,
                                        width: choiceButtonWidth,
                                        height: choiceButtonHeight,
                                      ),
                                    ),
                                    SizedBox(width: gap),
                                    Expanded(
                                      child: _buildBinaryChoiceButton(
                                        label: '0',
                                        color: _choiceZero,
                                        width: choiceButtonWidth,
                                        height: choiceButtonHeight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
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