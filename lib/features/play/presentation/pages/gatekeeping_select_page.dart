import 'dart:async';

import 'package:and_another_one/core/audio/home_bgm_route_mixin.dart';
import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:and_another_one/shared/widgets/music_button.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../play/data/models/gatekeeping_question.dart';
import '../../../play/presentation/pages/gatekeeping_game_page.dart';
import '../../../tutorial/app_tutorial_controller.dart';
import '../../../tutorial/tutorial_targets.dart';

class GatekeepingSelectPage extends StatefulWidget {
  const GatekeepingSelectPage({super.key});

  @override
  State<GatekeepingSelectPage> createState() => _GatekeepingSelectPageState();
}

class _GatekeepingSelectPageState extends State<GatekeepingSelectPage>
    with RouteAware, HomeBgmRouteMixin {
  Widget _buildMenuButtonWithAndy({
    required Key? buttonKey,
    required String label,
    required Color color,
    required double width,
    required double height,
    required double fontSize,
    required Color textColor,
    required VoidCallback onTap,
    required String andyAsset,
    required bool andyOnLeft,
    double andySize = 56,
    double andyAngle = 0.0,
    double andyBottom = 5,
    double andySideOffset = -6,
  }) {
    return SizedBox(
      width: width + 24,
      height: height + 20,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: BeveledMenuButton(
              key: buttonKey,
              label: label,
              color: color,
              width: width,
              height: height,
              textColor: textColor,
              fontSize: fontSize,
              onTap: onTap,
            ),
          ),

          Positioned(
            left: andyOnLeft ? andySideOffset : null,
            right: andyOnLeft ? null : andySideOffset,
            bottom: andyBottom,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: andyAngle,
                child: Image.asset(
                  andyAsset,
                  width: andySize,
                  height: andySize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double btnWidth = 300;
    const double btnHeight = 70;
    const double btnFontSize = 28;
    const double btnGap = 5;
    const Color btnTextColor = Colors.white;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.orangeBg,
        child: TutorialPageReady(
          routeName: AppRoutes.gatekeepingSelect,
          child: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    const SizedBox(height: 50),

                    Image.asset(
                      AppAssets.homeLogo,
                      width: size.width * 0.32,
                    ),

                    const SizedBox(height: 50),

                    Image.asset(
                      AppAssets.gatekeepingText,
                      width: size.width * 0.78,
                    ),

                    const SizedBox(height: 18),

                    BeveledMenuButton(
                      key: TutorialTargets.gateHowToPlay,
                      label: 'HOW TO PLAY?',
                      color: AppColors.purpleButton,
                      width: 200,
                      height: 40,
                      textColor: btnTextColor,
                      fontSize: 18,
                      onTap: () {
                        unawaited(SfxController.instance.playMenuPress());
                        Navigator.pushNamed(context, AppRoutes.mechanicsGatekeeping);
                      },
                    ),

                    const SizedBox(height: 32),

                    _buildMenuButtonWithAndy(
                      buttonKey: TutorialTargets.gateBasic,
                      label: 'BASIC',
                      color: AppColors.yellowButton,
                      width: btnWidth,
                      height: btnHeight,
                      fontSize: btnFontSize,
                      textColor: btnTextColor,
                      andyAsset: AppAssets.andyBasic,
                      andyOnLeft: true,
                      andySize: 115,
                      andyAngle: -0.16,
                      andyBottom: -10,
                      andySideOffset: -10,
                      onTap: () {
                        unawaited(SfxController.instance.playPlaySelect());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GatekeepingGamePage(
                              difficulty: Difficulty.basic,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: btnGap),

                    _buildMenuButtonWithAndy(
                      buttonKey: TutorialTargets.gateLogic,
                      label: 'LOGIC',
                      color: AppColors.darkOrangeButton,
                      width: btnWidth,
                      height: btnHeight,
                      fontSize: btnFontSize,
                      textColor: btnTextColor,
                      andyAsset: AppAssets.andyLogic,
                      andyOnLeft: false,
                      andySize: 122,
                      andyAngle: 0.19,
                      andyBottom: -15,
                      andySideOffset: -15,
                      onTap: () {
                        unawaited(SfxController.instance.playPlaySelect());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GatekeepingGamePage(
                              difficulty: Difficulty.logic,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: btnGap),

                    _buildMenuButtonWithAndy(
                      buttonKey: TutorialTargets.gateManic,
                      label: 'MANIC',
                      color: AppColors.redButton,
                      width: btnWidth,
                      height: btnHeight,
                      fontSize: btnFontSize,
                      textColor: btnTextColor,
                      andyAsset: AppAssets.andyManic,
                      andyOnLeft: true,
                      andySize: 115,
                      andyAngle: -0.14,
                      andyBottom: -10,
                      andySideOffset: -10,
                      onTap: () {
                        unawaited(SfxController.instance.playPlaySelect());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GatekeepingGamePage(
                              difficulty: Difficulty.manic,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: btnGap + 40),

                    BeveledMenuButton(
                      key: TutorialTargets.gateBack,
                      label: 'BACK',
                      color: AppColors.greyButton,
                      width: btnWidth - 150,
                      height: btnHeight - 20,
                      textColor: btnTextColor,
                      fontSize: btnFontSize - 6,
                      onTap: () {
                        unawaited(SfxController.instance.playMenuBack());
                        Navigator.pop(context);
                      },
                    ),

                    const SizedBox(height: btnGap + 20),

                    MusicButton(
                      size: size.width * 0.09,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}