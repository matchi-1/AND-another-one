import 'package:and_another_one/shared/widgets/pause_icon_button.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../../tutorial/app_tutorial_controller.dart';
import '../../../tutorial/tutorial_targets.dart';

class GatekeepingTutorialPreviewPage extends StatelessWidget {
  const GatekeepingTutorialPreviewPage({super.key});

  Widget _buildInfoText(String text, Color color, double fontSize) {
    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: color,
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

  Widget _buildExpressionBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'A',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'B',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildOperatorButton({
    required String label,
    required Color color,
  }) {
    return BeveledMenuButton(
      label: label,
      color: color,
      width: 150,
      height: 96,
      textColor: const Color(0xFF8A5200),
      fontSize: 42,
      onTap: () {},
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Mult: x1.0',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: width * 0.040,
              fontWeight: FontWeight.w900,
              color: const Color(0xFFFFE28A),
              height: 1.0,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 1.5),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Streak: 0',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: width * 0.040,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 1.5),
                  blurRadius: 2,
                ),
              ],
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
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/images/diagrams/basic/basic_1.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        useGrid: false,
        child: TutorialPageReady(
          routeName: AppRoutes.gatekeepingTutorialPreview,
          child: SizedBox.expand(
            child: Stack(
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
                              PauseIconButton( key: TutorialTargets.previewBack, onTap: () {}),

                              IconButton(
                              key: TutorialTargets.previewHelp,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              iconSize: 24,
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                              onPressed: () => (), //_showGatekeepingTutorial(),
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
                                      AppAssets.diagramContainerGreen1,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Positioned(
                                    left: w * 0.055,
                                    top: h * 0.045,
                                    width: w * 0.18,
                                    height: h * 0.10,
                                    child: Container(
                                      key: TutorialTargets.previewTimer,
                                      child: _buildInfoText(
                                        '60',
                                        const Color(0xFF8A5200),
                                        w * 0.10,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    left: w * 0.24,
                                    right: w * 0.4,
                                    top: h * 0.02,
                                    height: h * 0.11,
                                    child: Container(
                                      key: TutorialTargets.previewMultiplierStreak,
                                      child: _buildMultiplierText(w),
                                    ),
                                  ),

                                  Positioned(
                                    key: TutorialTargets.previewScore,
                                    right: w * 0.07,
                                    top: h * 0.055,
                                    width: w * 0.31,
                                    height: h * 0.09,
                                    child: _buildInfoText(
                                      '0',
                                      const Color(0xFFE6F7D9),
                                      w * 0.085,
                                    ),
                                  ),

                                  Positioned(
                                  left: w * 0.12,
                                  right: w * 0.12,
                                  top: h * 0.18,
                                  height: h * 0.55,
                                  child: Container(
                                    key: TutorialTargets.previewDiagram,
                                    child: _buildDiagramPlaceholder(),
                                  ),
                                ),

                                  Positioned(
                                    left: w * 0.12,
                                    right: w * 0.12,
                                    bottom: h * 0.08,
                                    height: h * 0.08,
                                    child: Container(
                                      key: TutorialTargets.previewExpression,
                                      alignment: Alignment.center,
                                      child: _buildExpressionBar(),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    key: TutorialTargets.previewPass,
                                    child: BeveledMenuButton(
                                      label: 'PASS',
                                      color: const Color(0xFFFF6B00),
                                      width: 120,
                                      height: 50,
                                      textColor: Colors.white,
                                      fontSize: 20,
                                      onTap: () {},
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Container(
                                      height: 32,
                                      alignment: Alignment.centerLeft,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      margin: const EdgeInsets.only(bottom: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.beigeBg,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFD8C6B5), width: 2),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'PASSES LEFT: 5',
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.visible,
                                          style: const TextStyle(
                                            color: Color(0xFFFF6B00),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BeveledMenuButton(
                                    key: TutorialTargets.previewBackspace,
                                    label: '⌫',
                                    color: Colors.grey,
                                    width: 80,
                                    height: 50,
                                    textColor: Colors.white,
                                    fontSize: 30,
                                    onTap: () {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                key: TutorialTargets.previewButtons,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildOperatorButton(label: '+', color: AppColors.orangeButton),
                                    _buildOperatorButton(label: '•', color: AppColors.purpleButton),
                                    _buildOperatorButton(label: '¬', color: AppColors.redButton),
                                    _buildOperatorButton(label: '⊕', color: AppColors.pinkButton),
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