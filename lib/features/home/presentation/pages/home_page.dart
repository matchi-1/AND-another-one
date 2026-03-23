import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double btnWidth = 300;
    const double btnHeight = 70;
    const double btnFontSize = 27;
    const double btnGap = 8;
    const Color btnTextColor = Colors.white;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [

                  Image.asset(
                    AppAssets.homeLogo,
                    width: size.width * 0.8,
                  ),

                  const SizedBox(height: 30),

                  BeveledMenuButton(
                    label: 'PLAY',
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
                    label: 'LOGIC GUIDE',
                    color: AppColors.pinkButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.logicGuide);
                    },
                  ),
                  const SizedBox(height: btnGap),

                  BeveledMenuButton(
                    label: 'LEADERBOARDS',
                    color: AppColors.greenButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.leaderboards);
                    },
                  ),
                  const SizedBox(height: btnGap + 30),

                  BeveledMenuButton(
                    label: 'EXIT',
                    color: AppColors.greyButton,
                    width: btnWidth - 150,
                    height: btnHeight - 20,
                    textColor: btnTextColor,
                    fontSize: btnFontSize - 6,
                    onTap: () {
                      SystemNavigator.pop();
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