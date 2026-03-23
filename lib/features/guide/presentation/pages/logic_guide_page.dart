import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';

class LogicGuidePage extends StatelessWidget {
  const LogicGuidePage({super.key});

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
        backgroundColor: AppColors.pinkBg,
        useGrid: false,
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [

                  const SizedBox(height: 100),

                  Image.asset(
                    AppAssets.diagramContainerPink,
                    width: size.width ,
                  ),

                  const SizedBox(height: 50),



                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}