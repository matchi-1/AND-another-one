import 'package:and_another_one/core/audio/home_bgm_route_mixin.dart';
import 'package:and_another_one/features/play/presentation/pages/one_or_none_game_page.dart';
import 'package:and_another_one/shared/widgets/music_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../data/models/gatekeeping_question.dart';

class OneOrNoneSelectPage extends StatefulWidget {
  const OneOrNoneSelectPage({super.key});
  @override
  State<OneOrNoneSelectPage> createState() => _OneOrNoneSelectPageState();
}

class _OneOrNoneSelectPageState extends State<OneOrNoneSelectPage>
    with RouteAware, HomeBgmRouteMixin {

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
        backgroundColor: AppColors.purpleBg,
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
                    AppAssets.oneOrNoneText,
                    width: size.width * 0.6,
                  ),

                  const SizedBox(height: 18),

                  BeveledMenuButton(
                    label: 'HOW TO PLAY?',
                    color: AppColors.pinkButton,
                    width: 200,
                    height: 40,
                    textColor: btnTextColor,
                    fontSize: 18,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.mechanicsOneOrNone);
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OneOrNoneGamePage(
                            difficulty: Difficulty.basic,
                          ),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OneOrNoneGamePage(
                            difficulty: Difficulty.logic,
                          ),
                        ),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OneOrNoneGamePage(
                            difficulty: Difficulty.manic,
                          ),
                        ),
                      );
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
      ),
    );
  }
}