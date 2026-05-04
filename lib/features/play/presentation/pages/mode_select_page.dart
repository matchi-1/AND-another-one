import 'package:and_another_one/core/audio/home_bgm_route_mixin.dart';
import 'package:and_another_one/shared/widgets/music_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../tutorial/app_tutorial_controller.dart';
import '../../../tutorial/tutorial_targets.dart';

class ModeSelectPage extends StatefulWidget {
  const ModeSelectPage({super.key});
  @override
  State<ModeSelectPage> createState() => _ModeSelectPageState();
}
class _ModeSelectPageState extends State<ModeSelectPage>
    with RouteAware, HomeBgmRouteMixin {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double btnWidth = 300;
    const double btnHeight = 75;
    const double btnFontSize = 28;
    const double btnGap = 12;
    const Color btnTextColor = Colors.white;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.redBg,
        child: TutorialPageReady(
          routeName: AppRoutes.selectMode,
          child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [

                  const SizedBox(height: 100),

                  Image.asset(
                    AppAssets.homeLogo,
                    width: size.width * 0.35,
                  ),

                  const SizedBox(height: 60),

                  Image.asset(
                    AppAssets.selectModeText,
                    width: size.width * 0.7,
                  ),

                  const SizedBox(height: 30),

                  BeveledMenuButton(
                    key: TutorialTargets.modeGatekeeping,
                    label: 'GATEKEEPING',
                    color: AppColors.orangeButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.gatekeepingSelect);
                    },
                  ),
                  const SizedBox(height: btnGap),

                  BeveledMenuButton(
                    key: TutorialTargets.modeOneOrNone,
                    label: 'ONE OR NONE',
                    color: AppColors.purpleButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.oneOrNoneSelect);
                    },
                  ),
                  const SizedBox(height: btnGap + 30),

                  BeveledMenuButton(
                    key: TutorialTargets.modeBack,
                    label: 'BACK',
                    color: AppColors.greyButton,
                    width: btnWidth - 150,
                    height: btnHeight - 20,
                    textColor: btnTextColor,
                    fontSize: btnFontSize - 6,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: btnGap + 20),

                  MusicButton(
                    size: size.width * 0.12,
                  ),
                ],
              ),
            ),
          ),
        ),
        )
      ),
    );
  }
}