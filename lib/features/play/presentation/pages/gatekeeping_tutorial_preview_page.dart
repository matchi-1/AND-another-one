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
                              Container(
                                key: TutorialTargets.previewBack,
                                child: IconButton(
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
                                          color: Color(0xFFFF6B00),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BeveledMenuButton(
                                    label: '←',
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