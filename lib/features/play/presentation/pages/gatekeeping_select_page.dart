import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';

class GatekeepingSelectPage extends StatelessWidget {
  const GatekeepingSelectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double btnWidth = 300;
    const double btnHeight = 70;
    const double btnFontSize = 28;
    const double btnGap = 10;
    const Color btnTextColor = Colors.white;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.orangeBg,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [

                  const SizedBox(height: 100),

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
                    label: 'HOW TO PLAY?',
                    color: AppColors.purpleButton,
                    width: 200,
                    height: 40,
                    textColor: btnTextColor,
                    fontSize: 18,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.mechanicsGatekeeping);
                    },
                  ),
                  const SizedBox(height: 32),

                  BeveledMenuButton(
                    label: 'BASIC',
                    color: AppColors.yellowButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.selectMode);
                    },
                  ),
                  const SizedBox(height: btnGap),

                  BeveledMenuButton(
                    label: 'LOGIC',
                    color: AppColors.darkOrangeButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.selectMode);
                    },
                  ),
                  const SizedBox(height: btnGap),

                  BeveledMenuButton(
                    label: 'MANIC',
                    color: AppColors.redButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.logicGuide);
                    },
                  ),
                  const SizedBox(height: btnGap + 30),

                  BeveledMenuButton(
                    label: 'BACK',
                    color: AppColors.greyButton,
                    width: btnWidth - 150,
                    height: btnHeight - 20,
                    textColor: btnTextColor,
                    fontSize: btnFontSize - 6,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.selectMode);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}